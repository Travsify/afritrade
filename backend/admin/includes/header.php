<?php
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}
if (!isset($_SESSION['admin_logged_in']) || $_SESSION['admin_logged_in'] !== true) {
    header('Location: login.php');
    exit;
}
$currentPage = basename($_SERVER['PHP_SELF']);
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Afritrad Admin</title>
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- Charts -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <style>
        /* CRITICAL FALLBACK CSS - Ensures layout works even if Tailwind fails */
        body {
            margin: 0;
            font-family: 'Outfit', sans-serif;
            background-color: #0f172a;
            color: white;
        }

        .flex {
            display: flex;
        }

        .fixed {
            position: fixed;
        }

        .min-h-screen {
            min-height: 100vh;
        }

        .w-64 {
            width: 16rem;
        }

        .ml-64 {
            margin-left: 16rem;
        }

        .flex-1 {
            flex: 1;
        }

        .p-6 {
            padding: 1.5rem;
        }

        .p-8 {
            padding: 2rem;
        }

        .gap-3 {
            gap: 0.75rem;
        }

        .bg-slate-800 {
            background-color: #1e293b;
        }

        .bg-slate-900 {
            background-color: #0f172a;
        }

        .text-white {
            color: white;
        }
    </style>
</head>

<body class="bg-slate-900 min-h-screen">
    <div class="flex">
        <!-- Sidebar -->
        <aside class="w-64 bg-slate-800 min-h-screen p-6 border-r border-slate-700 fixed z-10"
            style="border-right: 1px solid #334155;">
            <div class="flex items-center gap-3 mb-10">
                <div class="w-10 h-10 bg-emerald-500 rounded-xl flex items-center justify-center">
                    <span class="text-white font-bold text-lg">A</span>
                </div>
                <span class="text-white font-bold text-xl">Afritrad</span>
            </div>

            <nav class="space-y-2">
                <?php
                $navItems = [
                    'dashboard.php' => 'Dashboard',
                    'users.php' => 'Users',
                    'transactions.php' => 'Transactions',
                    'cards.php' => 'Virtual Cards',
                    'kyc.php' => 'KYC',
                    'support.php' => 'Support',
                    'referrals.php' => 'Referrals',
                    'cms.php' => 'CMS',
                    'audit.php' => 'Audit Logs',
                    'manage_admins.php' => 'Manage Admins',
                    'settings.php' => 'Settings'
                ];

                foreach ($navItems as $file => $label) {
                    $active = ($currentPage === $file);
                    $bgClass = $active ? 'bg-slate-700/50 text-white' : 'text-slate-400 hover:text-white hover:bg-slate-700/30';
                    echo "<a href='$file' class='flex items-center gap-3 px-4 py-3 rounded-xl transition $bgClass' style='display:flex; align-items:center; text-decoration:none;'>$label</a>";
                }
                ?>
            </nav>

            <div class="absolute bottom-6 left-6 right-6"
                style="position:absolute; bottom:1.5rem; left:1.5rem; right:1.5rem;">
                <a href="logout.php"
                    class="flex items-center gap-3 text-red-400 hover:text-red-300 px-4 py-3 rounded-xl transition">
                    Logout
                </a>
            </div>
        </aside>

        <!-- Main Content Wrapper -->
        <main class="ml-64 flex-1 p-8">