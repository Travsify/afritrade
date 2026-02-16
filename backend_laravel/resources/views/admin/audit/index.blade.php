@extends('layouts.admin')

@section('header', 'Audit Logs')

@section('content')
    <div class="bg-white rounded-lg shadow overflow-hidden">
        <div class="px-6 py-4 border-b border-gray-200">
            <h3 class="text-lg font-semibold text-gray-800">System Activity</h3>
        </div>
        
        <div class="overflow-x-auto">
            <table class="min-w-full leading-normal">
                <thead>
                    <tr>
                        <th class="px-5 py-3 border-b-2 border-gray-200 bg-gray-100 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">ID</th>
                        <th class="px-5 py-3 border-b-2 border-gray-200 bg-gray-100 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">User</th>
                        <th class="px-5 py-3 border-b-2 border-gray-200 bg-gray-100 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Action</th>
                        <th class="px-5 py-3 border-b-2 border-gray-200 bg-gray-100 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">IP Address</th>
                        <th class="px-5 py-3 border-b-2 border-gray-200 bg-gray-100 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Date</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($logs as $log)
                        <tr>
                            <td class="px-5 py-5 border-b border-gray-200 bg-white text-sm">{{ $log->id }}</td>
                            <td class="px-5 py-5 border-b border-gray-200 bg-white text-sm font-semibold">{{ $log->user->name ?? 'System/Unknown' }}</td>
                            <td class="px-5 py-5 border-b border-gray-200 bg-white text-sm">{{ $log->action }}</td>
                            <td class="px-5 py-5 border-b border-gray-200 bg-white text-sm text-gray-600">{{ $log->ip_address }}</td>
                            <td class="px-5 py-5 border-b border-gray-200 bg-white text-sm">{{ $log->created_at->format('M d, Y H:i:s') }}</td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
        
        <div class="px-5 py-5 bg-white border-t">
            {{ $logs->links() }}
        </div>
    </div>
@endsection
