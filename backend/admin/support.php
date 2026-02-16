<?php
// backend/admin/support.php
require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/../config/db.php';

// Fetch active support chats
$chats = [];
try {
    $stmt = $pdo->query("SELECT * FROM chat_sessions ORDER BY created_at DESC");
    $chats = $stmt->fetchAll();
} catch (Exception $e) {
}
?>

<!-- Header -->
<div class="flex justify-between items-center mb-8">
    <div>
        <h1 class="text-3xl font-bold text-white">Support Tickets</h1>
        <p class="text-slate-400">Manage User Support Sessions</p>
    </div>
</div>

<!-- Table -->
<div class="bg-slate-800 rounded-2xl border border-slate-700 overflow-hidden">
    <table class="w-full text-left border-collapse">
        <thead class="bg-slate-700/50">
            <tr>
                <th class="p-4 text-slate-400 font-medium">Session ID</th>
                <th class="p-4 text-slate-400 font-medium">User ID</th>
                <th class="p-4 text-slate-400 font-medium">Status</th>
                <th class="p-4 text-slate-400 font-medium">Started</th>
                <th class="p-4 text-slate-400 font-medium text-right">Action</th>
            </tr>
        </thead>
        <tbody class="divide-y divide-slate-700">
            <?php if (empty($chats)): ?>
                <tr>
                    <td colspan="5" class="p-8 text-center text-slate-500">No active support sessions.</td>
                </tr>
            <?php else: ?>
                <?php foreach ($chats as $chat): ?>
                    <tr class="hover:bg-slate-700/30 transition">
                        <td class="p-4 text-white font-mono text-sm">
                            <?= htmlspecialchars($chat['id']) ?>
                        </td>
                        <td class="p-4 text-slate-300">
                            <?= htmlspecialchars($chat['user_id']) ?>
                        </td>
                        <td class="p-4">
                            <span
                                class="px-2 py-1 rounded text-xs font-bold uppercase 
                                <?= $chat['status'] == 'human' ? 'bg-blue-500/20 text-blue-400' : ($chat['status'] == 'pending_human' ? 'bg-amber-500/20 text-amber-400' : 'bg-slate-500/20 text-slate-400') ?>">
                                <?= htmlspecialchars($chat['status']) ?>
                            </span>
                        </td>
                        <td class="p-4 text-slate-500 text-sm">
                            <?= $chat['created_at'] ?>
                        </td>
                        <td class="p-4 text-right">
                            <a href="chat_agent.php?id=<?= $chat['id'] ?>"
                                class="inline-block bg-emerald-500/10 hover:bg-emerald-500 text-emerald-400 hover:text-white px-3 py-1 rounded-lg text-xs font-bold transition border border-emerald-500/20">
                                Open Chat
                            </a>
                        </td>
                    </tr>
                <?php endforeach; ?>
            <?php endif; ?>
        </tbody>
    </table>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>