<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class VirtualAccount extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'account_name',
        'account_number',
        'bank_name',
        'currency',
        'balance',
        'label',
        'status',
        'routing_number',
        'iban',
        'bic',
        'sort_code',
        'reference'
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
