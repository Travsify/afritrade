<?php
// backend/admin/chat_agent.php
require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/../config/db.php';

$session_id = $_GET['id'] ?? '';
if (!$session_id) {
    echo "<script>window.location='support.php';</script>";
    exit;
}

// Handle Agent Reply
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['message'])) {
    $msg = $_POST['message'];

    // 1. Insert Reply
    $stmt = $pdo->prepare("INSERT INTO chat_messages (session_id, sender, message) VALUES (?, 'agent', ?)");
    $stmt->execute([$session_id, $msg]);

    // 2. Set Status to Human Active
    $stmt = $pdo->prepare("UPDATE chat_sessions SET status = 'human' WHERE id = ?");
    $stmt->execute([$session_id]);
}

// Fetch Messages
$messages = [];
try {
    $stmt = $pdo->prepare("SELECT * FROM chat_messages WHERE session_id = ? ORDER BY created_at ASC");
    $stmt->execute([$session_id]);
    $messages = $stmt->fetchAll();
} catch (Exception $e) {
}
?>

<!-- Header -->
<div class="flex justify-between items-center mb-6">
    <div>
        <a href="support.php"
            class="text-slate-400 hover:text-white text-sm mb-2 inline-flex items-center gap-1 transition">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18">
                </path>
            </svg>
            Back to Support List
        </a>
        <h1 class="text-3xl font-bold text-white">Chat Session</h1>
        <p class="text-slate-400 font-mono text-sm">ID: <?= htmlspecialchars($session_id) ?></p>
    </div>
</div>

<!-- Chat Interface -->
<div class="bg-slate-800 rounded-2xl border border-slate-700 overflow-hidden flex flex-col" style="height: 70vh;">
    <!-- Messages Area -->
    <div id="chatBox" class="flex-1 overflow-y-auto p-6 space-y-4 bg-slate-900/50">
        <?php foreach ($messages as $m): ?>
            <?php
            $isUser = $m['sender'] === 'user';
            $align = $isUser ? 'justify-start' : 'justify-end';
            $bg = $isUser ? 'bg-slate-700 text-white rounded-tl-none' : ($m['sender'] === 'ai' ? 'bg-slate-600 text-slate-200 rounded-tr-none' : 'bg-emerald-600 text-white rounded-tr-none');
            $label = $isUser ? 'User' : ($m['sender'] === 'ai' ? 'AI Assistant' : 'You');
            ?>
            <div class="flex <?= $align ?>">
                <div class="max-w-[70%]">
                    <p class="text-xs text-slate-500 mb-1 px-1 <?= $isUser ? '' : 'text-right' ?>"><?= $label ?></p>
                    <div class="<?= $bg ?> p-4 rounded-2xl shadow-sm">
                        <?= htmlspecialchars($m['message']) ?>
                    </div>
                </div>
            </div>
        <?php endforeach; ?>
    </div>

    <!-- Input Area -->
    <div class="p-4 bg-slate-800 border-t border-slate-700">
        <form method="post" class="flex gap-4">
            <input type="text" name="message"
                class="flex-1 bg-slate-900 border border-slate-600 rounded-xl px-4 py-3 text-white focus:outline-none focus:border-emerald-500 transition placeholder-slate-500"
                placeholder="Type a reply..." required autocomplete="off" autofocus>
            <button
                class="bg-emerald-500 hover:bg-emerald-600 text-white px-6 py-3 rounded-xl font-bold transition shadow-lg shadow-emerald-500/20">
                Send
            </button>
        </form>
    </div>
</div>

<script>
    const chatBox = document.getElementById('chatBox');
    chatBox.scrollTop = chatBox.scrollHeight;
</script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>