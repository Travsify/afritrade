@extends('layouts.admin')

@section('header', 'Virtual Cards')

@section('content')
    <div class="bg-white rounded-lg shadow overflow-hidden">
        <div class="px-6 py-4 border-b border-gray-200 flex flex-col md:flex-row justify-between items-center space-y-2 md:space-y-0">
            <h3 class="text-lg font-semibold text-gray-800">Card Inventory</h3>
            <form action="{{ route('admin.virtual-cards.index') }}" method="GET" class="flex flex-wrap gap-2">
                <select name="status" class="rounded border-gray-300 text-sm">
                    <option value="">All Status</option>
                    <option value="active" {{ request('status') == 'active' ? 'selected' : '' }}>Active</option>
                    <option value="frozen" {{ request('status') == 'frozen' ? 'selected' : '' }}>Frozen</option>
                    <option value="terminated" {{ request('status') == 'terminated' ? 'selected' : '' }}>Terminated</option>
                </select>
                <input type="text" name="search" placeholder="Last 4 digits or User..." value="{{ request('search') }}" class="rounded border-gray-300 text-sm">
                <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded text-sm hover:bg-blue-700">Filter</button>
            </form>
        </div>
        
        <div class="overflow-x-auto">
            <table class="min-w-full leading-normal">
                <thead>
                    <tr>
                        <th class="px-5 py-3 border-b-2 border-gray-200 bg-gray-100 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Card Details</th>
                        <th class="px-5 py-3 border-b-2 border-gray-200 bg-gray-100 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">User</th>
                        <th class="px-5 py-3 border-b-2 border-gray-200 bg-gray-100 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Balance</th>
                        <th class="px-5 py-3 border-b-2 border-gray-200 bg-gray-100 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Status</th>
                        <th class="px-5 py-3 border-b-2 border-gray-200 bg-gray-100 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Action</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($cards as $card)
                        <tr>
                            <td class="px-5 py-5 border-b border-gray-200 bg-white text-sm">
                                <div class="flex items-center">
                                    <div class="h-10 w-16 bg-gradient-to-r from-blue-500 to-indigo-600 rounded mr-3 flex items-center justify-center text-white text-xs font-mono">
                                        **** {{ substr($card->card_number, -4) }}
                                    </div>
                                    <div>
                                        <p class="text-gray-900 whitespace-no-wrap font-semibold">{{ $card->brand }}</p>
                                        <p class="text-gray-500 text-xs">{{ $card->card_type }}</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-5 py-5 border-b border-gray-200 bg-white text-sm">
                                @if($card->user)
                                    <a href="{{ route('admin.users.show', $card->user_id) }}" class="text-blue-600 hover:underline">
                                        {{ $card->user->name }}
                                    </a>
                                @else
                                    <span class="text-gray-400">Unknown</span>
                                @endif
                            </td>
                            <td class="px-5 py-5 border-b border-gray-200 bg-white text-sm font-mono">
                                {{ $card->currency }} {{ number_format($card->balance, 2) }}
                            </td>
                            <td class="px-5 py-5 border-b border-gray-200 bg-white text-sm">
                                <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full 
                                    {{ $card->status == 'active' ? 'bg-green-100 text-green-800' : ($card->status == 'frozen' ? 'bg-yellow-100 text-yellow-800' : 'bg-red-100 text-red-800') }}">
                                    {{ ucfirst($card->status) }}
                                </span>
                            </td>
                            <td class="px-5 py-5 border-b border-gray-200 bg-white text-sm">
                                <a href="{{ route('admin.virtual-cards.show', $card->id) }}" class="text-blue-600 hover:text-blue-900">Manage</a>
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
        
        <div class="px-5 py-5 bg-white border-t flex flex-col xs:flex-row items-center xs:justify-between">
            {{ $cards->links() }}
        </div>
    </div>
@endsection
