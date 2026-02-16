<?php
// backend/admin/kyc.php
require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/../config/db.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'];
    $docId = $_POST['doc_id'];
    $reason = $_POST['reason'] ?? '';

    $status = $action == 'approve' ? 'approved' : 'rejected';

    $stmt = $pdo->prepare("UPDATE kyc_documents SET status = ?, rejection_reason = ? WHERE id = ?");
    $stmt->execute([$status, $reason, $docId]);

    // Log Audit
    $stmt = $pdo->prepare("INSERT INTO audit_logs (admin_id, action, details, ip_address) VALUES (?, ?, ?, ?)");
    $stmt->execute([$_SESSION['user_id'] ?? 1, 'KYC Review', "Doc #$docId marked as $status", $_SERVER['REMOTE_ADDR']]);
}

$docs = [];
try {
    $stmt = $pdo->query("SELECT k.*, u.name, u.email FROM kyc_documents k JOIN users u ON k.user_id = u.id ORDER BY k.created_at DESC");
    $docs = $stmt->fetchAll();
} catch (Exception $e) {
}
?>

<!-- Header -->
<div class="flex justify-between items-center mb-8">
    <div>
        <h1 class="text-3xl font-bold text-white">KYC Verification</h1>
        <p class="text-slate-400">Review Identity Documents</p>
    </div>
</div>

<!-- Table -->
<div class="bg-slate-800 rounded-2xl border border-slate-700 overflow-hidden">
    <table class="w-full text-left border-collapse">
        <thead class="bg-slate-700/50">
            <tr>
                <th class="p-4 text-slate-400 font-medium">User</th>
                <th class="p-4 text-slate-400 font-medium">Document</th>
                <th class="p-4 text-slate-400 font-medium">Status</th>
                <th class="p-4 text-slate-400 font-medium text-right">Actions</th>
            </tr>
        </thead>
        <tbody class="divide-y divide-slate-700">
            <?php if (empty($docs)): ?>
                <tr>
                    <td colspan="4" class="p-8 text-center text-slate-500">No pending KYC documents.</td>
                </tr>
            <?php else: ?>
                <?php foreach ($docs as $doc): ?>
                    <tr class="hover:bg-slate-700/30 transition">
                        <td class="p-4">
                            <p class="text-white font-bold"><?= htmlspecialchars($doc['name']) ?></p>
                            <p class="text-slate-500 text-sm"><?= htmlspecialchars($doc['email']) ?></p>
                        </td>
                        <td class="p-4">
                            <span
                                class="text-slate-300 uppercase text-sm font-semibold bg-slate-700 px-2 py-1 rounded"><?= htmlspecialchars($doc['doc_type']) ?></span>
                            <br>
                            <a href="<?= htmlspecialchars($doc['file_path']) ?>" target="_blank"
                                class="text-emerald-400 text-xs hover:underline mt-1 inline-block">View File</a>
                        </td>
                        <td class="p-4">
                            <span
                                class="px-2 py-1 rounded text-xs font-bold uppercase <?= $doc['status'] == 'approved' ? 'bg-emerald-500/20 text-emerald-400' : ($doc['status'] == 'rejected' ? 'bg-red-500/20 text-red-400' : 'bg-amber-500/20 text-amber-400') ?>">
                                <?= ucfirst($doc['status']) ?>
                            </span>
                        </td>
                        <td class="p-4 text-right">
                            <?php if ($doc['status'] == 'pending'): ?>
                                <div class="flex justify-end gap-2">
                                    <form method="POST">
                                        <input type="hidden" name="doc_id" value="<?= $doc['id'] ?>">
                                        <input type="hidden" name="action" value="approve">
                                        <button
                                            class="bg-emerald-500/10 hover:bg-emerald-500 text-emerald-400 hover:text-white px-3 py-1 rounded-lg text-xs font-bold transition border border-emerald-500/20">Approve</button>
                                    </form>
                                    <form method="POST">
                                        <input type="hidden" name="doc_id" value="<?= $doc['id'] ?>">
                                        <input type="hidden" name="action" value="reject">
                                        <button
                                            class="bg-red-500/10 hover:bg-red-500 text-red-400 hover:text-white px-3 py-1 rounded-lg text-xs font-bold transition border border-red-500/20">Reject</button>
                                    </form>
                                </div>
                            <?php else: ?>
                                <span class="text-slate-500 text-xs">Completed</span>
                            <?php endif; ?>
                        </td>
                    </tr>
                <?php endforeach; ?>
            <?php endif; ?>
        </tbody>
    </table>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>