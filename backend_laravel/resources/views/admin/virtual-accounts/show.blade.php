@extends('layouts.admin')

@section('header', 'Virtual Account Details')

@section('content')
<div class="max-w-3xl mx-auto">
    <div class="bg-white shadow overflow-hidden sm:rounded-lg">
        <div class="px-4 py-5 sm:px-6">
            <h3 class="text-lg leading-6 font-medium text-gray-900">
                Account #{{ $virtualAccount->account_number }}
            </h3>
            <p class="mt-1 max-w-2xl text-sm text-gray-500">
                {{ $virtualAccount->bank_name }}
            </p>
        </div>
        <div class="border-t border-gray-200">
            <dl>
                <div class="bg-gray-50 px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                    <dt class="text-sm font-medium text-gray-500">Account Name</dt>
                    <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                        {{ $virtualAccount->account_name }}
                    </dd>
                </div>
                <div class="bg-white px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                    <dt class="text-sm font-medium text-gray-500">Assigned User</dt>
                    <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                        @if($virtualAccount->user)
                            <a href="{{ route('users.show', $virtualAccount->user_id) }}" class="text-blue-600 hover:underline">
                                {{ $virtualAccount->user->name }}
                            </a>
                        @else
                            <span class="text-gray-400">Unassigned</span>
                        @endif
                    </dd>
                </div>
                <div class="bg-gray-50 px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                    <dt class="text-sm font-medium text-gray-500">Currency</dt>
                    <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                        {{ $virtualAccount->currency }}
                    </dd>
                </div>
                <div class="bg-white px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                    <dt class="text-sm font-medium text-gray-500">Reference</dt>
                    <dd class="mt-1 text-sm font-mono text-gray-900 sm:mt-0 sm:col-span-2">
                        {{ $virtualAccount->reference ?? 'N/A' }}
                    </dd>
                </div>
                 <div class="bg-gray-50 px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                    <dt class="text-sm font-medium text-gray-500">Created At</dt>
                    <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                        {{ $virtualAccount->created_at->format('F d, Y h:i A') }}
                    </dd>
                </div>
            </dl>
        </div>
        <div class="px-4 py-3 bg-gray-50 text-right sm:px-6">
            <button onclick="history.back()" class="inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-gray-600 hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500">
                Back
            </button>
        </div>
    </div>
</div>
@endsection
