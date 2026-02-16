<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index()
    {
        $notifications = Notification::latest()->get();
        return view('admin.notifications.index', compact('notifications'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'body' => 'required|string',
        ]);

        $notification = Notification::create([
            'title' => $request->title,
            'body' => $request->body,
            'type' => 'announcement',
            'is_sent' => true,
            'sent_at' => now(),
        ]);

        // Logic to send push notification via Firebase/OneSignal would go here.
        // For now, we assume it's "sent" as a system record.

        return back()->with('success', 'Notification sent successfully.');
    }

    public function destroy(Notification $notification)
    {
        $notification->delete();
        return back()->with('success', 'Notification deleted.');
    }
}
