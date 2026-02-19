<?php

namespace App\Jobs;

use App\Models\User;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class SendPushNotificationJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function __construct(
        protected int $userId,
        protected string $title,
        protected string $body,
        protected array $data = []
    ) {}

    public function handle(): void
    {
        try {
            $user = User::find($this->userId);
            if (!$user || empty($user->fcm_token)) return;

            $serverKey = config('services.firebase.server_key');
            if (empty($serverKey)) {
                Log::debug('FCM server key not configured, skipping push notification');
                return;
            }

            $payload = [
                'to' => $user->fcm_token,
                'notification' => [
                    'title' => $this->title,
                    'body' => $this->body,
                    'sound' => 'default',
                ],
                'data' => array_merge($this->data, [
                    'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                    'type' => $this->data['action'] ?? 'general',
                ]),
                'priority' => 'high',
            ];

            $response = Http::withHeaders([
                'Authorization' => 'key=' . $serverKey,
                'Content-Type' => 'application/json',
            ])->post('https://fcm.googleapis.com/fcm/send', $payload);

            if ($response->failed()) {
                Log::warning('FCM push failed', [
                    'user_id' => $this->userId,
                    'status' => $response->status(),
                    'body' => $response->body()
                ]);
            }
        } catch (\Exception $e) {
            Log::error('FCM push exception: ' . $e->getMessage());
        }
    }
}
