<?php
// backend/admin/transactions.php
require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/../config/db.php';

// Handle transaction actions
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';
    $txId = $_POST['tx_id'] ?? 0;
    $status = $_POST['status'] ?? '';

    if ($action === 'update_status' && $txId && $status) {
        $stmt = $pdo->prepare("UPDATE transactions SET status = ? WHERE id = ?");
        $stmt->execute([$status, $txId]);
    }

    // Manual Transaction Creation
    if ($action === 'create_transaction') {
        $email = $_POST['user_email'];
        $type = $_POST['type'];
        $amount = $_POST['amount'];
        $currency = $_POST['currency'];

        // Find User ID
        $stmt = $pdo->prepare("SELECT id FROM users WHERE email = ?");
        $stmt->execute([$email]);
        $uid = $stmt->fetchColumn();

        if ($uid) {
            $stmt = $pdo->prepare("INSERT INTO transactions (user_id, type, amount, currency, status, recipient) VALUES (?, ?, ?, ?, 'completed', 'Manual Credit')");
            $stmt->execute([$uid, $type, $amount, $currency]);
            $success = "Transaction created successfully for $email";
        } else {
            $error = "User with email $email not found.";
        }
    }
}
// Fetch Users for Dropdown (Optional, simplified to Email input for now)
// ...


// Fetch transactions
$transactions = [];
try {
    $stmt = $pdo->query("SELECT t.*, u.name as user_name FROM transactions t LEFT JOIN users u ON t.user_id = u.id ORDER BY t.created_at DESC");
    $transactions = $stmt->fetchAll();
} catch (PDOException $e) {
    // Handle error
}
?>

<div class="flex justify-between items-center mb-8">
    <div>
        <h1 class="text-3xl font-bold text-white">Transactions</h1>
    </div>
    <button onclick="document.getElementById('createTxModal').classList.remove('hidden')" class="bg-emerald-500 hover:bg-emerald-600 text-white px-4 py-2 rounded-xl font-bold transition">
        + New Transaction
    </button>
</div>

<!-- Output Messages -->
<?php if (isset($success)) echo "<div class='bg-green-500/20 text-green-400 p-4 rounded mb-4'>$success</div>"; ?>
<?php if (isset($error)) echo "<div class='bg-red-500/20 text-red-400 p-4 rounded mb-4'>$error</div>"; ?>

<!-- Modal -->
<div id="createTxModal" class="hidden fixed inset-0 bg-black/80 flex items-center justify-center z-50">
    <div class="bg-slate-800 p-6 rounded-2xl w-96 border border-slate-700">
        <h3 class="text-white font-bold text-xl mb-4">Create Transaction</h3>
        <form method="POST">
            <input type="hidden" name="action" value="create_transaction">
            <div class="mb-3">
                <label class="text-slate-400 text-sm block mb-1">User Email</label>
                <input type="email" name="user_email" class="w-full bg-slate-700 p-2 rounded text-white border border-slate-600 focus:border-emerald-500 outline-none" required placeholder="user@example.com">
            </div>
            <div class="mb-3">
                 <label class="text-slate-400 text-sm block mb-1">Type</label>
                 <select name="type" class="w-full bg-slate-700 p-2 rounded text-white border border-slate-600 focus:border-emerald-500 outline-none">
                     <option value="credit">Credit (Deposit)</option>
                     <option value="debit">Debit (Withdrawal)</option>
                 </select>
            </div>
            <div class="mb-3">
                 <label class="text-slate-400 text-sm block mb-1">Amount</label>
                 <input type="number" step="0.01" name="amount" class="w-full bg-slate-700 p-2 rounded text-white border border-slate-600 focus:border-emerald-500 outline-none" required>
            </div>
            <div class="mb-4">
                 <label class="text-slate-400 text-sm block mb-1">Currency</label>
                 <select name="currency" class="w-full bg-slate-700 p-2 rounded text-white border border-slate-600 focus:border-emerald-500 outline-none">
                     <option value="NGN">NGN</option>
                     <option value="USD">USD</option>
                 </select>
            </div>
            <div class="flex justify-end gap-3">
                <button type="button" onclick="document.getElementById('createTxModal').classList.add('hidden')" class="text-slate-400 hover:text-white">Cancel</button>
                <button type="submit" class="bg-emerald-500 hover:bg-emerald-600 text-white px-4 py-2 rounded font-bold">Create</button>
            </div>
        </form>
    </div>
</div>

<!-- Transactions Table -->
<div class="bg-slate-800 rounded-2xl border border-slate-700 overflow-hidden">
    <table class="w-full text-left border-collapse">
        <thead class="bg-slate-700/50">
            <tr>
                <th class="p-4 text-slate-400 font-medium">Reference</th>
                <th class="p-4 text-slate-400 font-medium">User</th>
                <th class="p-4 text-slate-400 font-medium">Type</th>
                <th class="p-4 text-slate-400 font-medium">Amount</th>
                <th class="p-4 text-slate-400 font-medium">Status</th>
                <th class="p-4 text-slate-400 font-medium">Date</th>
                <th class="p-4 text-slate-400 font-medium text-right">Actions</th>
            </tr>
        </thead>
        <tbody class="divide-y divide-slate-700">
            <?php if (empty($transactions)): ?>
                <tr><td colspan="7" class="p-8 text-center text-slate-500">No transactions found</td></tr>
            <?php else: ?>
                <?php foreach ($transactions as $tx): ?>
                    <tr class="hover:bg-slate-700/30 transition">
                        <td class="p-4 text-white font-medium">#<?php echo htmlspecialchars($tx['reference']); ?></td>
                        <td class="p-4 text-slate-300"><?php echo htmlspecialchars($tx['user_name'] ?? 'System'); ?></td>
                        <td class="p-4"><span class="px-2 py-1 rounded-lg text-xs font-medium bg-slate-700 text-slate-300 uppercase"><?php echo htmlspecialchars($tx['type']); ?></span></td>
                        <td class="p-4 text-white font-bold"><?php echo $tx['currency']; ?><?php echo number_format($tx['amount'], 2); ?></td>
                        <td class="p-4">
                            <?php
                            $statusClass = 'bg-amber-500/20 text-amber-400';
                            if ($tx['status'] === 'completed') $statusClass = 'bg-emerald-500/20 text-emerald-400';
                            if ($tx['status'] === 'rejected' || $tx['status'] === 'failed') $statusClass = 'bg-red-500/20 text-red-400';
                            ?>
                            <span class="px-3 py-1 rounded-full text-xs font-medium <?php echo $statusClass; ?>"><?php echo ucfirst($tx['status']); ?></span>
                        </td>
                        <td class="p-4 text-slate-400 text-sm"><?php echo date('M d, H:i', strtotime($tx['created_at'])); ?></td>
                        <td class="p-4 text-right">
                            <form method="POST" class="inline">
                                <input type="hidden" name="action" value="update_status">
                                <input type="hidden" name="tx_id" value="<?php echo $tx['id']; ?>">
                                <select name="status" onchange="this.form.submit()" class="bg-slate-700 border border-slate-600 rounded-lg px-2 py-1 text-xs text-white focus:outline-none">
                                    <option value="">Action</option>
                                    <option value="pending">Mark Pending</option>
                                    <option value="completed">Mark Complete</option>
                                    <option value="rejected">Reject</option>
                                </select>
                            </form>
                        </td>
                    </tr>
                <?php endforeach; ?>
            <?php endif; ?>
        </tbody>
    </table>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>