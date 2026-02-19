<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasFactory, Notifiable, \Laravel\Sanctum\HasApiTokens;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'transaction_pin',
        'balance',
        'kyc_tier', // 1, 2, 3
        'verification_status', // unverified, pending, verified, rejected
        'fcm_token',
        'country',
        'business_name',
        'otp_code',
        'otp_expires_at',
        'is_otp_verified',
        'kyb_status',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
        'transaction_pin',
        'otp_code',
    ];

    /**
     * Check if user has set a transaction pin.
     */
    public function getHasPinAttribute(): bool
    {
        return !is_null($this->transaction_pin);
    }

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'kyc_tier' => 'integer',
            'balance' => 'decimal:2',
            'is_kyc_verified' => 'boolean',
            'is_otp_verified' => 'boolean',
            'otp_expires_at' => 'datetime',
        ];
    }

    public function wallets()
    {
        return $this->hasMany(Wallet::class);
    }

    public function transactions()
    {
        return $this->hasMany(Transaction::class);
    }

    public function referrals()
    {
        return $this->hasMany(Referral::class, 'referrer_id');
    }

    public function notifications()
    {
        return $this->hasMany(Notification::class);
    }

    public function kycDocuments()
    {
        return $this->hasMany(KycDocument::class);
    }

    public function virtualAccounts()
    {
        return $this->hasMany(VirtualAccount::class);
    }

    public function cards()
    {
        return $this->hasMany(VirtualCard::class);
    }
}
