<?php

namespace App\Services;

use App\Models\AuditLog;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Request;

class AuditLogger
{
    /**
     * Log an admin action.
     */
    public static function log(string $action, ?string $details = null)
    {
        return AuditLog::create([
            'admin_id' => Auth::guard('admin')->id(),
            'action' => $action,
            'details' => $details,
            'ip_address' => Request::ip(),
        ]);
    }
}
