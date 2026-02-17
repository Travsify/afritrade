<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Admin - {{ config('app.name', 'Afritrad') }}</title>

    <!-- Tailwind CSS (via CDN for simplicity if build process fails) -->
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/alpinejs" defer></script>
</head>
<body class="bg-gray-100 font-sans leading-normal tracking-normal">

    <div class="flex h-screen overflow-hidden">
        <!-- Sidebar -->
        <div class="w-64 bg-gray-800 text-white flex-shrink-0 hidden md:flex flex-col">
            <div class="p-4 flex items-center justify-center h-16 border-b border-gray-700">
                <span class="text-xl font-bold">Afritrad Admin</span>
            </div>
            <nav class="flex-1 overflow-y-auto py-4">
                <a href="{{ route('admin.dashboard') }}" class="block px-4 py-2 hover:bg-gray-700 {{ request()->routeIs('admin.dashboard') ? 'bg-gray-900' : '' }}">
                    Dashboard
                </a>
                <a href="{{ route('admin.users.index') }}" class="block px-4 py-2 hover:bg-gray-700 {{ request()->routeIs('admin.users.*') ? 'bg-gray-900' : '' }}">
                    Users
                </a>
                <a href="{{ route('admin.transactions.index') }}" class="block px-4 py-2 hover:bg-gray-700 {{ request()->routeIs('admin.transactions.*') ? 'bg-gray-900' : '' }}">
                    Transactions
                </a>
                <a href="{{ route('admin.kyc.index') }}" class="block px-4 py-2 hover:bg-gray-700 {{ request()->routeIs('admin.kyc.*') ? 'bg-gray-900' : '' }}">
                    KYC
                </a>
                <a href="{{ route('admin.referrals.index') }}" class="block px-4 py-2 hover:bg-gray-700 {{ request()->routeIs('admin.referrals.*') ? 'bg-gray-900' : '' }}">
                    Referrals
                </a>
                <a href="{{ route('admin.chat.index') }}" class="block px-4 py-2 hover:bg-gray-700 {{ request()->routeIs('admin.chat.*') ? 'bg-gray-900' : '' }}">
                    Chat Support
                </a>
                <a href="{{ route('admin.virtual-accounts.index') }}" class="block px-4 py-2 hover:bg-gray-700 {{ request()->routeIs('admin.virtual-accounts.*') ? 'bg-gray-900' : '' }}">
                    Virtual Accounts
                </a>
                <a href="{{ route('admin.virtual-cards.index') }}" class="block px-4 py-2 hover:bg-gray-700 {{ request()->routeIs('admin.virtual-cards.*') ? 'bg-gray-900' : '' }}">
                    Virtual Cards
                </a>
                 <a href="{{ route('admin.swaps.index') }}" class="block px-4 py-2 hover:bg-gray-700 {{ request()->routeIs('admin.swaps.*') ? 'bg-gray-900' : '' }}">
                    Swaps
                </a>
                 <a href="{{ route('admin.bill-payments.index') }}" class="block px-4 py-2 hover:bg-gray-700 {{ request()->routeIs('admin.bill-payments.*') ? 'bg-gray-900' : '' }}">
                    Bill Payments
                </a>
                 <a href="{{ route('admin.exchange-rates.index') }}" class="block px-4 py-2 hover:bg-gray-700 {{ request()->routeIs('admin.exchange-rates.*') ? 'bg-gray-900' : '' }}">
                    Exchange Rates
                </a>
                <a href="{{ route('admin.audit.index') }}" class="block px-4 py-2 hover:bg-gray-700 {{ request()->routeIs('admin.audit.*') ? 'bg-gray-900' : '' }}">
                    Audit Logs
                </a>
                <a href="{{ route('admin.cms.index') }}" class="block px-4 py-2 hover:bg-gray-700 {{ request()->routeIs('admin.cms.*') ? 'bg-gray-900' : '' }}">
                    CMS
                </a>
                <a href="{{ route('admin.notifications.index') }}" class="block px-4 py-2 hover:bg-gray-700 {{ request()->routeIs('admin.notifications.*') ? 'bg-gray-900' : '' }}">
                    Notifications
                </a>
                <a href="{{ route('admin.settings.index') }}" class="block px-4 py-2 hover:bg-gray-700 {{ request()->routeIs('admin.settings.*') ? 'bg-gray-900' : '' }}">
                    Settings
                </a>
                <a href="{{ route('admin.admins.index') }}" class="block px-4 py-2 hover:bg-gray-700 {{ request()->routeIs('admin.admins.*') ? 'bg-gray-900' : '' }}">
                    Admins
                </a>
            </nav>
            <div class="p-4 border-t border-gray-700">
                <form action="{{ route('admin.logout') }}" method="POST">
                    @csrf
                    <button type="submit" class="w-full bg-red-600 hover:bg-red-700 text-white py-2 px-4 rounded">
                        Logout
                    </button>
                </form>
            </div>
        </div>

        <!-- Main Content -->
        <div class="flex-1 flex flex-col overflow-hidden">
            <!-- Header -->
            <header class="bg-white shadow">
                <div class="max-w-7xl mx-auto py-4 px-4 sm:px-6 lg:px-8 flex justify-between items-center">
                    <h1 class="text-2xl font-bold text-gray-900">
                        @yield('header', 'Dashboard')
                    </h1>
                    <div class="flex items-center">
                        <span class="text-gray-600 mr-4">Hello, {{ Auth::guard('admin')->user()->name ?? 'Admin' }}</span>
                    </div>
                </div>
            </header>

            <!-- Main -->
            <main class="flex-1 overflow-x-hidden overflow-y-auto bg-gray-200 p-6">
                @yield('content')
            </main>
        </div>
    </div>

</body>
</html>
