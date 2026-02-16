<?php
// backend/admin/settings.php
require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/../config/db.php';

// Fetch current settings
$settings = [];
if (isset($pdo)) {
    try {
        $stmt = $pdo->query("SELECT setting_key, setting_value FROM system_settings");
        while ($row = $stmt->fetch()) {
            $settings[$row['setting_key']] = $row['setting_value'];
        }
    } catch (PDOException $e) {
        // Table might not exist or connection failed
    }
}

$anchorKey = $settings['anchor_api_key'] ?? '';
$anchorUrl = $settings['anchor_base_url'] ?? 'https://api.getanchor.co/api/v1';
$ycKey = $settings['yellowcard_api_key'] ?? '';
$ycUrl = $settings['yellowcard_base_url'] ?? 'https://api.yellowcard.io';
$exchangeRate = $settings['exchange_rate'] ?? 1450.00;
$maintenanceMode = ($settings['maintenance_mode'] ?? '0') === '1';

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($pdo)) {
    $data = [
        'anchor_api_key' => $_POST['anchor_api_key'] ?? '',
        'anchor_base_url' => $_POST['anchor_base_url'] ?? '',
        'yellowcard_api_key' => $_POST['yellowcard_api_key'] ?? '',
        'yellowcard_base_url' => $_POST['yellowcard_base_url'] ?? '',
        'exchange_rate' => $_POST['rate'] ?? 1450.00,
        'maintenance_mode' => isset($_POST['maintenance']) ? '1' : '0'
    ];

    try {
        $stmt = $pdo->prepare("INSERT INTO system_settings (setting_key, setting_value, created_at, updated_at) VALUES (?, ?, NOW(), NOW()) ON DUPLICATE KEY UPDATE setting_value = ?, updated_at = NOW()");
        
        foreach ($data as $key => $value) {
            $stmt->execute([$key, $value, $value]);
        }
        
        // Refresh variables
        $anchorKey = $data['anchor_api_key'];
        $anchorUrl = $data['anchor_base_url'];
        $ycKey = $data['yellowcard_api_key'];
        $ycUrl = $data['yellowcard_base_url'];
        $exchangeRate = $data['exchange_rate'];
        $maintenanceMode = $data['maintenance_mode'] === '1';

        $success = "Settings updated successfully";
    } catch (PDOException $e) {
        $error = "Database Error: " . $e->getMessage();
    }
}
?>

<!-- Header -->
<div class="flex justify-between items-center mb-8">
    <div>
        <h1 class="text-3xl font-bold text-white">System Settings</h1>
        <p class="text-slate-400">Configure Global Parameters & API Keys</p>
    </div>
</div>

<?php if (isset($success)) echo "<div class='bg-emerald-500/20 text-emerald-400 p-4 rounded-xl mb-6 border border-emerald-500/20'>$success</div>"; ?>
<?php if (isset($error)) echo "<div class='bg-red-500/20 text-red-400 p-4 rounded-xl mb-6 border border-red-500/20'>$error</div>"; ?>

