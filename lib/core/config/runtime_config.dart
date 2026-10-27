class RuntimeConfig {
  RuntimeConfig._();

  static const String backendBaseUrl = String.fromEnvironment(
    'CHARMLY_BACKEND_BASE_URL',
    defaultValue: '',
  );

  static const bool mockAiMode = bool.fromEnvironment(
    'CHARMLY_MOCK_AI_MODE',
    defaultValue: true,
  );

  static const String revenueCatApiKey = String.fromEnvironment(
    'CHARMLY_REVENUECAT_PUBLIC_KEY',
    defaultValue: '',
  );

  static const bool mockPremiumEntitlement = bool.fromEnvironment(
    'CHARMLY_MOCK_PREMIUM',
    defaultValue: false,
  );
}
