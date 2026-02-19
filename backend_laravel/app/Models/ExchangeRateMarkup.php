<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ExchangeRateMarkup extends Model
{
    use HasFactory;

    protected $fillable = [
        'from_currency',
        'to_currency',
        'markup_type',
        'fixed_markup',
        'percentage_markup',
        'is_active',
    ];

    protected $casts = [
        'fixed_markup' => 'decimal:2',
        'percentage_markup' => 'decimal:2',
        'is_active' => 'boolean',
    ];
}
