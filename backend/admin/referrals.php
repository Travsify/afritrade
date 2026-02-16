<?php
// backend/admin/referrals.php
require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/../config/db.php';

$referrals = [];
try {
    // Join users table twice: once for the 'new user' (u1) and once for 'referrer' (u2)
    $stmt = $pdo->query("SELECT r.*, u1.name as invitee, u2.name as promoter 
                         FROM referrals r 
                         JOIN users u1 ON r.user_id = u1.id 
                         JOIN users u2 ON r.referrer_id = u2.id 
                         ORDER BY r.created_at DESC");
    $referrals = $stmt->fetchAll();
} catch (Exception $e) {
}
?>

<!-- Header -->
<div class="flex justify-between items-center mb-8">
    <div>
        <h1 class="text-3xl font-bold text-white">Referral Network</h1>
        <p class="text-slate-400">Track Promoters and Commissions</p>
    </div>
</div>

<!-- Table -->
<div class="bg-slate-800 rounded-2xl border border-slate-700 overflow-hidden">
    <table class="w-full text-left border-collapse">
        <thead class="bg-slate-700/50">
            <tr>
                <th class="p-4 text-slate-400 font-medium">Promoter</th>
                <th class="p-4 text-slate-400 font-medium">Invited User</th>
                <th class="p-4 text-slate-400 font-medium">Commission</th>
                <th class="p-4 text-slate-400 font-medium">Status</th>
                <th class="p-4 text-slate-400 font-medium text-right">Date</th>
            </tr>
        </thead>
        <tbody class="divide-y divide-slate-700">
            <?php if (empty($referrals)): ?>
                <tr>
                    <td colspan="5" class="p-8 text-center text-slate-500">No referral data found.</td>
                </tr>
            <?php else: ?>
                <?php foreach ($referrals as $ref): ?>
                    <tr class="hover:bg-slate-700/30 transition">
                        <td class="p-4">
                            <span class="text-emerald-400 font-bold"><?= htmlspecialchars($ref['promoter']) ?></span>
                        </td>
                        <td class="p-4 text-white">
                            <?= htmlspecialchars($ref['invitee']) ?>
                        </td>
                        <td class="p-4 text-white font-bold">₦
                            <?= number_format($ref['commission_earned'], 2) ?>
                        </td>
                        <td class="p-4">
                            <span
                                class="px-2 py-1 rounded text-xs font-bold uppercase <?= $ref['status'] == 'active' ? 'bg-emerald-500/20 text-emerald-400' : 'bg-slate-500/20 text-slate-400' ?>">
                                <?= ucfirst($ref['status']) ?>
                            </span>
                        </td>
                        <td class="p-4 text-slate-500 text-sm text-right">
                            <?= date('M d, Y', strtotime($ref['created_at'])) ?>
                        </td>
                    </tr>
                <?php endforeach; ?>
            <?php endif; ?>
        </tbody>
    </table>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>