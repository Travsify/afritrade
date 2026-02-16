@extends('layouts.admin')

@section('header', 'Chat with ' . ($chatSession->user->name ?? 'Guest'))

@section('content')
    <div class="flex flex-col h-[calc(100vh-12rem)]">
        <!-- Messages Area -->
        <div class="flex-1 overflow-y-auto bg-white rounded-lg shadow p-4 mb-4 space-y-4">
            @foreach($chatSession->messages as $message)
                <div class="flex {{ $message->is_admin_reply ? 'justify-end' : 'justify-start' }}">
                    <div class="max-w-xs lg:max-w-md px-4 py-2 rounded-lg {{ $message->is_admin_reply ? 'bg-blue-500 text-white' : 'bg-gray-200 text-gray-800' }}">
                        <p class="text-sm">{{ $message->message }}</p>
                        <p class="text-xs {{ $message->is_admin_reply ? 'text-blue-100' : 'text-gray-500' }} mt-1 text-right">
                            {{ $message->created_at->format('H:i') }}
                        </p>
                    </div>
                </div>
            @endforeach
        </div>

        <!-- Reply Area -->
        <div class="bg-white rounded-lg shadow p-4">
            <form action="{{ route('admin.chat.update', $chatSession->id) }}" method="POST" class="flex gap-4">
                @csrf
                @method('PUT')
                <input type="text" name="message" class="flex-1 rounded-lg border-gray-300 focus:border-blue-500 focus:ring-blue-500" placeholder="Type your reply..." required>
                <button type="submit" class="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 transition">Send</button>
            </form>
        </div>
    </div>
@endsection
