@extends('layouts.admin')

@section('header', 'Admin Management')

@section('content')
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        
        <!-- List Admins -->
        <div class="bg-white rounded-lg shadow overflow-hidden">
            <div class="px-6 py-4 border-b border-gray-200">
                <h3 class="text-lg font-semibold text-gray-800">Administrator List</h3>
            </div>
            <div class="p-6">
                @if(session('error'))
                    <div class="text-red-500 mb-4">{{ session('error') }}</div>
                @endif
                
                <ul class="space-y-4">
                    @foreach($admins as $admin)
                        <li class="flex justify-between items-center border-b pb-2">
                            <div>
                                <p class="font-bold text-gray-800">{{ $admin->name }}</p>
                                <p class="text-sm text-gray-600">{{ $admin->email }}</p>
                            </div>
                            @if(auth()->id() !== $admin->id)
                                <form action="{{ route('admin.admins.destroy', $admin) }}" method="POST">
                                    @csrf @method('DELETE')
                                    <button type="submit" class="text-red-600 hover:text-red-800" onclick="return confirm('Are you sure?')">
                                        Delete
                                    </button>
                                </form>
                            @else
                                <span class="text-xs text-gray-500 italic">(You)</span>
                            @endif
                        </li>
                    @endforeach
                </ul>
            </div>
        </div>

        <!-- Create Admin -->
        <div class="bg-white rounded-lg shadow p-6">
            <h3 class="text-lg font-semibold text-gray-800 mb-4">Create New Admin</h3>
            
            <form action="{{ route('admin.admins.store') }}" method="POST">
                @csrf
                <div class="mb-4">
                    <label class="block text-gray-700 text-sm font-bold mb-2">Name</label>
                    <input type="text" name="name" required
                        class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500">
                </div>
                <div class="mb-4">
                    <label class="block text-gray-700 text-sm font-bold mb-2">Email</label>
                    <input type="email" name="email" required
                        class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500">
                </div>
                <div class="mb-6">
                    <label class="block text-gray-700 text-sm font-bold mb-2">Password</label>
                    <input type="password" name="password" required minlength="8"
                        class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500">
                </div>
                <button type="submit" class="w-full bg-blue-600 text-white font-bold py-2 px-4 rounded hover:bg-blue-700">
                    Create Admin
                </button>
            </form>
        </div>

    </div>
@endsection
