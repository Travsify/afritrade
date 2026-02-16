<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\ChatSession;
use Illuminate\Http\Request;

class ChatController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $sessions = ChatSession::with('user')->withCount(['messages as unread_count' => function($query) {
            $query->where('is_admin_reply', false)->where('is_read', false);
        }])->latest()->paginate(15);
        
        return view('admin.chat.index', compact('sessions'));
    }

    public function show(ChatSession $chatSession)
    {
        $chatSession->load(['messages', 'user']);
        // Mark admin messages as read? Usually we mark user messages as read by admin.
        $chatSession->messages()->where('is_admin_reply', false)->update(['is_read' => true]);
        
        return view('admin.chat.show', compact('chatSession'));
    }

    public function update(Request $request, ChatSession $chatSession)
    {
        $request->validate([
            'message' => 'required|string'
        ]);

        $chatSession->messages()->create([
            'user_id' => auth()->id(), // Assuming admin is logged in as user or we use guard
            'message' => $request->message,
            'is_admin_reply' => true,
        ]);

        $chatSession->touch(); // Update updated_at to move to top

        return back()->with('success', 'Reply sent successfully.');
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        //
    }
}
