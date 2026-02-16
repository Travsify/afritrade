<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Referral extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'referrer_id',
        'commission_earned',
        'status',
    ];

    protected $casts = [
        'commission_earned' => 'decimal:2',
    ];

    public function recommender()
    {
        return $this->belongsTo(User::class, 'referrer_id');
    }

    public function user() // The referee
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}