<form method="POST" class="grid grid-cols-1 lg:grid-cols-2 gap-8">
    
    <!-- General Settings -->
    <div class="bg-slate-800 rounded-2xl p-6 border border-slate-700 h-fit">
        <h3 class="text-white font-bold text-xl mb-6">General Configuration</h3>
        
        <div class="mb-6">
            <label class="block text-slate-400 mb-2 text-sm uppercase tracking-wider font-semibold">Global Exchange Rate (USD/NGN)</label>
            <div class="relative">
                <span class="absolute left-4 top-3 text-slate-500">₦</span>
                <input type="number" step="0.01" name="rate" value="<?= htmlspecialchars($exchangeRate) ?>"
                    class="w-full bg-slate-700 border border-slate-600 rounded-xl p-3 pl-8 text-white focus:outline-none focus:border-emerald-500 transition font-mono text-lg">
            </div>
            <p class="text-xs text-slate-500 mt-2">Used for all currency conversions in the app.</p>
        </div>

        <div class="mb-8 p-4 bg-slate-700/30 rounded-xl border border-slate-700">
            <div class="flex items-center justify-between">
                <div>
                    <label class="text-white font-bold block">Maintenance Mode</label>
                    <p class="text-slate-400 text-sm">Disable access for non-admin users</p>
                </div>
                <label class="relative inline-flex items-center cursor-pointer">
                    <input type="checkbox" name="maintenance" class="sr-only peer" <?= $maintenanceMode ? 'checked' : '' ?>>
                    <div class="w-11 h-6 bg-slate-600 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-emerald-500"></div>
                </label>
            </div>
        </div>
    </div>

    <!-- API Configuration -->
    <div class="bg-slate-800 rounded-2xl p-6 border border-slate-700 h-fit">
        <h3 class="text-white font-bold text-xl mb-6">API Integration Keys</h3>
        
        <!-- Anchor API -->
        <div class="mb-6 p-4 rounded-xl bg-slate-900/50 border border-slate-600">
            <h4 class="text-emerald-400 font-bold mb-4 flex items-center gap-2">
                <span class="w-2 h-2 rounded-full bg-emerald-400"></span> Anchor Banking (Virtual Accounts)
            </h4>
            
            <div class="mb-4">
                <label class="block text-slate-400 mb-2 text-xs">Anchor Base URL</label>
                <input type="text" name="anchor_base_url" value="<?= htmlspecialchars($anchorUrl) ?>"
                    class="w-full bg-slate-800 border border-slate-600 rounded-lg p-3 text-sm text-white focus:outline-none focus:border-emerald-500">
            </div>
            
            <div class="mb-2">
                <label class="block text-slate-400 mb-2 text-xs">Live API Key</label>
                <input type="password" name="anchor_api_key" value="<?= htmlspecialchars($anchorKey) ?>" placeholder="sk_live_..."
                    class="w-full bg-slate-800 border border-slate-600 rounded-lg p-3 text-sm text-white focus:outline-none focus:border-emerald-500 font-mono">
            </div>
        </div>

        <!-- Yellow Card API -->
        <div class="mb-6 p-4 rounded-xl bg-slate-900/50 border border-slate-600">
            <h4 class="text-yellow-400 font-bold mb-4 flex items-center gap-2">
                <span class="w-2 h-2 rounded-full bg-yellow-400"></span> Yellow Card (Crypto/Stablecoins)
            </h4>
            
            <div class="mb-4">
                <label class="block text-slate-400 mb-2 text-xs">Yellow Card Base URL</label>
                <input type="text" name="yellowcard_base_url" value="<?= htmlspecialchars($ycUrl) ?>"
                    class="w-full bg-slate-800 border border-slate-600 rounded-lg p-3 text-sm text-white focus:outline-none focus:border-yellow-500">
            </div>
            
            <div class="mb-2">
                <label class="block text-slate-400 mb-2 text-xs">API Key</label>
                <input type="password" name="yellowcard_api_key" value="<?= htmlspecialchars($ycKey) ?>" placeholder="yc_..."
                    class="w-full bg-slate-800 border border-slate-600 rounded-lg p-3 text-sm text-white focus:outline-none focus:border-yellow-500 font-mono">
            </div>
        </div>

        <button class="w-full bg-emerald-500 hover:bg-emerald-600 text-white px-6 py-4 rounded-xl font-bold transition shadow-lg shadow-emerald-500/20">
            Save All Configurations
        </button>
    </div>

</form>

    <!-- Info Panel -->
    <div class="space-y-6">
        <div class="bg-blue-500/10 rounded-2xl p-6 border border-blue-500/20">
            <h3 class="text-blue-400 font-bold text-lg mb-2">System Status</h3>
            <div class="space-y-2">
                <div class="flex justify-between text-sm">
                    <span class="text-slate-400">PHP Version</span>
                    <span class="text-white font-mono"><?= phpversion() ?></span>
                </div>
                <div class="flex justify-between text-sm">
                    <span class="text-slate-400">Server Time</span>
                    <span class="text-white font-mono"><?= date('Y-m-d H:i:s') ?></span>
                </div>
                <div class="flex justify-between text-sm">
                    <span class="text-slate-400">Database</span>
                    <span class="text-emerald-400 font-medium">Connected</span>
                </div>
            </div>
        </div>
    </div>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>