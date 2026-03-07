<!DOCTYPE html>
<html>
<head>
    <title>Your Afritrad Verification Code</title>
    <style>
        body { font-family: 'Inter', 'Helvetica Neue', Helvetica, Arial, sans-serif; background-color: #f4f7f6; margin: 0; padding: 0; }
        .container { max-width: 600px; margin: 40px auto; background-color: #ffffff; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); overflow: hidden; }
        .header { background-color: #0d1b2a; color: #ffffff; padding: 30px; text-align: center; }
        .header h1 { margin: 0; font-size: 24px; font-weight: 700; letter-spacing: -0.5px; }
        .content { padding: 40px 30px; text-align: center; }
        .content p { font-size: 16px; color: #4a5568; line-height: 1.6; margin-bottom: 24px; }
        .otp-box { background-color: #f8fafc; border: 2px dashed #cbd5e1; border-radius: 8px; padding: 20px; text-align: center; margin: 30px 0; }
        .otp-code { font-size: 36px; font-weight: 800; color: #3b82f6; letter-spacing: 8px; margin: 0; }
        .footer { background-color: #f1f5f9; padding: 20px; text-align: center; color: #64748b; font-size: 14px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Afritrad</h1>
        </div>
        <div class="content">
            <h2 style="color: #1e293b; margin-top: 0;">Verify Your Email Address</h2>
            <p>Hi {{ $name }}, <br><br>Thank you for choosing Afritrad. Please use the verification code below to complete your sign-in process. This code will expire in 15 minutes.</p>
            
            <div class="otp-box">
                <p class="otp-code">{{ $otp }}</p>
            </div>
            
            <p style="font-size: 14px; color: #94a3b8;">If you did not request this code, please ignore this email or contact support.</p>
        </div>
        <div class="footer">
            &copy; {{ date('Y') }} Afritrad. All rights reserved.
        </div>
    </div>
</body>
</html>
