@extends('layouts.admin')

@section('header', 'Payment Details')

@section('content')
<div class="max-w-3xl mx-auto">
    <div class="bg-white shadow overflow-hidden sm:rounded-lg">
        <div class="px-4 py-5 sm:px-6 flex justify-between items-center">
            <div>
                <h3 class="text-lg leading-6 font-medium text-gray-900">
                    Ref #{{ $transaction->reference }}
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
                            <a href="{{ route('users.show', $transaction->user_id) }}" class="text-blue-600 hover:underline">
                                {{ $transaction->user->name }}
                            </a>
                        @else
                            <span class="text-gray-400">Unknown User</span>
                        @endif
                    </dd>
                </div>
                
                <div class="bg-white px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                    <dt class="text-sm font-medium text-gray-500">Amount</dt>
                    <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2 font-bold">
                        {{ $transaction->currency }} {{ number_format($transaction->amount, 2) }}
                    </dd>
                </div>

                @if(isset($transaction->metadata['biller_name']))
                <div class="bg-gray-50 px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                    <dt class="text-sm font-medium text-gray-500">Service/Biller</dt>
                    <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                        {{ $transaction->metadata['biller_name'] }}
                    </dd>
                </div>
                @endif
                
                @if(isset($transaction->metadata['customer_id']))
                <div class="bg-white px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                    <dt class="text-sm font-medium text-gray-500">Customer ID</dt>
                    <dd class="mt-1 text-sm font-mono text-gray-900 sm:mt-0 sm:col-span-2">
                        {{ $transaction->metadata['customer_id'] }}
                    </dd>
                </div>
                @endif

                <div class="bg-gray-50 px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                    <dt class="text-sm font-medium text-gray-500">Provider Response</dt>
                    <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                        <pre class="bg-gray-100 p-2 rounded text-xs overflow-x-auto">{{ json_encode($transaction->metadata, JSON_PRETTY_PRINT) }}</pre>
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
