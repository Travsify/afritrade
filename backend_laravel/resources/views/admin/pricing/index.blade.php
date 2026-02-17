@extends('layouts.admin')

@section('header', 'Pricing & Markups')

@section('content')
<div class="bg-white rounded-lg shadow overflow-hidden">
    <div class="px-6 py-4 border-b border-gray-200">
        <h3 class="text-lg font-semibold text-gray-800">Global Service Fees</h3>
        <p class="text-sm text-gray-500">Manage fixed fees and percentage markups for all platform services.</p>
    </div>
    
    <div class="p-6">
        <table class="min-w-full divide-y divide-gray-200">
            <thead>
                <tr>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Service</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Fee Type</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Fixed Fee</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Percentage</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Action</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
                @foreach($markups as $markup)
                <tr>
                    <form action="{{ route('admin.pricing.update', $markup->id) }}" method="POST">
                        @csrf
                        @method('PUT')
                        <td class="px-6 py-4 font-medium text-gray-900 uppercase">
                            {{ str_replace('_', ' ', $markup->service_name) }}
                        </td>
                        <td class="px-6 py-4">
                            <select name="fee_type" class="text-sm rounded border-gray-300">
                                <option value="fixed" {{ $markup->fee_type == 'fixed' ? 'selected' : '' }}>Fixed</option>
                                <option value="percentage" {{ $markup->fee_type == 'percentage' ? 'selected' : '' }}>Percentage</option>
                                <option value="both" {{ $markup->fee_type == 'both' ? 'selected' : '' }}>Both</option>
                            </select>
                        </td>
                        <td class="px-6 py-4">
                            <input type="number" step="0.01" name="fixed_fee" value="{{ $markup->fixed_fee }}" class="w-24 text-sm rounded border-gray-300">
                        </td>
                        <td class="px-6 py-4">
                            <div class="flex items-center">
                                <input type="number" step="0.01" name="percentage_fee" value="{{ $markup->percentage_fee }}" class="w-20 text-sm rounded border-gray-300">
                                <span class="ml-1 text-gray-500">%</span>
                            </div>
                        </td>
                        <td class="px-6 py-4">
                            <select name="is_active" class="text-sm rounded border-gray-300">
                                <option value="1" {{ $markup->is_active ? 'selected' : '' }}>Active</option>
                                <option value="0" {{ !$markup->is_active ? 'selected' : '' }}>Disabled</option>
                            </select>
                        </td>
                        <td class="px-6 py-4">
                            <button type="submit" class="bg-blue-600 text-white px-3 py-1 rounded text-xs hover:bg-blue-700">Save</button>
                        </td>
                    </form>
                </tr>
                @endforeach
            </tbody>
        </table>
    </div>
</div>
@endsection
