@extends('layouts.admin')

@section('header', 'Service Settings')

@section('content')
<div class="max-w-3xl mx-auto">
    <div class="bg-white shadow overflow-hidden sm:rounded-lg mb-6">
        <div class="px-4 py-5 sm:px-6">
            <h3 class="text-lg leading-6 font-medium text-gray-900">
                Service Provider Management
            </h3>
            <p class="mt-1 max-w-2xl text-sm text-gray-500">
                Toggle availability of bill payment services.
            </p>
        </div>
        <div class="border-t border-gray-200 p-6">
            <div class="grid grid-cols-1 gap-6">
                <!-- Example Service Toggles -->
                <div class="flex items-center justify-between py-3 border-b">
                     <div>
                         <span class="font-medium text-gray-800">Mobile Data (MTN)</span>
                         <p class="text-xs text-gray-500">Provider: SystemSpecs</p>
                     </div>
                     <label class="switch">
                         <input type="checkbox" checked>
                         <span class="slider round"></span>
                     </label>
                </div>
                <div class="flex items-center justify-between py-3 border-b">
                     <div>
                         <span class="font-medium text-gray-800">Airtime Topup</span>
                         <p class="text-xs text-gray-500">Provider: SystemSpecs</p>
                     </div>
                     <label class="switch">
                         <input type="checkbox" checked>
                         <span class="slider round"></span>
                     </label>
                </div>
                 <div class="flex items-center justify-between py-3 border-b">
                     <div>
                         <span class="font-medium text-gray-800">Cable TV (DSTV/GOTV)</span>
                         <p class="text-xs text-gray-500">Provider: Reloadly</p>
                     </div>
                     <label class="switch">
                         <input type="checkbox" checked>
                         <span class="slider round"></span>
                     </label>
                </div>
            </div>
            <div class="mt-6 text-right">
                <button class="bg-blue-600 text-white px-4 py-2 rounded text-sm hover:bg-blue-700">Save Changes</button>
            </div>
        </div>
    </div>
</div>

<style>
/* Basic Switch CSS */
.switch { position: relative; display: inline-block; width: 44px; height: 24px; }
.switch input { opacity: 0; width: 0; height: 0; }
.slider { position: absolute; cursor: pointer; top: 0; left: 0; right: 0; bottom: 0; background-color: #ccc; -webkit-transition: .4s; transition: .4s; border-radius: 24px; }
.slider:before { position: absolute; content: ""; height: 18px; width: 18px; left: 3px; bottom: 3px; background-color: white; -webkit-transition: .4s; transition: .4s; border-radius: 50%; }
input:checked + .slider { background-color: #2196F3; }
input:focus + .slider { box-shadow: 0 0 1px #2196F3; }
input:checked + .slider:before { -webkit-transform: translateX(20px); -ms-transform: translateX(20px); transform: translateX(20px); }
</style>
@endsection
