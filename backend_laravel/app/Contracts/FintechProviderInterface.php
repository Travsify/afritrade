<?php

namespace App\Contracts;

interface FintechProviderInterface
{
    public function getBalance();
    public function getWebhookHeaders();
}
