<?php
// backend/admin/cards.php
require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/../config/db.php';

// Handle Actions (Freeze/Unfreeze)
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';
    $cardId = $_POST['card_id'] ?? 0;

    if ($action === 'freeze') {
        $stmt = $pdo->prepare("UPDATE virtual_cards SET status = 'frozen' WHERE id = ?");
        $stmt->execute([$cardId]);
    } elseif ($action === 'unfreeze') {
        $stmt = $pdo->prepare("UPDATE virtual_cards SET status = 'active' WHERE id = ?");
        $stmt->execute([$cardId]);
    }
}

// Fetch cards
$cards = [];
try {
    $stmt = $pdo->query("SELECT c.*, u.name as user_name FROM virtual_cards c JOIN users u ON c.user_id = u.id ORDER BY c.created_at DESC");
    $cards = $stmt->fetchAll();
} catch (PDOException $e) {
}
?>

<div class="flex justify-between items-center mb-8">
    <div>
        <h1 class="text-3xl font-bold text-white">Virtual Cards</h1>
        <p class="text-slate-400">Monitor and Manage Issued Cards</p>
    </div>
</div>

<div class="bg-slate-800 rounded-2xl border border-slate-700 overflow-hidden">
    <table class="w-full text-left border-collapse">
        <thead class="bg-slate-700/50">
            <tr>
                <th class="p-4 text-slate-400 font-medium">Card Label</th>
                <th class="p-4 text-slate-400 font-medium">User</th>
                <th class="p-4 text-slate-400 font-medium">Balance</th>
                <th class="p-4 text-slate-400 font-medium">Brand</th>
                <th class="p-4 text-slate-400 font-medium">Status</th>
                <th class="p-4 text-slate-400 font-medium text-right">Actions</th>
            </tr>
        </thead>
        <tbody class="divide-y divide-slate-700">
            <?php if (empty($cards)): ?>
                <tr><td colspan="6" class="p-8 text-center text-slate-500">No cards issued yet</td></tr>
            <?php else: ?>
                <?php foreach ($cards as $card): ?>
                    <tr class="hover:bg-slate-700/30 transition">
                        <td class="p-4">
                            <p class="text-white font-medium"><?php echo htmlspecialchars($card['label']); ?></p>
                            <p class="text-slate-500 text-xs">**** <?php echo substr($card['card_number'], -4); ?></p>
                        </td>
                        <td class="p-4 text-slate-300"><?php echo htmlspecialchars($card['user_name']); ?></td>
                        <td class="p-4 text-white font-bold">$<?php echo number_format($card['balance'], 2); ?></td>
                        <td class="p-4"><span class="px-2 py-1 rounded-lg text-xs font-medium bg-slate-700 text-slate-300 uppercase"><?php echo htmlspecialchars($card['brand']); ?></span></td>
                        <td class="p-4">
                            <span class="px-3 py-1 rounded-full text-xs font-medium <?php echo $card['status'] === 'active' ? 'bg-emerald-500/20 text-emerald-400' : 'bg-red-500/20 text-red-400'; ?>">
                                <?php echo ucfirst($card['status']); ?>
                            </span>
                        </td>
                        <td class="p-4 text-right">
                            <form method="POST" class="inline">
                                <input type="hidden" name="card_id" value="<?php echo $card['id']; ?>">
                                <?php if ($card['status'] === 'active'): ?>
                                    <input type="hidden" name="action" value="freeze">
                                    <button type="submit" class="text-amber-400 hover:underline text-sm">Freeze</button>
                                <?php else: ?>
                                    <input type="hidden" name="action" value="unfreeze">
                                    <button type="submit" class="text-emerald-400 hover:underline text-sm">Unfreeze</button>
                                <?php endif; ?>
                            </form>
                        </td>
                    </tr>
                <?php endforeach; ?>
            <?php endif; ?>
        </tbody>
    </table>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
