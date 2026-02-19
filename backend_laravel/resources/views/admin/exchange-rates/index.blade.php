@extends('layouts.admin')

@section('header', 'Exchange Rate Management')

@section('content')
<div class="max-w-6xl mx-auto">
    <div class="bg-white shadow overflow-hidden sm:rounded-lg mb-6">
        <div class="px-4 py-5 sm:px-6 flex justify-between items-center bg-indigo-50">
            <div>
                <h3 class="text-lg leading-6 font-bold text-gray-900">
                    Regional FX Markups
                </h3>
                <p class="mt-1 max-w-2xl text-sm text-gray-600">
                    Define how much to add (fixed or %) to base rates fetched from providers.
                </p>
            </div>
            <button onclick="toggleAddModal()" class="bg-indigo-600 text-white px-4 py-2 rounded text-sm font-semibold hover:bg-indigo-700 transition">Add New Pair</button>
        </div>
        
        <div class="border-t border-gray-200">
            <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50 text-gray-500 text-xs font-semibold uppercase tracking-wider">
                    <tr>
                        <th scope="col" class="px-6 py-3 text-left">Currency Pair</th>
                        <th scope="col" class="px-6 py-3 text-left">Markup Style</th>
                        <th scope="col" class="px-6 py-3 text-left">Fixed Add-on</th>
                        <th scope="col" class="px-6 py-3 text-left">Percentage (%)</th>
                        <th scope="col" class="px-6 py-3 text-left">Status</th>
                        <th scope="col" class="px-6 py-3 text-right">Actions</th>
                    </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200 text-sm">
                    @foreach($markups as $markup)
                    <tr>
                        <form action="{{ route('admin.exchange-rates.update') }}" method="POST">
                            @csrf
                            @method('POST') {{-- Using POST since the controller update handles multi-field --}}
                            <input type="hidden" name="id" value="{{ $markup->id }}">
                            
                            <td class="px-6 py-4 whitespace-nowrap font-bold text-indigo-900 uppercase">
                                {{ $markup->from_currency }} / {{ $markup->to_currency }}
                            </td>
                            <td class="px-6 py-4">
                                <select name="markup_type" class="rounded-md border-gray-300 text-xs py-1">
                                    <option value="fixed" {{ $markup->markup_type == 'fixed' ? 'selected' : '' }}>Flat Fee</option>
                                    <option value="percentage" {{ $markup->markup_type == 'percentage' ? 'selected' : '' }}>Percentage</option>
                                    <option value="both" {{ $markup->markup_type == 'both' ? 'selected' : '' }}>Flat + %</option>
                                </select>
                            </td>
                            <td class="px-6 py-4">
                                <input type="number" step="0.01" name="fixed_markup" value="{{ $markup->fixed_markup }}" class="w-24 rounded-md border-gray-300 text-xs py-1">
                            </td>
                            <td class="px-6 py-4">
                                <input type="number" step="0.01" name="percentage_markup" value="{{ $markup->percentage_markup }}" class="w-16 rounded-md border-gray-300 text-xs py-1">
                            </td>
                            <td class="px-6 py-4">
                                <select name="is_active" class="rounded-md border-gray-300 text-xs py-1">
                                    <option value="1" {{ $markup->is_active ? 'selected' : '' }}>Active</option>
                                    <option value="0" {{ !$markup->is_active ? 'selected' : '' }}>Inactive</option>
                                </select>
                            </td>
                            <td class="px-6 py-4 text-right">
                                <button type="submit" class="text-indigo-600 hover:text-indigo-900 font-bold">Save</button>
                            </td>
                        </form>
                    </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>

    <!-- Add Modal Placeholder -->
    <div id="addModal" class="hidden fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full">
        <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
            <div class="mt-3 text-center">
                <h3 class="text-lg leading-6 font-medium text-gray-900">Add New FX Pair</h3>
                <form action="{{ route('admin.exchange-rates.store') }}" method="POST" class="mt-4 text-left">
                    @csrf
                    <div class="mb-4">
                        <label class="block text-gray-700 text-xs font-bold mb-1">From Currency (3 chars)</label>
                        <input type="text" name="from_currency" placeholder="USD" class="w-full rounded-md border-gray-300 text-sm" required>
                    </div>
                    <div class="mb-4">
                        <label class="block text-gray-700 text-xs font-bold mb-1">To Currency (3 chars)</label>
                        <input type="text" name="to_currency" placeholder="NGN" class="w-full rounded-md border-gray-300 text-sm" required>
                    </div>
                    <div class="mb-4">
                        <label class="block text-gray-700 text-xs font-bold mb-1">Markup Type</label>
                        <select name="markup_type" class="w-full rounded-md border-gray-300 text-sm">
                            <option value="percentage">Percentage</option>
                            <option value="fixed">Fixed</option>
                            <option value="both">Both</option>
                        </select>
                    </div>
                    <div class="flex gap-2 mb-4">
                        <div class="w-1/2">
                            <label class="block text-gray-700 text-xs font-bold mb-1">Fixed</label>
                            <input type="number" step="0.01" name="fixed_markup" value="0.00" class="w-full rounded-md border-gray-300 text-sm">
                        </div>
                        <div class="w-1/2">
                            <label class="block text-gray-700 text-xs font-bold mb-1">Percentage %</label>
                            <input type="number" step="0.01" name="percentage_markup" value="0.00" class="w-full rounded-md border-gray-300 text-sm">
                        </div>
                    </div>
                    <div class="items-center px-4 py-3 flex gap-2">
                        <button type="submit" class="px-4 py-2 bg-indigo-600 text-white text-base font-medium rounded-md w-full shadow-sm hover:bg-indigo-700">Add Pair</button>
                        <button type="button" onclick="toggleAddModal()" class="px-4 py-2 bg-gray-100 text-gray-700 text-base font-medium rounded-md w-full shadow-sm hover:bg-gray-200">Cancel</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
    function toggleAddModal() {
        document.getElementById('addModal').classList.toggle('hidden');
    }
</script>
@endsection
