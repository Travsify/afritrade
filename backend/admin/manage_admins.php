<?php
// backend/admin/manage_admins.php
require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/../config/db.php';

// Check if current user is strict Super Admin? 
// For now, any admin can manage admins to keep it simple as requested.

$success = '';
$error = '';

// Handle Create Admin
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['action']) && $_POST['action'] === 'create') {
        $name = $_POST['name'] ?? '';
        $email = $_POST['email'] ?? '';
        $password = $_POST['password'] ?? '';

        if ($name && $email && $password) {
            try {
                // Check if email exists
                $stmt = $pdo->prepare("SELECT id FROM users WHERE email = ?");
                $stmt->execute([$email]);
                if ($stmt->fetch()) {
                    $error = "Email already exists.";
                } else {
                    $hashed = password_hash($password, PASSWORD_DEFAULT);
                    $stmt = $pdo->prepare("INSERT INTO users (name, email, password, role, created_at) VALUES (?, ?, ?, 'admin', NOW())");
                    $stmt->execute([$name, $email, $hashed]);
                    $success = "New admin created successfully.";
                }
            } catch (PDOException $e) {
                $error = "Database error: " . $e->getMessage();
            }
        } else {
            $error = "All fields are required.";
        }
    }

    // Handle Delete Admin
    if (isset($_POST['action']) && $_POST['action'] === 'delete') {
        $id = $_POST['admin_id'] ?? 0;
        // Prevent self-deletion
        if ($id == $_SESSION['admin_id']) {
            $error = "You cannot delete your own account.";
        } else {
            try {
                $stmt = $pdo->prepare("DELETE FROM users WHERE id = ? AND role = 'admin'");
                $stmt->execute([$id]);
                $success = "Admin removed successfully.";
            } catch (PDOException $e) {
                $error = "Error removing admin.";
            }
        }
    }
}

// Fetch Admins
$admins = [];
try {
    $stmt = $pdo->query("SELECT * FROM users WHERE role = 'admin' ORDER BY created_at DESC");
    $admins = $stmt->fetchAll();
} catch (PDOException $e) {
}
?>

<!-- Header -->
<div class="flex justify-between items-center mb-8">
    <div>
        <h1 class="text-3xl font-bold text-white">Manage Admins</h1>
        <p class="text-slate-400">Create and Remove System Administrators</p>
    </div>
</div>

<?php if ($success): ?>
    <div class="bg-emerald-500/20 text-emerald-400 p-4 rounded-xl mb-6 border border-emerald-500/20">
        <?= htmlspecialchars($success) ?>
    </div>
<?php endif; ?>

<?php if ($error): ?>
    <div class="bg-red-500/20 text-red-400 p-4 rounded-xl mb-6 border border-red-500/20">
        <?= htmlspecialchars($error) ?>
    </div>
<?php endif; ?>

<div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
    <!-- Create Form -->
    <div class="lg:col-span-1">
        <div class="bg-slate-800 rounded-2xl p-6 border border-slate-700">
            <h3 class="text-white font-bold text-xl mb-6">Add New Admin</h3>
            <form method="POST" class="space-y-4">
                <input type="hidden" name="action" value="create">
                <div>
                    <label class="block text-slate-400 text-sm mb-2">Full Name</label>
                    <input type="text" name="name" required
                        class="w-full bg-slate-700 border border-slate-600 rounded-xl px-4 py-3 text-white focus:outline-none focus:border-emerald-500 transition">
                </div>
                <div>
                    <label class="block text-slate-400 text-sm mb-2">Email Address</label>
                    <input type="email" name="email" required
                        class="w-full bg-slate-700 border border-slate-600 rounded-xl px-4 py-3 text-white focus:outline-none focus:border-emerald-500 transition">
                </div>
                <div>
                    <label class="block text-slate-400 text-sm mb-2">Password</label>
                    <input type="password" name="password" required
                        class="w-full bg-slate-700 border border-slate-600 rounded-xl px-4 py-3 text-white focus:outline-none focus:border-emerald-500 transition">
                </div>
                <button type="submit"
                    class="w-full bg-emerald-500 hover:bg-emerald-600 text-white font-bold py-3 rounded-xl transition shadow-lg shadow-emerald-500/20">
                    Create Admin
                </button>
            </form>
        </div>
    </div>

    <!-- Admin List -->
    <div class="lg:col-span-2">
        <div class="bg-slate-800 rounded-2xl border border-slate-700 overflow-hidden">
            <table class="w-full text-left border-collapse">
                <thead class="bg-slate-700/50">
                    <tr>
                        <th class="p-4 text-slate-400 font-medium">Admin User</th>
                        <th class="p-4 text-slate-400 font-medium">Email</th>
                        <th class="p-4 text-slate-400 font-medium">Joined</th>
                        <th class="p-4 text-slate-400 font-medium text-right">Action</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-700">
                    <?php foreach ($admins as $admin): ?>
                        <tr class="hover:bg-slate-700/30 transition">
                            <td class="p-4">
                                <div class="flex items-center gap-3">
                                    <div
                                        class="w-8 h-8 bg-purple-500/20 rounded-lg flex items-center justify-center text-purple-400 font-bold text-sm">
                                        <?= strtoupper(substr($admin['name'], 0, 1)) ?>
                                    </div>
                                    <span class="text-white font-medium">
                                        <?= htmlspecialchars($admin['name']) ?>
                                    </span>
                                    <?php if ($admin['id'] == $_SESSION['admin_id']): ?>
                                        <span class="bg-slate-600 text-white text-xs px-2 py-0.5 rounded">You</span>
                                    <?php endif; ?>
                                </div>
                            </td>
                            <td class="p-4 text-slate-400 text-sm">
                                <?= htmlspecialchars($admin['email']) ?>
                            </td>
                            <td class="p-4 text-slate-500 text-sm">
                                <?= date('M d, Y', strtotime($admin['created_at'])) ?>
                            </td>
                            <td class="p-4 text-right">
                                <?php if ($admin['id'] != $_SESSION['admin_id']): ?>
                                    <form method="POST"
                                        onsubmit="return confirm('Are you sure you want to remove this admin?');">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="admin_id" value="<?= $admin['id'] ?>">
                                        <button
                                            class="text-red-400 hover:text-red-300 p-1 bg-red-500/10 rounded hover:bg-red-500/20 transition">
                                            Remove
                                        </button>
                                    </form>
                                <?php endif; ?>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>