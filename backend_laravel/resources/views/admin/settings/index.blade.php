@extends('layouts.admin')

@section('header', 'System Settings')

@section('content')
    <div class="bg-white rounded-lg shadow p-6">
        
        @if(session('success'))
            <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative mb-4">
                {{ session('success') }}
            </div>
        @endif

        <form action="{{ route('admin.settings.update') }}" method="POST">
            @csrf
            
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <!-- General Settings -->
                <div>
                    <h3 class="text-lg font-medium text-gray-900 mb-4">General Configuration</h3>
                    
                    <div class="mb-4">
                        <label class="block text-gray-700 text-sm font-bold mb-2">Exchange Rate (USD to NGN)</label>
                        <input type="number" step="0.01" name="exchange_rate_usd_ngn" 
                            value="{{ $settings['exchange_rate_usd_ngn'] ?? '1450.00' }}"
                            class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500">
                    </div>

                    <div class="mb-4">
                        <label class="block text-gray-700 text-sm font-bold mb-2">Maintenance Mode</label>
                        <select name="maintenance_mode" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500">
                            <option value="0" {{ ($settings['maintenance_mode'] ?? '0') == '0' ? 'selected' : '' }}>Off</option>
                            <option value="1" {{ ($settings['maintenance_mode'] ?? '0') == '1' ? 'selected' : '' }}>On</option>
                        </select>
                    </div>
                </div>

            <!-- API Keys -->
                <div>
                    <h3 class="text-lg font-medium text-gray-900 mb-4">API Configuration</h3>
                    
                    <div class="mb-4">
                        <label class="block text-gray-700 text-sm font-bold mb-2">OpenAI API Key</label>
                        <input type="password" name="openai_api_key" 
                            value="{{ $settings['openai_api_key'] ?? '' }}"
                            class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500">
                    </div>

                    <div class="mb-4">
                        <label class="block text-gray-700 text-sm font-bold mb-2">Anchor Base URL</label>
                        <input type="url" name="anchor_base_url" 
                            value="{{ $settings['anchor_base_url'] ?? 'https://api.anchor.com' }}"
                            class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500">
                    </div>
                </div>

                <!-- Mobile App Configuration -->
                <div class="col-span-1 md:col-span-2 border-t pt-6 mt-2">
                    <h3 class="text-lg font-medium text-gray-900 mb-4">Mobile App Control</h3>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div>
                            <div class="mb-4">
                                <label class="block text-gray-700 text-sm font-bold mb-2">Min Android Version (e.g. 1.0.0)</label>
                                <input type="text" name="min_android_version" 
                                    value="{{ $settings['min_android_version'] ?? '1.0.0' }}"
                                    class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500">
                            </div>
                            <div class="mb-4">
                                <label class="block text-gray-700 text-sm font-bold mb-2">Min iOS Version (e.g. 1.0.0)</label>
                                <input type="text" name="min_ios_version" 
                                    value="{{ $settings['min_ios_version'] ?? '1.0.0' }}"
                                    class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500">
                            </div>
                            <div class="mb-4">
                                <label class="block text-gray-700 text-sm font-bold mb-2">Force Update</label>
                                <select name="force_update" class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500">
                                    <option value="0" {{ ($settings['force_update'] ?? '0') == '0' ? 'selected' : '' }}>No</option>
                                    <option value="1" {{ ($settings['force_update'] ?? '0') == '1' ? 'selected' : '' }}>Yes</option>
                                </select>
                            </div>
                        </div>
                        <div>
                            <div class="mb-4">
                                <label class="block text-gray-700 text-sm font-bold mb-2">Play Store URL</label>
                                <input type="url" name="play_store_url" 
                                    value="{{ $settings['play_store_url'] ?? '' }}"
                                    class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500">
                            </div>
                            <div class="mb-4">
                                <label class="block text-gray-700 text-sm font-bold mb-2">App Store URL</label>
                                <input type="url" name="app_store_url" 
                                    value="{{ $settings['app_store_url'] ?? '' }}"
                                    class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500">
                            </div>
                            <div class="mb-4">
                                <label class="block text-gray-700 text-sm font-bold mb-2">Support Email</label>
                                <input type="email" name="support_email" 
                                    value="{{ $settings['support_email'] ?? '' }}"
                                    class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500">
                            </div>
                        </div>
                         <div class="col-span-1 md:col-span-2">
                             <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                                <div class="mb-4">
                                    <label class="block text-gray-700 text-sm font-bold mb-2">Privacy Policy URL</label>
                                    <input type="url" name="privacy_policy_url" 
                                        value="{{ $settings['privacy_policy_url'] ?? '' }}"
                                        class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500">
                                </div>
                                <div class="mb-4">
                                    <label class="block text-gray-700 text-sm font-bold mb-2">Terms of Service URL</label>
                                    <input type="url" name="terms_of_service_url" 
                                        value="{{ $settings['terms_of_service_url'] ?? '' }}"
                                        class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500">
                                </div>
                             </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="mt-6">
                <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">
                    Save Changes
                </button>
            </div>
        </form>
    </div>
@endsection
