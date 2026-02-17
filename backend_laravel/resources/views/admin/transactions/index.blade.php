@extends('layouts.admin')

@section('header', 'Transaction History')

@section('content')
    <div class="bg-white rounded-lg shadow overflow-hidden">
        <div class="px-6 py-4 border-b border-gray-200 flex flex-col md:flex-row justify-between items-center space-y-2 md:space-y-0">
            <h3 class="text-lg font-semibold text-gray-800">Transaction History</h3>
            <form action="{{ route('transactions.index') }}" method="GET" class="flex flex-wrap gap-2">
                <select name="type" class="rounded border-gray-300 text-sm">
                    <option value="">All Types</option>
                    <option value="deposit" {{ request('type') == 'deposit' ? 'selected' : '' }}>Deposit</option>
                    <option value="withdrawal" {{ request('type') == 'withdrawal' ? 'selected' : '' }}>Withdrawal</option>
                    <option value="transfer" {{ request('type') == 'transfer' ? 'selected' : '' }}>Transfer</option>
                    <option value="swap" {{ request('type') == 'swap' ? 'selected' : '' }}>Swap</option>
                    <option value="bill_payment" {{ request('type') == 'bill_payment' ? 'selected' : '' }}>Bill Payment</option>
                </select>
                <select name="status" class="rounded border-gray-300 text-sm">
                    <option value="">All Status</option>
                    <option value="completed" {{ request('status') == 'completed' ? 'selected' : '' }}>Completed</option>
                    <option value="pending" {{ request('status') == 'pending' ? 'selected' : '' }}>Pending</option>
                    <option value="failed" {{ request('status') == 'failed' ? 'selected' : '' }}>Failed</option>
                </select>
                <input type="date" name="date" value="{{ request('date') }}" class="rounded border-gray-300 text-sm">
                <input type="text" name="search" placeholder="Ref or User..." value="{{ request('search') }}" class="rounded border-gray-300 text-sm">
                <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded text-sm hover:bg-blue-700">Filter</button>
            </form>
        </div>
            <table class="min-w-full leading-normal">
                <thead>
                    <tr>
                        <th class="px-5 py-3 border-b-2 border-gray-200 bg-gray-100 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                            Ref
                        </th>
                        <th class="px-5 py-3 border-b-2 border-gray-200 bg-gray-100 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                            User
                        </th>
                        <th class="px-5 py-3 border-b-2 border-gray-200 bg-gray-100 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                            Type
                        </th>
                        <th class="px-5 py-3 border-b-2 border-gray-200 bg-gray-100 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                            Amount
                        </th>
                        <th class="px-5 py-3 border-b-2 border-gray-200 bg-gray-100 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                            Status
                        </th>
                        <th class="px-5 py-3 border-b-2 border-gray-200 bg-gray-100 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                            Date
                        </th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($transactions as $transaction)
                        <tr>
                            <td class="px-5 py-5 border-b border-gray-200 bg-white text-sm">
                                <span class="text-gray-900 whitespace-no-wrap">{{ $transaction->reference ?? 'N/A' }}</span>
                            </td>
                            <td class="px-5 py-5 border-b border-gray-200 bg-white text-sm">
                                <p class="text-gray-900 whitespace-no-wrap">
                                    {{ $transaction->user->name ?? 'Unknown' }}
                                </p>
                            </td>
                            <td class="px-5 py-5 border-b border-gray-200 bg-white text-sm">
                                <span class="capitalize">{{ $transaction->type }}</span>
                            </td>
                            <td class="px-5 py-5 border-b border-gray-200 bg-white text-sm">
                                <p class="text-gray-900 whitespace-no-wrap">
                                    {{ $transaction->currency }} {{ number_format($transaction->amount, 2) }}
                                </p>
                            </td>
                            <td class="px-5 py-5 border-b border-gray-200 bg-white text-sm">
                                <span class="relative inline-block px-3 py-1 font-semibold text-{{ $transaction->status === 'completed' ? 'green' : 'yellow' }}-900 leading-tight">
                                    <span aria-hidden class="absolute inset-0 bg-{{ $transaction->status === 'completed' ? 'green' : 'yellow' }}-200 opacity-50 rounded-full"></span>
                                    <span class="relative">{{ ucfirst($transaction->status) }}</span>
                                </span>
                            </td>
                            <td class="px-5 py-5 border-b border-gray-200 bg-white text-sm">
                                <p class="text-gray-900 whitespace-no-wrap">
                                    {{ $transaction->created_at->format('M d, Y H:i') }}
                                </p>
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
        
        <div class="px-5 py-5 bg-white border-t flex flex-col xs:flex-row items-center xs:justify-between">
            {{ $transactions->links() }}
        </div>
    </div>
@endsection
