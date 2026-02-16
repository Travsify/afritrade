<?php

namespace App\Listeners;

use App\Events\UserFunded;
use App\Models\Referral;
use App\Models\Transaction;
use App\Models\Wallet;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Support\Facades\Log;

class RewardReferrer
{
    /**
     * Create the event listener.
     */
    public function __construct()
    {
        //
    }

    /**
     * Handle the event.
     */
    public function handle(UserFunded $event): void
    {
        $user = $event->user;
        
        // check if user has a referrer
        $referral = Referral::where('user_id', $user->id)->where('status', 'active')->first();

        if ($referral && $referral->commission_earned == 0) {
             // Logic: Reward referrer 5% of first deposit? Or fixed amount?
             // Let's assume fixed $5 (converted) or 1% for now. 
             // Simplification: Fixed reward of 10 units of whatever currency.
             // Better: 100 NGN or 1 USD.
             // For MVP: Let's give 10.00 base currency reward.

             $rewardAmount = 10.00;
             $referrer = $referral->recommender;

             if ($referrer) {
                 $referrerWallet = Wallet::firstOrCreate(
                     ['user_id' => $referrer->id, 'currency' => $event->currency],
                     ['balance' => 0]
                 );

                 $referrerWallet->balance += $rewardAmount;
                 $referrerWallet->save();

                 // Log transaction
                 Transaction::create([
                     'user_id' => $referrer->id,
                     'wallet_id' => $referrerWallet->id,
                     'type' => 'referral_bonus',
                     'amount' => $rewardAmount,
                     'currency' => $event->currency,
                     'status' => 'completed',
                     'reference' => 'REF-BONUS-' . $user->id,
                 ]);

                 // Update referral record
                 $referral->commission_earned += $rewardAmount;
                 $referral->status = 'completed'; // One time reward
                 $referral->save();

                 Log::info("Referral reward of {$rewardAmount} {$event->currency} given to User {$referrer->id} for referring User {$user->id}");

                 // Notify Referrer
                 \App\Models\Notification::create([
                    'user_id' => $referrer->id,
                    'type' => 'referral',
                    'title' => 'Referral Reward!',
                    'message' => "You have earned {$event->currency} {$rewardAmount} for referring " . $user->name,
                    'data' => ['referral_id' => $referral->id]
                 ]);
             }
        }

        // Notify the user who funded their wallet
        \App\Models\Notification::create([
            'user_id' => $user->id,
            'type' => 'transaction',
            'title' => 'Wallet Funded',
            'message' => "Your wallet has been funded with {$event->currency} {$event->amount}.",
            'data' => ['amount' => $event->amount, 'currency' => $event->currency]
        ]);
    }
}
