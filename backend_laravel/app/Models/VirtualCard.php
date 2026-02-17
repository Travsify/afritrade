<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class VirtualCard extends Model
{
    protected $fillable = [
        'user_id',
        'card_number',
        'name_on_card',
        'expiration_date',
        'cvv',
        'card_type',
        'brand',
        'currency',
        'balance',
        'status',
        'billing_address'
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
