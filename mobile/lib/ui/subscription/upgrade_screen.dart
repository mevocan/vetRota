import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/env.dart';
import '../../data/subscription/subscription_repository.dart';
import 'payment_screen.dart';

const Color _green = Color(Env.primaryColorHex);

// M10.1: Free → Premium upgrade ekrani (mobil).
class UpgradeScreen extends ConsumerStatefulWidget {
  const UpgradeScreen({super.key});

  @override
  ConsumerState<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends ConsumerState<UpgradeScreen> {
  bool _loading = false;

  Future<void> _upgrade(String period) async {
    final priceLabel = period == 'yearly' ? '12.500 ₺ / yıl' : '1.250 ₺ / ay';
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PaymentScreen(period: period, priceLabel: priceLabel),
      ),
    );
    if (ok == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _cancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Free pakete dön'),
        content: const Text('Premium özellikleriniz kapanır. Emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Free\'ye dön'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _loading = true);
    try {
      await ref.read(subscriptionRepositoryProvider).cancel();
      ref.invalidate(subscriptionStatusProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(subscriptionStatusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Premium')),
      body: statusAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (status) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: status.isPremium
                ? _premiumActiveView(context, status)
                : _freeUpgradeView(context),
          ),
        ),
      ),
    );
  }

  Widget _premiumActiveView(BuildContext context, SubscriptionStatus status) {
    final expires = status.expiresAt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          color: _green.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: _green.withValues(alpha: 0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: _green, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Premium aktif',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _green,
                        ),
                      ),
                      if (expires != null)
                        Text(
                          'Bitiş: ${expires.day}.${expires.month}.${expires.year}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: _loading ? null : _cancel,
          child: const Text('Free pakete dön'),
        ),
      ],
    );
  }

  Widget _freeUpgradeView(BuildContext context) {
    final features = [
      ('Akıllı rota optimizasyonu', Icons.map),
      ('Çiftçi SMS portalı', Icons.message),
      ('Fotoğraflı muayene', Icons.camera_alt),
      ('Hastalık yayılım haritası', Icons.coronavirus),
      ('Gün sonu PDF raporu', Icons.picture_as_pdf),
      ('Klinik analitik paneli', Icons.bar_chart),
      ('Aşı hatırlatma motoru', Icons.notifications_active),
      ('Dijital reçete PDF', Icons.receipt_long),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Premium\'a geçin',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        const Text(
          'Sahada çalışan veteriner için tüm gelişmiş özellikler.',
          style: TextStyle(color: Colors.black54),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                for (final f in features)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(f.$2, color: _green, size: 22),
                    title: Text(f.$1),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _PriceCard(
                title: 'Aylık',
                price: '1.250 ₺',
                sub: '/ay',
                onTap: _loading ? null : () => _upgrade('monthly'),
                highlighted: false,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PriceCard(
                title: 'Yıllık',
                price: '12.500 ₺',
                sub: '/yıl (≈1.042 ₺/ay)',
                onTap: _loading ? null : () => _upgrade('yearly'),
                highlighted: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 12, color: Colors.black45),
            SizedBox(width: 4),
            Text(
              'Güvenli ödeme — kart bilgileriniz şifrelenir.',
              style: TextStyle(color: Colors.black45, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({
    required this.title,
    required this.price,
    required this.sub,
    required this.onTap,
    required this.highlighted,
  });

  final String title;
  final String price;
  final String sub;
  final VoidCallback? onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: highlighted ? _green : Colors.grey.shade300,
          width: highlighted ? 2 : 1,
        ),
      ),
      color: highlighted ? _green.withValues(alpha: 0.08) : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(title, style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 4),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(sub, style: const TextStyle(fontSize: 11, color: Colors.black54)),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: onTap,
                style: FilledButton.styleFrom(
                  backgroundColor: highlighted ? _green : null,
                ),
                child: const Text('Seç'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
