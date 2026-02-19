<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class WebhookCall extends Model
{
    protected $fillable = [
        'provider',
        'provider_reference',
        'payload',
        'status',
    ];

    protected $casts = [
        'payload' => 'array',
    ];
}
