<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ChatMessage extends Model
{
    protected $fillable = [
        'session_id',
        'user_id',
        'sender',
        'message',
        'is_read',
        'is_admin_reply',
    ];
}
