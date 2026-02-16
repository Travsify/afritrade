<?php
// backend/admin/dashboard.php
require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/../config/db.php';

// Check for database connection error
if (!isDbConnected()) {
    echo '<div class="bg-red-500/20 border border-red-500 rounded-2xl p-6 text-center mb-8">';
    echo '<h2 class="text-xl font-bold text-red-400 mb-2">⚠️ Database Connection Error</h2>';
    echo '<p class="text-red-300">Unable to connect to the database. Please check your <code class="bg-red-500/30 px-2 py-1 rounded">config/db.php</code> file and ensure the password is set correctly.</p>';
    if (isset($db_error)) {
        echo '<p class="text-red-400 mt-3 text-sm font-mono">' . htmlspecialchars($db_error) . '</p>';
    }
    echo '</div>';
}

// Fetch stats
$totalUsers = 0;
$totalTransactions = 0;
$totalVolume = 0;
$pendingTransactions = 0;

try {
    if (isDbConnected()) {
        $stmt = $pdo->query("SELECT COUNT(*) FROM users");
        $totalUsers = $stmt->fetchColumn();
        $stmt = $pdo->query("SELECT COUNT(*) FROM transactions");
        $totalTransactions = $stmt->fetchColumn();
        $stmt = $pdo->query("SELECT COALESCE(SUM(amount), 0) FROM transactions WHERE status = 'completed'");
        $totalVolume = $stmt->fetchColumn();
        $stmt = $pdo->query("SELECT COUNT(*) FROM transactions WHERE status = 'pending'");
        $pendingTransactions = $stmt->fetchColumn();
    }
} catch (PDOException $e) {}

// Fetch recent transactions
$recentTransactions = [];
try {
    $stmt = $pdo->query("SELECT t.*, u.name as username FROM transactions t LEFT JOIN users u ON t.user_id = u.id ORDER BY t.created_at DESC LIMIT 10");
    $recentTransactions = $stmt->fetchAll();
} catch (PDOException $e) {}
?>

<!-- Header -->
<div class="flex justify-between items-center mb-8">
    <div>
        <h1 class="text-3xl font-bold text-white">Dashboard</h1>
        <p class="text-slate-400">Welcome back, <?php echo htmlspecialchars($_SESSION['admin_name'] ?? 'Admin'); ?></p>
    </div>
</div>

<!-- Stats -->
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
    <div class="bg-gradient-to-br from-blue-500 to-blue-600 rounded-2xl p-6 shadow-lg shadow-blue-500/20">
        <div>
             <p class="text-blue-100 text-sm">Total Users</p>
             <h3 class="text-3xl font-bold text-white mt-1"><?php echo number_format($totalUsers); ?></h3>
        </div>
    </div>
    <div class="bg-gradient-to-br from-emerald-500 to-emerald-600 rounded-2xl p-6 shadow-lg shadow-emerald-500/20">
        <div>
             <p class="text-emerald-100 text-sm">Total Volume</p>
             <h3 class="text-3xl font-bold text-white mt-1">$<?php echo number_format($totalVolume, 2); ?></h3>
        </div>
    </div>
    <div class="bg-gradient-to-br from-purple-500 to-purple-600 rounded-2xl p-6 shadow-lg shadow-purple-500/20">
        <div>
             <p class="text-purple-100 text-sm">Total Transactions</p>
             <h3 class="text-3xl font-bold text-white mt-1"><?php echo number_format($totalTransactions); ?></h3>
        </div>
    </div>
    <div class="bg-gradient-to-br from-amber-500 to-amber-600 rounded-2xl p-6 shadow-lg shadow-amber-500/20">
        <div>
             <p class="text-amber-100 text-sm">Pending</p>
             <h3 class="text-3xl font-bold text-white mt-1"><?php echo number_format($pendingTransactions); ?></h3>
        </div>
    </div>
</div>

<!-- Chart & List -->
<div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
    <!-- Chart -->
    <div class="lg:col-span-2 bg-slate-800 rounded-2xl p-6 border border-slate-700">
        <h3 class="text-lg font-semibold text-white mb-4">Transaction Volume</h3>
        <canvas id="volumeChart" height="120"></canvas>
    </div>

    <!-- Recent -->
    <div class="bg-slate-800 rounded-2xl p-6 border border-slate-700">
        <h3 class="text-lg font-semibold text-white mb-4">Recent Transactions</h3>
        <div class="space-y-4">
            <?php if (empty($recentTransactions)): ?>
                <p class="text-slate-500 text-center py-8">No transactions yet</p>
            <?php else: ?>
                <?php foreach (array_slice($recentTransactions, 0, 5) as $tx): ?>
                    <div class="flex items-center gap-4">
                         <div class="w-10 h-10 rounded-full flex items-center justify-center <?php echo $tx['status'] === 'completed' ? 'bg-emerald-500/20' : 'bg-amber-500/20'; ?>">
                             <span class="text-xs <?php echo $tx['status'] === 'completed' ? 'text-emerald-500' : 'text-amber-500'; ?>">$</span>
                         </div>
                         <div class="flex-1">
                             <p class="text-white text-sm font-medium"><?php echo htmlspecialchars($tx['recipient']); ?></p>
                             <p class="text-slate-500 text-xs"><?php echo htmlspecialchars($tx['username'] ?? 'Unknown'); ?></p>
                         </div>
                         <div class="text-right">
                             <p class="text-white font-semibold">$<?php echo number_format($tx['amount'], 2); ?></p>
                             <p class="text-xs <?php echo $tx['status'] === 'completed' ? 'text-emerald-400' : 'text-amber-400'; ?>"><?php echo ucfirst($tx['status']); ?></p>
                         </div>
                    </div>
                <?php endforeach; ?>
            <?php endif; ?>
        </div>
    </div>
</div>

<script>
    const ctx = document.getElementById('volumeChart').getContext('2d');
    new Chart(ctx, {
        type: 'line',
        data: {
            labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
            datasets: [{ label: 'Volume ($)', data: [12000, 19000, 15000, 25000, 22000, 30000], borderColor: '#10b981', backgroundColor: 'rgba(16, 185, 129, 0.1)', tension: 0.4, fill: true }]
        },
        options: { responsive: true, plugins: { legend: { display: false } }, scales: { y: { grid: { color: 'rgba(255,255,255,0.05)' }, ticks: { color: '#94a3b8' } }, x: { grid: { display: false }, ticks: { color: '#94a3b8' } } } }
    });
</script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>