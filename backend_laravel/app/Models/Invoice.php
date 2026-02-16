<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Invoice extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'recipient_email',
        'amount',
        'currency',
        'description',
        'status',
        'reference',
        'due_date'
    ];

    // The user who issued the invoice
    public function issuer()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}
