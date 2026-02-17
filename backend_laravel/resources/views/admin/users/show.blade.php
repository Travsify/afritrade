@extends('layouts.admin')

@section('header', 'User Details')

@section('content')
<div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
    <!-- Left Column: User Profile -->
    <div class="lg:col-span-1 space-y-6">
        <div class="bg-white rounded-lg shadow p-6">
            <div class="text-center mb-6">
                <div class="h-24 w-24 rounded-full bg-blue-100 flex items-center justify-center mx-auto text-blue-500 text-3xl font-bold">
                    {{ substr($user->name, 0, 1) }}
                </div>
                <h2 class="mt-4 text-xl font-bold text-gray-800">{{ $user->name }}</h2>
                <p class="text-gray-500">{{ $user->email }}</p>
                <div class="mt-2">
                    <span class="px-3 py-1 rounded-full text-sm font-semibold 
                        {{ $user->verification_status == 'verified' ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800' }}">
                        {{ ucfirst($user->verification_status) }}
                    </span>
                    <span class="ml-2 text-sm text-gray-500">Tier {{ $user->kyc_tier }}</span>
                </div>
            </div>

            <div class="border-t pt-4 space-y-3">
                <div class="flex justify-between">
                    <span class="text-gray-600">Joined</span>
                    <span class="font-medium">{{ $user->created_at->format('M d, Y') }}</span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-600">Phone</span>
                    <span class="font-medium">{{ $user->phone ?? 'N/A' }}</span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-600">Country</span>
                    <span class="font-medium">{{ $user->country ?? 'N/A' }}</span>
                </div>
            </div>

            <div class="mt-6 space-y-2">
                {{-- Action Buttons --}}
                <form action="{{ route('users.update', $user->id) }}" method="POST">
                    @csrf
                    @method('PUT')
                    <!-- Quick KYC Update for Admin -->
                    <div class="mb-4">
                         <label class="block text-sm font-medium text-gray-700">Update KYC Tier</label>
                         <div class="flex space-x-2 mt-1">
                             <input type="hidden" name="name" value="{{ $user->name }}">
                             <input type="hidden" name="email" value="{{ $user->email }}">
                             <input type="hidden" name="verification_status" value="{{ $user->verification_status }}">
                             <select name="kyc_tier" class="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm">
                                <option value="0" {{ $user->kyc_tier == 0 ? 'selected' : '' }}>Tier 0</option>
                                <option value="1" {{ $user->kyc_tier == 1 ? 'selected' : '' }}>Tier 1</option>
                                <option value="2" {{ $user->kyc_tier == 2 ? 'selected' : '' }}>Tier 2</option>
                                <option value="3" {{ $user->kyc_tier == 3 ? 'selected' : '' }}>Tier 3</option>
                             </select>
                             <button type="submit" class="bg-blue-600 text-white px-3 py-1 rounded text-sm">Save</button>
                         </div>
                    </div>
                </form>

                <form action="{{ route('users.destroy', $user->id) }}" method="POST" onsubmit="return confirm('Suspend this user transaction capability?');">
                    @csrf
                    @method('DELETE')
                    <button class="w-full bg-red-50 text-red-600 py-2 rounded-lg font-medium hover:bg-red-100">
                        Suspend User
                    </button>
                </form>
            </div>
        </div>

        <!-- Wallets Summary -->
        <div class="bg-white rounded-lg shadow p-6">
            <h3 class="font-bold text-gray-700 mb-4">Wallet Balances</h3>
            <div class="space-y-4">
                <div class="flex justify-between items-center p-3 bg-gray-50 rounded">
                    <div class="flex items-center">
                        <span class="font-bold text-gray-700">USD</span>
                    </div>
                    <span class="font-bold font-mono">${{ number_format($totalBalanceUSD, 2) }}</span>
                </div>
                <div class="flex justify-between items-center p-3 bg-gray-50 rounded">
                    <div class="flex items-center">
                        <span class="font-bold text-gray-700">NGN</span>
                    </div>
                    <span class="font-bold font-mono">₦{{ number_format($totalBalanceNGN, 2) }}</span>
                </div>
            </div>
        </div>
    </div>

    <!-- Right Column: Tabs -->
    <div class="lg:col-span-2 space-y-6">
        
        <!-- Transaction History -->
        <div class="bg-white rounded-lg shadow overflow-hidden">
            <div class="px-6 py-4 border-b border-gray-200">
                <h3 class="text-lg font-semibold text-gray-800">Recent Transactions</h3>
            </div>
            <div class="overflow-x-auto">
                <table class="min-w-full leading-normal">
                    <thead>
                        <tr>
                            <th class="px-5 py-3 bg-gray-50 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Type</th>
                            <th class="px-5 py-3 bg-gray-50 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Amount</th>
                            <th class="px-5 py-3 bg-gray-50 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Status</th>
                            <th class="px-5 py-3 bg-gray-50 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Date</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse($user->transactions as $tx)
                            <tr>
                                <td class="px-5 py-4 border-b border-gray-200 bg-white text-sm">
                                    <span class="font-medium text-gray-700 capitalize">{{ str_replace('_', ' ', $tx->type) }}</span>
                                    <div class="text-xs text-gray-500">{{ $tx->reference }}</div>
                                </td>
                                <td class="px-5 py-4 border-b border-gray-200 bg-white text-sm font-mono">
                                    {{ $tx->currency }} {{ number_format($tx->amount, 2) }}
                                </td>
                                <td class="px-5 py-4 border-b border-gray-200 bg-white text-sm">
                                    <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full 
                                        {{ $tx->status == 'completed' ? 'bg-green-100 text-green-800' : ($tx->status == 'pending' ? 'bg-yellow-100 text-yellow-800' : 'bg-red-100 text-red-800') }}">
                                        {{ ucfirst($tx->status) }}
                                    </span>
                                </td>
                                <td class="px-5 py-4 border-b border-gray-200 bg-white text-sm">
                                    {{ $tx->created_at->format('M d, H:i') }}
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="4" class="px-5 py-4 text-center text-gray-500">No transactions found.</td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>

        <!-- KYC Documents -->
        <div class="bg-white rounded-lg shadow overflow-hidden">
             <div class="px-6 py-4 border-b border-gray-200">
                <h3 class="text-lg font-semibold text-gray-800">KYC Documents</h3>
            </div>
            <div class="p-6">
                @if($user->kycDocuments->count() > 0)
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        @foreach($user->kycDocuments as $doc)
                            <div class="border rounded p-4">
                                <div class="flex justify-between items-start">
                                    <div>
                                        <p class="font-semibold text-gray-800 capitalize">{{ str_replace('_', ' ', $doc->document_type) }}</p>
                                        <p class="text-sm text-gray-500">{{ $doc->document_number }}</p>
                                        <span class="mt-2 inline-block px-2 py-1 text-xs font-semibold rounded 
                                            {{ $doc->status == 'approved' ? 'bg-green-100 text-green-800' : ($doc->status == 'pending' ? 'bg-yellow-100 text-yellow-800' : 'bg-red-100 text-red-800') }}">
                                            {{ ucfirst($doc->status) }}
                                        </span>
                                    </div>
                                    @if($doc->file_path)
                                        <a href="{{ Storage::url($doc->file_path) }}" target="_blank" class="text-blue-600 text-sm hover:underline">View File</a>
                                    @endif
                                </div>
                                <div class="mt-3 flex space-x-2">
                                     <a href="#" class="text-xs bg-green-50 text-green-700 px-2 py-1 rounded border border-green-200 hover:bg-green-100">Approve</a>
                                     <a href="#" class="text-xs bg-red-50 text-red-700 px-2 py-1 rounded border border-red-200 hover:bg-red-100">Reject</a>
                                </div>
                            </div>
                        @endforeach
                    </div>
                @else
                    <p class="text-gray-500">No KYC documents submitted.</p>
                @endif
            </div>
        </div>

    </div>
</div>
@endsection
