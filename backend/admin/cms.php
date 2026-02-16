<?php
// backend/admin/cms.php
require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/../config/db.php';

// Handle Banner Upload
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['type']) && $_POST['type'] == 'banner') {
        $title = $_POST['title'];
        $image = $_POST['image']; // URL
        $stmt = $pdo->prepare("INSERT INTO cms_banners (title, image_url) VALUES (?, ?)");
        $stmt->execute([$title, $image]);
    }
    // Handle Delete
    if (isset($_POST['action']) && $_POST['action'] == 'delete') {
        $id = $_POST['id'];
        $stmt = $pdo->prepare("DELETE FROM cms_banners WHERE id = ?");
        $stmt->execute([$id]);
    }
}
$banners = [];
try {
    $banners = $pdo->query("SELECT * FROM cms_banners ORDER BY id DESC")->fetchAll();
} catch (Exception $e) {
}
?>

<div class="flex justify-between items-center mb-8">
    <div>
        <h1 class="text-3xl font-bold text-white">Content Management</h1>
        <p class="text-slate-400">Manage App Banners & Announcements</p>
    </div>
</div>

<div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
    <!-- Add Form -->
    <div class="lg:col-span-1">
        <div class="bg-slate-800 rounded-2xl p-6 border border-slate-700">
            <h3 class="text-white font-bold text-xl mb-4">Add Promo Banner</h3>
            <form method="POST" class="space-y-4">
                <input type="hidden" name="type" value="banner">
                <div>
                    <label class="text-slate-400 text-sm mb-1 block">Title</label>
                    <input type="text" name="title" placeholder="e.g. Summer Promo"
                        class="w-full bg-slate-700 p-3 rounded-xl text-white border border-slate-600 focus:border-emerald-500 outline-none"
                        required>
                </div>
                <div>
                    <label class="text-slate-400 text-sm mb-1 block">Image URL</label>
                    <input type="text" name="image" placeholder="https://..."
                        class="w-full bg-slate-700 p-3 rounded-xl text-white border border-slate-600 focus:border-emerald-500 outline-none"
                        required>
                    <p class="text-xs text-slate-500 mt-1">Direct link to image (JPG/PNG)</p>
                </div>
                <button
                    class="w-full bg-emerald-500 hover:bg-emerald-600 text-white py-3 rounded-xl font-bold transition shadow-lg shadow-emerald-500/20">
                    Add Banner
                </button>
            </form>
        </div>
    </div>

    <!-- List -->
    <div class="lg:col-span-2">
        <h3 class="text-white font-bold text-lg mb-4">Active Banners</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <?php foreach ($banners as $b): ?>
                <div class="bg-slate-800 rounded-xl overflow-hidden border border-slate-700 group relative">
                    <div class="h-40 bg-slate-700 bg-center bg-cover"
                        style="background-image: url('<?= htmlspecialchars($b['image_url']) ?>')"></div>
                    <div
                        class="p-4 flex justify-between items-center bg-slate-800/90 backdrop-blur absolute bottom-0 left-0 right-0">
                        <span class="text-white font-bold truncate mr-2"><?= htmlspecialchars($b['title']) ?></span>
                        <form method="POST" onsubmit="return confirm('Delete this banner?')">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="id" value="<?= $b['id'] ?>">
                            <button class="text-red-400 hover:text-red-300 p-1 bg-red-500/10 rounded-lg">
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16">
                                    </path>
                                </svg>
                            </button>
                        </form>
                    </div>
                </div>
            <?php endforeach; ?>
            <?php if (empty($banners)): ?>
                <div class="col-span-2 text-center py-10 text-slate-500 border border-dashed border-slate-700 rounded-xl">
                    No active banners
                </div>
            <?php endif; ?>
        </div>
    </div>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>