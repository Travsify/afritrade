<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ChatMessage;
use App\Models\ChatSession;
use App\Models\SystemSetting;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;

class ChatApiController extends Controller
{
    private function getOpenAiKey() {
        return SystemSetting::where('setting_key', 'openai_api_key')->value('setting_value');
    }

    public function handle(Request $request)
    {
        $action = $request->query('action') ?? $request->input('action');
        
        if ($action == 'init') {
            return $this->initSession($request);
        } elseif ($action == 'send') {
            return $this->sendMessage($request);
        } elseif ($action == 'handover') {
            return $this->handover($request);
        } elseif ($action == 'history') {
            return $this->getHistory($request);
        }

        return response()->json(['status' => 'error', 'message' => 'Invalid action: ' . $action]);
    }

    private function getHistory(Request $request) 
    {
        $sessionId = $request->input('session_id') ?? $request->query('session_id');
        if (!$sessionId) {
            // Find active session for user
            $session = ChatSession::where('user_id', auth()->id())->latest()->first();
            if (!$session) {
                return response()->json(['status' => 'success', 'messages' => [], 'session_status' => 'ai']);
            }
            $sessionId = $session->id;
        } else {
            $session = ChatSession::find($sessionId);
            if (!$session || $session->user_id != auth()->id()) {
                return response()->json(['status' => 'error', 'message' => 'Unauthorized']);
            }
        }

        // Mark admin replies as read
        ChatMessage::where('session_id', $sessionId)
            ->where('is_admin_reply', true)
            ->where('is_read', false)
            ->update(['is_read' => true]);

        $messages = ChatMessage::where('session_id', $sessionId)->oldest()->get();
        return response()->json([
            'status' => 'success', 
            'session_id' => $sessionId,
            'session_status' => $session->status,
            'messages' => $messages
        ]);
    }

    private function initSession(Request $request)
    {
        $userId = auth()->id();
        
        // See if there's an existing active session
        $existingSession = ChatSession::where('user_id', $userId)->latest()->first();
        if ($existingSession) {
            return $this->getHistory(new Request(['session_id' => $existingSession->id]));
        }

        $sessionId = uniqid('chat_');

        ChatSession::create([
            'id' => $sessionId,
            'user_id' => $userId,
            'status' => 'ai'
        ]);

        return response()->json([
            'status' => 'success', 
            'session_id' => $sessionId,
            'session_status' => 'ai',
            'messages' => []
        ]);
    }

    private function sendMessage(Request $request)
    {
        $sessionId = $request->input('session_id');
        $message = $request->input('message');

        if (!$sessionId || !$message) {
             return response()->json(['status' => 'error', 'message' => 'Missing data']);
        }

        $session = ChatSession::find($sessionId);
        if (!$session || $session->user_id != auth()->id()) {
             return response()->json(['status' => 'error', 'message' => 'Session not found or unauthorized']);
        }

        // Save User Message
        $userMsg = ChatMessage::create([
            'session_id' => $sessionId,
            'user_id' => auth()->id(),
            'sender' => 'user',
            'message' => $message,
            'is_admin_reply' => false,
            'is_read' => false
        ]);

        if ($session->status == 'human') {
            return $this->getHistory(new Request(['session_id' => $sessionId]));
        }

        if ($session->status == 'pending_human') {
            return $this->getHistory(new Request(['session_id' => $sessionId]));
        }

        // Call OpenAI
        $apiKey = $this->getOpenAiKey();
        $reply = "I am unable to connect to the AI brain right now.";

        if ($apiKey) {
            try {
                // Get last 5 messages for context
                $history = ChatMessage::where('session_id', $sessionId)->latest()->take(5)->get()->reverse();
                $messages = [
                    ['role' => 'system', 'content' => 'You are Bridget, a helpful support assistant for Afritrad. Keep responses concise and friendly. If a user asks a complex account question, tell them you can transfer them to a human agent.']
                ];
                
                foreach ($history as $msg) {
                    if ($msg->id != $userMsg->id) { // skip the one we just saved since we add it below
                        $messages[] = [
                            'role' => $msg->sender == 'user' ? 'user' : 'assistant',
                            'content' => $msg->message
                        ];
                    }
                }
                $messages[] = ['role' => 'user', 'content' => $message];

                $response = Http::withToken($apiKey)->post('https://api.openai.com/v1/chat/completions', [
                    'model' => 'gpt-3.5-turbo',
                    'messages' => $messages
                ]);

                if ($response->successful()) {
                    $reply = $response->json()['choices'][0]['message']['content'] ?? $reply;
                }
            } catch (\Exception $e) {
                // Log error
            }
        }

        // Save AI Reply
        ChatMessage::create([
            'session_id' => $sessionId,
            'sender' => 'ai',
            'message' => $reply,
            'is_admin_reply' => false,
            'is_read' => false
        ]);

        return $this->getHistory(new Request(['session_id' => $sessionId]));
    }

    private function handover(Request $request)
    {
        $sessionId = $request->input('session_id');
        $session = ChatSession::find($sessionId);
        
        if ($session && $session->user_id == auth()->id()) {
            $session->update(['status' => 'pending_human']);
            
            ChatMessage::create([
                'session_id' => $sessionId,
                'sender' => 'ai',
                'message' => 'I have notified our support team. An agent will join this chat shortly.',
                'is_admin_reply' => false,
                'is_read' => false
            ]);
        }

        return $this->getHistory(new Request(['session_id' => $sessionId]));
    }
}
