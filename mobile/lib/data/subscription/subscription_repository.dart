import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';

// M10.1: Abonelik durumu + upgrade.
// proje.md §4.2: 1.250 ₺ aylik, 12.500 ₺ yillik.
class SubscriptionStatus {
  SubscriptionStatus({
    required this.tier,
    required this.isPremium,
    this.expiresAt,
  });

  final String tier; // free | premium
  final bool isPremium;
  final DateTime? expiresAt;

  factory SubscriptionStatus.fromJson(Map<String, dynamic> j) {
    return SubscriptionStatus(
      tier: (j['tier'] as String?) ?? 'free',
      isPremium: (j['is_premium'] as bool?) ?? false,
      expiresAt: j['expires_at'] == null
          ? null
          : DateTime.tryParse(j['expires_at'] as String),
    );
  }

  static SubscriptionStatus free() => SubscriptionStatus(
        tier: 'free',
        isPremium: false,
      );
}

class SubscriptionRepository {
  SubscriptionRepository(this._api);
  final ApiClient _api;

  Future<SubscriptionStatus> fetch() async {
    try {
      final res = await _api.get<Map<String, dynamic>>('/subscription');
      return SubscriptionStatus.fromJson(res.data ?? const {});
    } catch (_) {
      // Offline / 401 → free varsay; UI bozulmasin.
      return SubscriptionStatus.free();
    }
  }

  Future<SubscriptionStatus> upgrade(String period) async {
    final res = await _api.post<Map<String, dynamic>>(
      '/subscription/upgrade',
      data: {'period': period},
    );
    return SubscriptionStatus.fromJson(res.data ?? const {});
  }

  Future<SubscriptionStatus> cancel() async {
    final res = await _api.post<Map<String, dynamic>>('/subscription/cancel');
    return SubscriptionStatus.fromJson(res.data ?? const {});
  }
}

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository(ref.watch(apiClientProvider));
});

// Tum app bunu izler — rozet + gating.
final subscriptionStatusProvider =
    FutureProvider<SubscriptionStatus>((ref) async {
  return ref.watch(subscriptionRepositoryProvider).fetch();
});
