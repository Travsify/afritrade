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
        $action = $request->query('action');
        
        if ($action == 'init') {
            return $this->initSession($request);
        } elseif ($action == 'send') {
            return $this->sendMessage($request);
        } elseif ($action == 'handover') {
            return $this->handover($request);
        }

        return response()->json(['status' => 'error', 'message' => 'Invalid action']);
    }

    private function initSession(Request $request)
    {
        $userId = $request->input('user_id') ?? 'guest'; // Legacy used user_id input
        $sessionId = uniqid('chat_');

        ChatSession::create([
            'id' => $sessionId,
            'user_id' => $userId,
            'status' => 'ai'
        ]);

        return response()->json(['status' => 'success', 'session_id' => $sessionId]);
    }

    private function sendMessage(Request $request)
    {
        $sessionId = $request->input('session_id');
        $message = $request->input('message');

        if (!$sessionId || !$message) {
             return response()->json(['status' => 'error', 'message' => 'Missing data']);
        }

        // Save User Message
        ChatMessage::create([
            'session_id' => $sessionId,
            'sender' => 'user',
            'message' => $message
        ]);

        $session = ChatSession::find($sessionId);
        if (!$session) {
             return response()->json(['status' => 'error', 'message' => 'Session not found']);
        }

        if ($session->status == 'human') {
            return response()->json(['status' => 'success', 'reply' => null, 'mode' => 'human']);
        }

        if ($session->status == 'pending_human') {
            return response()->json(['status' => 'success', 'reply' => "An agent will be with you shortly.", 'mode' => 'human']);
        }

        // Call OpenAI
        $apiKey = $this->getOpenAiKey();
        $reply = "I am unable to connect to the AI brain right now.";

        if ($apiKey) {
            try {
                $response = Http::withToken($apiKey)->post('https://api.openai.com/v1/chat/completions', [
                    'model' => 'gpt-3.5-turbo',
                    'messages' => [
                        ['role' => 'system', 'content' => 'You are Bridget, a helpful support assistant for Afritrad.'],
                        ['role' => 'user', 'content' => $message]
                    ]
                ]);

                if ($response->successful()) {
                    $reply = $response->json()['choices'][0]['message']['content'] ?? $reply;
                }
            } catch (\Exception $e) {
                // Log error?
            }
        }

        // Save AI Reply
        ChatMessage::create([
            'session_id' => $sessionId,
            'sender' => 'ai',
            'message' => $reply
        ]);

        return response()->json(['status' => 'success', 'reply' => $reply, 'mode' => 'ai']);
    }

    private function handover(Request $request)
    {
        $sessionId = $request->input('session_id');
        $session = ChatSession::find($sessionId);
        
        if ($session) {
            $session->update(['status' => 'pending_human']);
        }

        return response()->json(['status' => 'success', 'message' => 'Handover requested']);
    }
}
