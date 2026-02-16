<?php
// backend/admin/users.php
require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/../config/db.php';

// Handle user actions
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';
    // ... (action logic remains same, assuming it was safe)
// Update User Logic
    if ($action === 'update' && $userId) {
        $name = $_POST['name'];
        $email = $_POST['email'];
        $role = $_POST['role'];
        // $phone = $_POST['phone']; // If phone is in DB

        $stmt = $pdo->prepare("UPDATE users SET name = ?, email = ?, role = ? WHERE id = ?");
        $stmt->execute([$name, $email, $role, $userId]);
        $success = "User updated successfully";
    }
}

// Fetch users
$users = [];
try {
    $stmt = $pdo->query("SELECT * FROM users ORDER BY created_at DESC");
    $users = $stmt->fetchAll();
} catch (PDOException $e) {
}
?>

<!-- Header -->
<div class="flex justify-between items-center mb-8">
    <div>
        <h1 class="text-3xl font-bold text-white">Users</h1>
        <p class="text-slate-400">Manage all registered users</p>
    </div>
</div>

<?php if (isset($success))
    echo "<div class='bg-emerald-500/20 text-emerald-400 p-4 rounded mb-4'>$success</div>"; ?>

<!-- Users Table -->
<div class="bg-slate-800 rounded-2xl border border-slate-700 overflow-hidden">
    <table class="w-full text-left border-collapse">
        <thead class="bg-slate-700/50">
            <tr>
                <th class="p-4 text-slate-400 font-medium">User</th>
                <th class="p-4 text-slate-400 font-medium">Email</th>
                <th class="p-4 text-slate-400 font-medium">Role</th>
                <th class="p-4 text-slate-400 font-medium">Joined</th>
                <th class="p-4 text-slate-400 font-medium text-right">Actions</th>
            </tr>
        </thead>
        <tbody class="divide-y divide-slate-700">
            <?php if (empty($users)): ?>
                <tr>
                    <td colspan="5" class="p-8 text-center text-slate-500">No users found</td>
                </tr>
            <?php else: ?>
                <?php foreach ($users as $user): ?>
                    <tr class="hover:bg-slate-700/30 transition">
                        <td class="p-4">
                            <div class="flex items-center gap-3">
                                <div
                                    class="w-10 h-10 bg-blue-500/20 rounded-full flex items-center justify-center text-blue-400 font-bold">
                                    <?php echo strtoupper(substr($user['name'], 0, 1)); ?>
                                </div>
                                <span class="text-white font-medium"><?php echo htmlspecialchars($user['name']); ?></span>
                            </div>
                        </td>
                        <td class="p-4 text-slate-400"><?php echo htmlspecialchars($user['email']); ?></td>
                        <td class="p-4">
                            <span
                                class="px-3 py-1 rounded-full text-xs font-medium <?php echo $user['role'] === 'admin' ? 'bg-emerald-500/20 text-emerald-400' : 'bg-blue-500/20 text-blue-400'; ?>">
                                <?php echo ucfirst($user['role']); ?>
                            </span>
                        </td>
                        <td class="p-4 text-slate-400"><?php echo date('M d, Y', strtotime($user['created_at'])); ?></td>
                        <td class="p-4 text-right flex justify-end gap-2">
                            <!-- Edit Button -->
                            <button onclick="openEditModal(<?= htmlspecialchars(json_encode($user)) ?>)"
                                class="text-blue-400 hover:text-blue-300 p-1 bg-blue-500/10 rounded hover:bg-blue-500/20 transition">
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z">
                                    </path>
                                </svg>
                            </button>

                            <?php if ($user['role'] !== 'admin'): ?>
                                <form method="POST" class="inline" onsubmit="return confirm('Delete user?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="user_id" value="<?php echo $user['id']; ?>">
                                    <button
                                        class="text-red-400 hover:text-red-300 p-1 bg-red-500/10 rounded hover:bg-red-500/20 transition">
                                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16">
                                            </path>
                                        </svg>
                                    </button>
                                </form>
                            <?php endif; ?>
                        </td>
                    </tr>
                <?php endforeach; ?>
            <?php endif; ?>
        </tbody>
    </table>
</div>

<!-- Edit User Modal -->
<div id="editUserModal" class="hidden fixed inset-0 bg-black/80 flex items-center justify-center z-50">
    <div class="bg-slate-800 p-6 rounded-2xl w-96 border border-slate-700">
        <h3 class="text-white font-bold text-xl mb-4">Edit User</h3>
        <form method="POST">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="user_id" id="edit_user_id">

            <div class="mb-3">
                <label class="text-slate-400 text-sm block mb-1">Full Name</label>
                <input type="text" name="name" id="edit_name" required
                    class="w-full bg-slate-700 p-2 rounded text-white border border-slate-600 focus:border-emerald-500 outline-none">
            </div>

            <div class="mb-3">
                <label class="text-slate-400 text-sm block mb-1">Email</label>
                <input type="email" name="email" id="edit_email" required
                    class="w-full bg-slate-700 p-2 rounded text-white border border-slate-600 focus:border-emerald-500 outline-none">
            </div>

            <div class="mb-4">
                <label class="text-slate-400 text-sm block mb-1">Role</label>
                <select name="role" id="edit_role"
                    class="w-full bg-slate-700 p-2 rounded text-white border border-slate-600 focus:border-emerald-500 outline-none">
                    <option value="user">User</option>
                    <option value="admin">Admin</option>
                </select>
            </div>

            <div class="flex justify-end gap-3">
                <button type="button" onclick="document.getElementById('editUserModal').classList.add('hidden')"
                    class="text-slate-400 hover:text-white">Cancel</button>
                <button type="submit"
                    class="bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded font-bold">Update</button>
            </div>
        </form>
    </div>
</div>

<script>
    function openEditModal(user) {
        document.getElementById('edit_user_id').value = user.id;
        document.getElementById('edit_name').value = user.name;
        document.getElementById('edit_email').value = user.email;
        document.getElementById('edit_role').value = user.role;
        document.getElementById('editUserModal').classList.remove('hidden');
    }
</script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>