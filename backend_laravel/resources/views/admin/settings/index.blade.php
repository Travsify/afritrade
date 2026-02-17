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

                <!-- API Configuration -->
                <div class="col-span-1 md:col-span-2 mt-6">
                    <h3 class="text-xl font-bold text-gray-900 mb-6 border-b pb-2">Centralized Fintech Providers</h3>
                    
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
                        <!-- Fincra -->
                        <div class="bg-gray-50 p-4 rounded-lg border">
                            <h4 class="font-bold text-blue-600 mb-4 border-b pb-1">Fincra (Accounts & Bills)</h4>
                            <div class="mb-4">
                                <label class="block text-gray-700 text-xs font-bold mb-1">API Key</label>
                                <input type="password" name="fincra_api_key" value="{{ $settings['fincra_api_key'] ?? '' }}" class="w-full px-3 py-1 text-sm border rounded">
                            </div>
                            <div class="mb-4">
                                <label class="block text-gray-700 text-xs font-bold mb-1">Merchant ID</label>
                                <input type="text" name="fincra_merchant_id" value="{{ $settings['fincra_merchant_id'] ?? '' }}" class="w-full px-3 py-1 text-sm border rounded">
                            </div>
                            <div class="mb-4">
                                <label class="block text-gray-700 text-xs font-bold mb-1">Base URL</label>
                                <input type="text" name="fincra_base_url" value="{{ $settings['fincra_base_url'] ?? 'https://api.fincra.com' }}" class="w-full px-3 py-1 text-sm border rounded">
                            </div>
                        </div>

                        <!-- Maplerad -->
                        <div class="bg-gray-50 p-4 rounded-lg border">
                            <h4 class="font-bold text-purple-600 mb-4 border-b pb-1">Maplerad (Cards)</h4>
                            <div class="mb-4">
                                <label class="block text-gray-700 text-xs font-bold mb-1">Secret Key</label>
                                <input type="password" name="maplerad_secret_key" value="{{ $settings['maplerad_secret_key'] ?? '' }}" class="w-full px-3 py-1 text-sm border rounded">
                            </div>
                            <div class="mb-4">
                                <label class="block text-gray-700 text-xs font-bold mb-1">Base URL</label>
                                <input type="text" name="maplerad_base_url" value="{{ $settings['maplerad_base_url'] ?? 'https://api.maplerad.com/v1' }}" class="w-full px-3 py-1 text-sm border rounded">
                            </div>
                        </div>

                        <!-- Klasha -->
                        <div class="bg-gray-50 p-4 rounded-lg border">
                            <h4 class="font-bold text-red-600 mb-4 border-b pb-1">Klasha (China/Global)</h4>
                            <div class="mb-4">
                                <label class="block text-gray-700 text-xs font-bold mb-1">API Key</label>
                                <input type="password" name="klasha_api_key" value="{{ $settings['klasha_api_key'] ?? '' }}" class="w-full px-3 py-1 text-sm border rounded">
                            </div>
                            <div class="mb-4">
                                <label class="block text-gray-700 text-xs font-bold mb-1">Base URL</label>
                                <input type="text" name="klasha_base_url" value="{{ $settings['klasha_base_url'] ?? 'https://api.klasha.com' }}" class="w-full px-3 py-1 text-sm border rounded">
                            </div>
                        </div>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-8 mt-6">
                         <!-- Anchor (Legacy/Fallback) -->
                         <div class="bg-gray-50 p-4 rounded-lg border">
                            <h4 class="font-bold text-gray-600 mb-4 border-b pb-1">Anchor (Legacy)</h4>
                            <div class="mb-4">
                                <label class="block text-gray-700 text-xs font-bold mb-1">API Key</label>
                                <input type="password" name="anchor_api_key" value="{{ $settings['anchor_api_key'] ?? '' }}" class="w-full px-3 py-1 text-sm border rounded">
                            </div>
                            <div class="mb-4">
                                <label class="block text-gray-700 text-xs font-bold mb-1">Base URL</label>
                                <input type="text" name="anchor_base_url" value="{{ $settings['anchor_base_url'] ?? 'https://api.getanchor.co/api/v1' }}" class="w-full px-3 py-1 text-sm border rounded">
                            </div>
                        </div>

                         <!-- Active Providers Selection -->
                         <div class="bg-blue-50 p-4 rounded-lg border border-blue-200">
                            <h4 class="font-bold text-blue-800 mb-4 border-b pb-1 border-blue-200">Active Service Providers</h4>
                            <div class="grid grid-cols-2 gap-4">
                                <div>
                                    <label class="block text-gray-700 text-xs font-bold mb-1">Virtual Accounts</label>
                                    <select name="active_va_provider" class="w-full px-3 py-1 text-sm border rounded">
                                        <option value="fincra" {{ ($settings['active_va_provider'] ?? 'fincra') == 'fincra' ? 'selected' : '' }}>Fincra (Preferred)</option>
                                        <option value="anchor" {{ ($settings['active_va_provider'] ?? '') == 'anchor' ? 'selected' : '' }}>Anchor (Legacy)</option>
                                    </select>
                                </div>
                                <div>
                                    <label class="block text-gray-700 text-xs font-bold mb-1">Virtual Cards</label>
                                    <select name="active_card_provider" class="w-full px-3 py-1 text-sm border rounded">
                                        <option value="maplerad" {{ ($settings['active_card_provider'] ?? 'maplerad') == 'maplerad' ? 'selected' : '' }}>Maplerad (Preferred)</option>
                                        <option value="anchor" {{ ($settings['active_card_provider'] ?? '') == 'anchor' ? 'selected' : '' }}>Anchor (Legacy)</option>
                                    </select>
                                </div>
                                <div>
                                    <label class="block text-gray-700 text-xs font-bold mb-1">Bill Payments</label>
                                    <select name="active_bills_provider" class="w-full px-3 py-1 text-sm border rounded">
                                        <option value="fincra" {{ ($settings['active_bills_provider'] ?? 'fincra') == 'fincra' ? 'selected' : '' }}>Fincra</option>
                                    </select>
                                </div>
                                <div>
                                    <label class="block text-gray-700 text-xs font-bold mb-1">China/FX Wire</label>
                                    <select name="active_payout_provider" class="w-full px-3 py-1 text-sm border rounded">
                                        <option value="klasha" {{ ($settings['active_payout_provider'] ?? 'klasha') == 'klasha' ? 'selected' : '' }}>Klasha</option>
                                    </select>
                                </div>
                            </div>
                        </div>
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
