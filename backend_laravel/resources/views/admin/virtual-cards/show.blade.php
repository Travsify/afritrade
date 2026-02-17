@extends('layouts.admin')

@section('header', 'Virtual Card Details')

@section('content')
<div class="max-w-3xl mx-auto">
    <div class="bg-white shadow overflow-hidden sm:rounded-lg">
        <div class="px-4 py-5 sm:px-6 flex justify-between items-center">
            <div>
                <h3 class="text-lg leading-6 font-medium text-gray-900">
                    {{ $virtualCard->brand }} {{ $virtualCard->card_type }}
                </h3>
                <p class="mt-1 max-w-2xl text-sm text-gray-500">
                    Ending in {{ substr($virtualCard->card_number, -4) }}
                </p>
            </div>
             <span class="px-3 py-1 inline-flex text-sm leading-5 font-semibold rounded-full 
                {{ $virtualCard->status == 'active' ? 'bg-green-100 text-green-800' : ($virtualCard->status == 'frozen' ? 'bg-yellow-100 text-yellow-800' : 'bg-red-100 text-red-800') }}">
                {{ ucfirst($virtualCard->status) }}
            </span>
        </div>
        
        <!-- Card Visual Representation (Basic) -->
        <div class="p-6 bg-gradient-to-r from-gray-800 to-gray-900 text-white rounded-lg mx-6 mb-6 shadow-xl w-96 h-56 relative">
            <div class="flex justify-between items-start">
                <span class="font-bold text-lg tracking-widest">{{ strtoupper($virtualCard->brand) }}</span>
                <span class="text-xs opacity-75">{{ ucfirst($virtualCard->card_type) }}</span>
            </div>
            <div class="mt-10">
                <p class="font-mono text-2xl tracking-widest">{{ chunk_split($virtualCard->card_number, 4, ' ') }}</p>
            </div>
            <div class="flex justify-between items-end mt-8">
                <div>
                     <p class="text-xs opacity-75">Card Holder</p>
                     <p class="font-medium tracking-wide border-b border-transparent uppercase">{{ $virtualCard->name_on_card }}</p>
                </div>
                <div>
                     <p class="text-xs opacity-75">Expires</p>
                     <p class="font-medium tracking-wide">{{ $virtualCard->expiration_date }}</p>
                </div>
            </div>
        </div>

        <div class="border-t border-gray-200">
            <dl>
                <div class="bg-gray-50 px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                    <dt class="text-sm font-medium text-gray-500">Assigned User</dt>
                    <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                         @if($virtualCard->user)
                            <a href="{{ route('users.show', $virtualCard->user_id) }}" class="text-blue-600 hover:underline">
                                {{ $virtualCard->user->name }}
                            </a>
                        @else
                            <span class="text-gray-400">Unknown</span>
                        @endif
                    </dd>
                </div>
                <div class="bg-white px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                    <dt class="text-sm font-medium text-gray-500">Current Balance</dt>
                    <dd class="mt-1 text-sm font-bold text-gray-900 sm:mt-0 sm:col-span-2">
                        {{ $virtualCard->currency }} {{ number_format($virtualCard->balance, 2) }}
                    </dd>
                </div>
                <div class="bg-gray-50 px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                    <dt class="text-sm font-medium text-gray-500">Billing Address</dt>
                    <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                        {{ $virtualCard->billing_address ?? 'N/A' }}
                    </dd>
                </div>
                <div class="bg-white px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                    <dt class="text-sm font-medium text-gray-500">CVV</dt>
                    <dd class="mt-1 text-sm font-mono text-gray-900 sm:mt-0 sm:col-span-2">
                        {{ $virtualCard->cvv }}
                    </dd>
                </div>
            </dl>
        </div>
        
        <div class="px-4 py-4 sm:px-6 bg-gray-50 border-t border-gray-200 flex justify-end space-x-3">
             @if($virtualCard->status == 'active')
                <form action="{{ route('admin.virtual-cards.freeze', $virtualCard->id) }}" method="POST" onsubmit="return confirm('Freeze this card?');">
                    @csrf
                     <button type="submit" class="bg-yellow-500 text-white px-4 py-2 rounded text-sm hover:bg-yellow-600">
                        Freeze Card
                    </button>
                </form>
            @elseif($virtualCard->status == 'frozen')
                <form action="{{ route('admin.virtual-cards.unfreeze', $virtualCard->id) }}" method="POST" onsubmit="return confirm('Unfreeze this card?');">
                    @csrf
                     <button type="submit" class="bg-green-600 text-white px-4 py-2 rounded text-sm hover:bg-green-700">
                        Unfreeze Card
                    </button>
                </form>
            @endif
             
             <button onclick="history.back()" class="inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-gray-600 hover:bg-gray-700">
                Back
            </button>
        </div>
    </div>
</div>
@endsection
