import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/runtime_config.dart';

abstract class PaywallService {
  Future<PaywallStatus> initialize();
  Future<PaywallStatus> refresh();
  Future<PaywallStatus> purchase();
  Future<PaywallStatus> restore();
  Future<void> manageSubscription();
}

class PaywallStatus {
  const PaywallStatus({
    required this.isConfigured,
    required this.isPremium,
    this.lastError,
    this.cancelled = false,
  });

  final bool isConfigured;
  final bool isPremium;
  final String? lastError;
  final bool cancelled;

  PaywallStatus copyWith({
    bool? isConfigured,
    bool? isPremium,
    String? lastError,
    bool? cancelled,
  }) {
    return PaywallStatus(
      isConfigured: isConfigured ?? this.isConfigured,
      isPremium: isPremium ?? this.isPremium,
      lastError: lastError,
      cancelled: cancelled ?? this.cancelled,
    );
  }
}

class RevenueCatPaywallService implements PaywallService {
  PaywallStatus _status = PaywallStatus(
    isConfigured: false,
    isPremium: RuntimeConfig.mockPremiumEntitlement,
  );

  bool get _mockOnly => RuntimeConfig.revenueCatApiKey.trim().isEmpty;

  @override
  Future<PaywallStatus> initialize() async {
    if (_mockOnly) {
      _status = _status.copyWith(
        isConfigured: false,
        lastError:
            'RevenueCat is not configured. Set CHARMLY_REVENUECAT_PUBLIC_KEY for live purchases.',
      );
      return _status;
    }
    try {
      await Purchases.configure(
        PurchasesConfiguration(RuntimeConfig.revenueCatApiKey.trim()),
      );
      return refresh().then((value) {
        _status = value.copyWith(isConfigured: true);
        return _status;
      });
    } catch (e) {
      _status = _status.copyWith(
        isConfigured: false,
        lastError: 'RevenueCat initialization failed: $e',
      );
      return _status;
    }
  }

  @override
  Future<PaywallStatus> refresh() async {
    if (_mockOnly) return _status;
    try {
      final info = await Purchases.getCustomerInfo();
      final premium = info.entitlements.active['premium'] != null;
      _status = PaywallStatus(isConfigured: true, isPremium: premium);
      return _status;
    } catch (e) {
      return _status.copyWith(lastError: 'Failed to refresh entitlement: $e');
    }
  }

  @override
  Future<PaywallStatus> purchase() async {
    if (_mockOnly) {
      return _status.copyWith(
        lastError:
            'Premium purchasing is unavailable in mock mode. Configure RevenueCat to enable purchases.',
      );
    }
    try {
      final offerings = await Purchases.getOfferings();
      final packages = offerings.current?.availablePackages ?? <Package>[];
      final packageToBuy = packages.isEmpty ? null : packages.first;
      if (packageToBuy == null) {
        return _status.copyWith(lastError: 'No purchasable package available.');
      }
      final result = await Purchases.purchasePackage(packageToBuy);
      final premium = result.customerInfo.entitlements.active['premium'] != null;
      _status = PaywallStatus(isConfigured: true, isPremium: premium);
      return _status;
    } catch (e) {
      final cancelled = e.toString().contains('purchaseCancelledError');
      return _status.copyWith(
        cancelled: cancelled,
        lastError: cancelled ? null : 'Purchase failed: $e',
      );
    }
  }

  @override
  Future<PaywallStatus> restore() async {
    if (_mockOnly) return _status;
    try {
      final info = await Purchases.restorePurchases();
      final premium = info.entitlements.active['premium'] != null;
      _status = PaywallStatus(isConfigured: true, isPremium: premium);
      return _status;
    } catch (e) {
      return _status.copyWith(lastError: 'Restore failed: $e');
    }
  }

  @override
  Future<void> manageSubscription() async {
    final uri = Uri.parse(
      'https://www.apple.com/legal/internet-services/itunes/manage-subscriptions/',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
