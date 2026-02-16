<?php
// backend/admin/audit.php
require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/../config/db.php';

$logs = [];
try {
    $stmt = $pdo->query("SELECT l.*, a.name as admin_name FROM audit_logs l LEFT JOIN admins a ON l.admin_id = a.id ORDER BY l.created_at DESC LIMIT 100");
    $logs = $stmt->fetchAll();
} catch (Exception $e) {
}
?>

<!-- Header -->
<div class="flex justify-between items-center mb-8">
    <div>
        <h1 class="text-3xl font-bold text-white">System Audit Logs</h1>
        <p class="text-slate-400">Activity and Security Monitoring</p>
    </div>
</div>

<!-- Table -->
<div class="bg-slate-800 rounded-2xl border border-slate-700 overflow-hidden">
    <table class="w-full text-left border-collapse">
        <thead class="bg-slate-700/50">
            <tr>
                <th class="p-4 text-slate-400 font-medium">Admin</th>
                <th class="p-4 text-slate-400 font-medium">Action</th>
                <th class="p-4 text-slate-400 font-medium">Details</th>
                <th class="p-4 text-slate-400 font-medium">IP</th>
                <th class="p-4 text-slate-400 font-medium">Time</th>
            </tr>
        </thead>
        <tbody class="divide-y divide-slate-700">
            <?php if (empty($logs)): ?>
                <tr>
                    <td colspan="5" class="p-8 text-center text-slate-500">No logs found.</td>
                </tr>
            <?php else: ?>
                <?php foreach ($logs as $log): ?>
                    <tr class="hover:bg-slate-700/30 transition">
                        <td class="p-4 text-white">
                            <?= htmlspecialchars($log['admin_name']) ?>
                        </td>
                        <td class="p-4 text-emerald-400 font-medium">
                            <?= htmlspecialchars($log['action']) ?>
                        </td>
                        <td class="p-4 text-slate-400 text-sm">
                            <?= htmlspecialchars($log['details']) ?>
                        </td>
                        <td class="p-4 text-slate-500 font-mono text-xs">
                            <?= htmlspecialchars($log['ip_address']) ?>
                        </td>
                        <td class="p-4 text-slate-500 text-xs">
                            <?= $log['created_at'] ?>
                        </td>
                    </tr>
                <?php endforeach; ?>
            <?php endif; ?>
        </tbody>
    </table>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>