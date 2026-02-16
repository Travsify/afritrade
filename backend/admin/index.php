<?php
/**
 * Admin Panel Entry Point
 * Redirects to login or dashboard based on session
 */

session_start();

// If already logged in, go to dashboard
if (isset($_SESSION['admin_logged_in']) && $_SESSION['admin_logged_in'] === true) {
    header('Location: dashboard.php');
    exit;
}

// Otherwise, go to login
header('Location: login.php');
exit;
