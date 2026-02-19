class AppApiConfig {
  static const String baseUrl = 'https://afritrade.onrender.com/api';

  // Auth endpoints
  static const String login = '$baseUrl/login';
  static const String register = '$baseUrl/register';
  static const String settings = '$baseUrl/settings';

  // KYC endpoints
  static const String kycStatus = '$baseUrl/kyc_status';
  static const String kycVerify = '$baseUrl/kyc/verify';
  static const String kycVerifyBusiness = '$baseUrl/kyc/verify-business';
  static const String kycUpload = '$baseUrl/kyc/upload';

  // Transactions
  static const String transactions = '$baseUrl/transactions';
  static const String fcmToken = '$baseUrl/fcm/token';
  
  // Wallets & Accounts
  static const String wallets = '$baseUrl/wallets';
  static const String virtualAccounts = '$baseUrl/virtual-accounts';
  static const String walletSwap = '$baseUrl/wallets/swap';
  static const String rates = '$baseUrl/rates';
  static const String referrals = '$baseUrl/referrals';
  
  // Cards
  static const String cards = '$baseUrl/cards';

  // Support & Chat
  static const String supportChat = '$baseUrl/support_chat';
  static const String notifications = '$baseUrl/notifications';

  // Withdrawals
  static const String withdraw = '$baseUrl/withdraw';
  static const String withdrawals = '$baseUrl/withdrawals';

  // Security
  static const String pinStatus = '$baseUrl/security/pin/status';
  static const String pinSet = '$baseUrl/security/pin/set';
  static const String pinVerify = '$baseUrl/security/pin/verify';

  // Headers helper
  static Map<String, String> getHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
