<?php

namespace App\Events;

use App\Models\User;
use App\Models\Wallet;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class UserFunded
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $user;
    public $amount;
    public $currency;

    /**
     * Create a new event instance.
     */
    public function __construct(User $user, $amount, $currency)
    {
        $this->user = $user;
        $this->amount = $amount;
        $this->currency = $currency;
    }
}
