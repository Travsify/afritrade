@extends('layouts.admin')

@section('header', 'Virtual Accounts')

@section('content')
    <div class="bg-white rounded-lg shadow overflow-hidden">
        <div class="px-6 py-4 border-b border-gray-200 flex flex-col md:flex-row justify-between items-center space-y-2 md:space-y-0">
            <h3 class="text-lg font-semibold text-gray-800">Account Inventory</h3>
            <form action="{{ route('virtual-accounts.index') }}" method="GET" class="flex flex-wrap gap-2">
                <select name="bank_name" class="rounded border-gray-300 text-sm">
                    <option value="">All Banks</option>
                    <option value="Wema" {{ request('bank_name') == 'Wema' ? 'selected' : '' }}>Wema Bank</option>
                    <option value="Providus" {{ request('bank_name') == 'Providus' ? 'selected' : '' }}>Providus Bank</option>
                    <option value="Moniepoint" {{ request('bank_name') == 'Moniepoint' ? 'selected' : '' }}>Moniepoint</option>
                </select>
                <input type="text" name="search" placeholder="Account No or User..." value="{{ request('search') }}" class="rounded border-gray-300 text-sm">
                <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded text-sm hover:bg-blue-700">Filter</button>
            </form>
        </div>
        
        <div class="overflow-x-auto">
            <table class="min-w-full leading-normal">
                <thead>
                    <tr>
                        <th class="px-5 py-3 border-b-2 border-gray-200 bg-gray-100 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Account Info</th>
                        <th class="px-5 py-3 border-b-2 border-gray-200 bg-gray-100 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Assigned To</th>
                        <th class="px-5 py-3 border-b-2 border-gray-200 bg-gray-100 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Bank</th>
                        <th class="px-5 py-3 border-b-2 border-gray-200 bg-gray-100 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Currency</th>
                        <th class="px-5 py-3 border-b-2 border-gray-200 bg-gray-100 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Date Created</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($accounts as $account)
                        <tr>
                            <td class="px-5 py-5 border-b border-gray-200 bg-white text-sm">
                                <p class="text-gray-900 font-mono font-bold">{{ $account->account_number }}</p>
                                <p class="text-gray-500 text-xs">{{ $account->account_name }}</p>
                            </td>
                            <td class="px-5 py-5 border-b border-gray-200 bg-white text-sm">
                                @if($account->user)
                                    <a href="{{ route('users.show', $account->user_id) }}" class="text-blue-600 hover:underline">
                                        {{ $account->user->name }}
                                    </a>
                                @else
                                    <span class="text-gray-400 italic">Unassigned</span>
                                @endif
                            </td>
                            <td class="px-5 py-5 border-b border-gray-200 bg-white text-sm">
                                <span class="bg-gray-100 text-gray-800 px-2 py-1 rounded text-xs font-semibold">{{ $account->bank_name }}</span>
                            </td>
                            <td class="px-5 py-5 border-b border-gray-200 bg-white text-sm">
                                 <span class="font-bold">{{ $account->currency }}</span>
                            </td>
                            <td class="px-5 py-5 border-b border-gray-200 bg-white text-sm">
                                {{ $account->created_at->format('M d, Y') }}
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
        
        <div class="px-5 py-5 bg-white border-t flex flex-col xs:flex-row items-center xs:justify-between">
            {{ $accounts->links() }}
        </div>
    </div>
@endsection
