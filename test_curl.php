<?php
$email = 'tester_' . time() . '@example.com';

// 1. Register User
$ch1 = curl_init('https://afritrade.onrender.com/api/register');
curl_setopt($ch1, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch1, CURLOPT_POSTFIELDS, json_encode([
    'name' => 'Automated Test',
    'email' => $email,
    'password' => 'password123',
    'password_confirmation' => 'password123',
    'country' => 'Nigeria',
    'business_name' => 'Automated Business',
    'phone' => '+234' . rand(10000000, 99999999), 
]));
curl_setopt($ch1, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);
$res1 = curl_exec($ch1);
curl_close($ch1);
file_put_contents('curl_out.txt', "FULL Register Response:\n$res1\n\n");

// 2. Resend OTP
$ch2 = curl_init('https://afritrade.onrender.com/api/resend-otp');
curl_setopt($ch2, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch2, CURLOPT_POSTFIELDS, json_encode([
    'email' => $email,
]));
curl_setopt($ch2, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);
$res2 = curl_exec($ch2);
curl_close($ch2);
file_put_contents('curl_out.txt', "FULL Resend OTP Response:\n$res2\n", FILE_APPEND);
echo "Done saving to curl_out.txt";
