@extends('layouts.admin')

@section('header', 'Swap Details')

@section('content')
<div class="max-w-3xl mx-auto">
    <div class="bg-white shadow overflow-hidden sm:rounded-lg">
        <div class="px-4 py-5 sm:px-6 flex justify-between items-center">
            <div>
                <h3 class="text-lg leading-6 font-medium text-gray-900">
                    Swap #{{ $transaction->reference }}
                </h3>
                <p class="mt-1 max-w-2xl text-sm text-gray-500">
                    {{ $transaction->created_at->format('F d, Y h:i A') }}
                </p>
            </div>
             <span class="px-3 py-1 inline-flex text-sm leading-5 font-semibold rounded-full 
                {{ $transaction->status == 'completed' ? 'bg-green-100 text-green-800' : ($transaction->status == 'pending' ? 'bg-yellow-100 text-yellow-800' : 'bg-red-100 text-red-800') }}">
                {{ ucfirst($transaction->status) }}
            </span>
        </div>
        <div class="border-t border-gray-200">
            <dl>
                <div class="bg-gray-50 px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                    <dt class="text-sm font-medium text-gray-500">User</dt>
                    <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                        @if($transaction->user)
                            <a href="{{ route('admin.users.show', $transaction->user_id) }}" class="text-blue-600 hover:underline">
                                {{ $transaction->user->name }}
                            </a>
                            <br>
                            <span class="text-gray-500">{{ $transaction->user->email }}</span>
                        @else
                            <span class="text-gray-400">Unknown User</span>
                        @endif
                    </dd>
                </div>
                
                {{-- 
                    Ideally, swap details (Sell Amount/Currency vs Buy Amount/Currency) 
                    should be stored in metadata or specific columns. 
                    For now, we display the main transaction amount.
                --}}
                
                <div class="bg-white px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                    <dt class="text-sm font-medium text-gray-500">Amount Sent</dt>
                    <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                        <span class="font-bold">{{ $transaction->currency }} {{ number_format($transaction->amount, 2) }}</span>
                    </dd>
                </div>

                @if(isset($transaction->metadata['target_currency']))
                <div class="bg-gray-50 px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                    <dt class="text-sm font-medium text-gray-500">Target Currency</dt>
                    <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                        {{ $transaction->metadata['target_currency'] }}
                    </dd>
                </div>
                @endif
                
                @if(isset($transaction->metadata['exchange_rate']))
                <div class="bg-white px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                    <dt class="text-sm font-medium text-gray-500">Exchange Rate</dt>
                    <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                        {{ $transaction->metadata['exchange_rate'] }}
                    </dd>
                </div>
                @endif

                <div class="bg-gray-50 px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                    <dt class="text-sm font-medium text-gray-500">Notes</dt>
                    <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                        {{ $transaction->description ?? 'No additional notes' }}
                    </dd>
                </div>
            </dl>
        </div>
        <div class="px-4 py-3 bg-gray-50 text-right sm:px-6">
            <button onclick="history.back()" class="inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-gray-600 hover:bg-gray-700">
                Back
            </button>
        </div>
    </div>
</div>
@endsection
