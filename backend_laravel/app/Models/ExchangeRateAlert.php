<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ExchangeRateAlert extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'pair',
        'target_rate',
        'condition',
        'status',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
