@extends('layouts.admin')

@section('header', 'Fintech Provider Monitoring')

@section('content')
<div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
    <!-- Fincra Wallet -->
    <div class="bg-white rounded-lg shadow p-6 border-l-4 border-blue-500">
        <h3 class="text-lg font-bold text-gray-800 mb-4">Fincra Wallets</h3>
        @foreach($balances['fincra'] as $balance)
            <div class="flex justify-between items-center mb-2">
                <span class="text-gray-600 font-medium">{{ $balance['currency'] }}</span>
                <span class="text-xl font-bold">{{ $balance['amount'] }}</span>
            </div>
        @endforeach
        <div class="mt-4 pt-4 border-t text-sm text-gray-500">
            Status: <span class="text-green-600 font-bold">Operational</span>
        </div>
    </div>

    <!-- Maplerad Wallet -->
    <div class="bg-white rounded-lg shadow p-6 border-l-4 border-purple-500">
        <h3 class="text-lg font-bold text-gray-800 mb-4">Maplerad Wallets</h3>
        @foreach($balances['maplerad'] as $balance)
            <div class="flex justify-between items-center mb-2">
                <span class="text-gray-600 font-medium">{{ $balance['currency'] }}</span>
                <span class="text-xl font-bold">{{ $balance['amount'] }}</span>
            </div>
        @endforeach
        <div class="mt-4 pt-4 border-t text-sm text-gray-500">
            Status: <span class="text-green-600 font-bold">Operational</span>
        </div>
    </div>

    <!-- Klasha Wallet -->
    <div class="bg-white rounded-lg shadow p-6 border-l-4 border-red-500">
        <h3 class="text-lg font-bold text-gray-800 mb-4">Klasha Wallets</h3>
        @foreach($balances['klasha'] as $balance)
            <div class="flex justify-between items-center mb-2">
                <span class="text-gray-600 font-medium">{{ $balance['currency'] }}</span>
                <span class="text-xl font-bold">{{ $balance['amount'] }}</span>
            </div>
        @endforeach
        <div class="mt-4 pt-4 border-t text-sm text-gray-500">
            Status: <span class="text-green-600 font-bold">Active</span>
        </div>
    </div>
</div>

<div class="bg-white rounded-lg shadow overflow-hidden">
    <div class="px-6 py-4 border-b bg-gray-50 text-sm font-bold text-gray-700">
        Recent API Transactions & Webhooks
    </div>
    <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
            <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Provider</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Event</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Time</th>
            </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
            <tr>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">Fincra</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">Virtual Account Request</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-green-500 font-bold">SUCCESS</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">2 mins ago</td>
            </tr>
            <tr>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">Maplerad</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">Card Issued</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-green-500 font-bold">SUCCESS</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">1 hour ago</td>
            </tr>
            <tr>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">Klasha</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">China Payment (Alipay)</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-green-500 font-bold">SUCCESS</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">3 hours ago</td>
            </tr>
        </tbody>
    </table>
</div>
@endsection
