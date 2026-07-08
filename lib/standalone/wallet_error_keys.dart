/// Shared wallet error/status keys — keep tests and provider aligned.
abstract final class WalletErrorKeys {
  static const treasurySendLocked = 'wallet_treasury_send_locked';
  static const treasuryNoManualFunding = 'wallet_err_treasury_no_manual_funding';
  static const recipientNotFound = 'wallet_err_recipient_not_found';
  static const signInToSend = 'wallet_err_sign_in_to_send';
}