@extends('layouts.admin')

@section('header', 'Transaction Details')

@section('content')
<div class="max-w-3xl mx-auto">
    <div class="bg-white shadow overflow-hidden sm:rounded-lg">
        <div class="px-4 py-5 sm:px-6 flex justify-between items-center">
            <div>
                <h3 class="text-lg leading-6 font-medium text-gray-900">
                    Transaction #{{ $transaction->reference }}
                </h3>
                <p class="mt-1 max-w-2xl text-sm text-gray-500">
                    {{ $transaction->created_at->format('F d, Y h:i A') }}
                </p>
            </div>
            <div>
                <span class="px-3 py-1 inline-flex text-sm leading-5 font-semibold rounded-full 
                    {{ $transaction->status == 'completed' ? 'bg-green-100 text-green-800' : ($transaction->status == 'pending' ? 'bg-yellow-100 text-yellow-800' : 'bg-red-100 text-red-800') }}">
                    {{ ucfirst($transaction->status) }}
                </span>
            </div>
        </div>
        <div class="border-t border-gray-200">
            <dl>
                <div class="bg-gray-50 px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                    <dt class="text-sm font-medium text-gray-500">User</dt>
                    <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                        <a href="{{ route('admin.users.show', $transaction->user_id) }}" class="text-blue-600 hover:underline">
                            {{ $transaction->user->name }}
                        </a>
                        <br>
                        <span class="text-gray-500">{{ $transaction->user->email }}</span>
                    </dd>
                </div>
                <div class="bg-white px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                    <dt class="text-sm font-medium text-gray-500">Prepare For</dt>
                    <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2 capitalize">
                        {{ str_replace('_', ' ', $transaction->type) }}
                    </dd>
                </div>
                <div class="bg-gray-50 px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                    <dt class="text-sm font-medium text-gray-500">Amount</dt>
                    <dd class="mt-1 text-sm font-bold text-gray-900 sm:mt-0 sm:col-span-2">
                        {{ $transaction->currency }} {{ number_format($transaction->amount, 2) }}
                    </dd>
                </div>
                <div class="bg-white px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                    <dt class="text-sm font-medium text-gray-500">Recipient</dt>
                    <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                        {{ $transaction->recipient ?? 'N/A' }}
                    </dd>
                </div>
                <!-- Additional Details (JSON) -->
                {{-- 
                @if($transaction->metadata)
                <div class="bg-gray-50 px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                     <dt class="text-sm font-medium text-gray-500">Metadata</dt>
                     <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                         <pre class="text-xs bg-gray-100 p-2 rounded">{{ json_encode($transaction->metadata, JSON_PRETTY_PRINT) }}</pre>
                     </dd>
                </div>
                @endif
                --}}
            </dl>
        </div>
        
        <div class="px-4 py-4 sm:px-6 bg-gray-50 border-t border-gray-200 flex justify-end space-x-3">
            @if($transaction->status == 'pending')
                <form action="{{ route('admin.transactions.requery', $transaction->id) }}" method="POST">
                    @csrf
                    <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded text-sm hover:bg-blue-700">
                        Re-query Status
                    </button>
                </form>
            @endif
            
            @if($transaction->status != 'completed')
                <form action="{{ route('admin.transactions.update', $transaction->id) }}" method="POST" onsubmit="return confirm('Manually mark as completed?');">
                    @csrf
                    @method('PUT')
                    <input type="hidden" name="status" value="completed">
                    <button type="submit" class="bg-green-600 text-white px-4 py-2 rounded text-sm hover:bg-green-700">
                        Mark Completed
                    </button>
                </form>
                <form action="{{ route('admin.transactions.update', $transaction->id) }}" method="POST" onsubmit="return confirm('Manually mark as failed?');">
                    @csrf
                    @method('PUT')
                    <input type="hidden" name="status" value="failed">
                    <button type="submit" class="bg-red-600 text-white px-4 py-2 rounded text-sm hover:bg-red-700">
                        Mark Failed
                    </button>
                </form>
            @endif

            <button onclick="window.print()" class="bg-gray-200 text-gray-800 px-4 py-2 rounded text-sm hover:bg-gray-300">
                Print Receipt
            </button>
        </div>
    </div>
</div>
@endsection
