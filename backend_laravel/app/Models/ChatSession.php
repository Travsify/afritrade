<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ChatSession extends Model
{
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'user_id',
        'status',
    ];
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function messages()
    {
        return $this->hasMany(ChatMessage::class);
    }
}
