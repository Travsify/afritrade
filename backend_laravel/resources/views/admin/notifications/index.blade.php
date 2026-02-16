@extends('layouts.admin')

@section('header', 'Notifications')

@section('content')
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        
        <!-- Create Notification -->
        <div class="bg-white rounded-lg shadow p-6">
            <h3 class="text-lg font-semibold text-gray-800 mb-4">Send New Notification</h3>
            
            @if(session('success'))
                <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative mb-4">
                    {{ session('success') }}
                </div>
            @endif

            <form action="{{ route('admin.notifications.store') }}" method="POST">
                @csrf
                <div class="mb-4">
                    <label class="block text-gray-700 text-sm font-bold mb-2">Title</label>
                    <input type="text" name="title" required
                        class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500">
                </div>
                
                <div class="mb-4">
                    <label class="block text-gray-700 text-sm font-bold mb-2">Message Body</label>
                    <textarea name="body" required rows="4"
                        class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"></textarea>
                </div>

                <div class="mb-4">
                    <label class="block text-gray-700 text-sm font-bold mb-2">Target Audience</label>
                    <select name="target" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500">
                        <option value="all">All Users</option>
                        <!-- Future: specific users/groups -->
                    </select>
                </div>

                <button type="submit" class="w-full bg-blue-600 text-white font-bold py-2 px-4 rounded hover:bg-blue-700">
                    Send Notification
                </button>
            </form>
        </div>

        <!-- History -->
        <div class="bg-white rounded-lg shadow p-6">
            <h3 class="text-lg font-semibold text-gray-800 mb-4">History</h3>
            
            <div class="space-y-4 max-h-[600px] overflow-y-auto">
                @forelse($notifications as $notification)
                    <div class="border-b pb-4 last:border-b-0">
                        <div class="flex justify-between items-start">
                            <div>
                                <h4 class="font-bold text-gray-900">{{ $notification->title }}</h4>
                                <p class="text-xs text-gray-500">{{ $notification->created_at->format('M d, Y h:i A') }}</p>
                            </div>
                            <span class="bg-green-100 text-green-800 text-xs px-2 py-1 rounded-full">Sent</span>
                        </div>
                        <p class="text-sm text-gray-600 mt-2">{{ $notification->body }}</p>
                        
                        <div class="mt-2 text-right">
                             <form action="{{ route('admin.notifications.destroy', $notification) }}" method="POST" class="inline">
                                @csrf @method('DELETE')
                                <button type="submit" class="text-red-500 text-xs hover:text-red-700" onclick="return confirm('Are you sure?')">Delete</button>
                            </form>
                        </div>
                    </div>
                @empty
                    <p class="text-gray-500 text-center py-4">No notifications sent yet.</p>
                @endforelse
            </div>
        </div>
    </div>
@endsection
