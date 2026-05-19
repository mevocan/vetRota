import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/env.dart';
import '../../data/auth/auth_repository.dart';
import '../../data/auth/auth_storage.dart';
import '../../data/subscription/subscription_repository.dart';
import '../../data/sync/sync_repository.dart';
import '../subscription/upgrade_screen.dart';

const Color _green = Color(Env.primaryColorHex);

// Profil + ayarlar + cikis. Mobil offline-first oldugu icin ayarlar
// cogunlukla okuma — sahada degisiklik gerekirse buradan.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.watch(authStorageProvider);
    final pendingAsync = ref.watch(pendingCountProvider);
    final conflictsAsync = ref.watch(syncConflictsProvider);
    final subAsync = ref.watch(subscriptionStatusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          FutureBuilder<String?>(
            future: storage.readEmail(),
            builder: (_, snap) {
              final email = snap.data ?? '—';
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: _green,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: const Text('Giris yapan kullanici'),
                subtitle: Text(email),
              );
            },
          ),
          FutureBuilder<String?>(
            future: storage.readClinicId(),
            builder: (_, snap) {
              final clinic = snap.data ?? '—';
              return ListTile(
                leading: const Icon(Icons.business),
                title: const Text('Klinik ID'),
                subtitle: Text(clinic),
              );
            },
          ),
          FutureBuilder<String>(
            future: storage.ensureDeviceId(),
            builder: (_, snap) {
              final dev = snap.data ?? '—';
              return ListTile(
                leading: const Icon(Icons.smartphone),
                title: const Text('Cihaz ID'),
                subtitle: Text(dev),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Bekleyen sync kaydi'),
            subtitle: pendingAsync.when(
              data: (n) => Text('$n kayit'),
              error: (e, _) => Text('Hata: $e'),
              loading: () => const Text('...'),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.warning_amber),
            title: const Text('Cozumlenmemis catismalar'),
            subtitle: conflictsAsync.when(
              data: (rows) => Text('${rows.length} catisma'),
              error: (e, _) => Text('Hata: $e'),
              loading: () => const Text('...'),
            ),
          ),
          FutureBuilder<DateTime?>(
            future: ref.read(syncRepositoryProvider).readLastSyncedLocal(),
            builder: (_, snap) {
              final t = snap.data;
              return ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Son sync zamani'),
                subtitle: Text(t == null ? 'Henuz yok' : _fmtFull(t)),
              );
            },
          ),
          const Divider(),
          subAsync.when(
            loading: () => const ListTile(
              leading: Icon(Icons.workspace_premium),
              title: Text('Paket'),
              subtitle: Text('Yukleniyor...'),
            ),
            error: (e, _) => const ListTile(
              leading: Icon(Icons.workspace_premium),
              title: Text('Paket'),
              subtitle: Text('Bilgi alinamadi'),
            ),
            data: (status) => ListTile(
              leading: Icon(
                status.isPremium ? Icons.auto_awesome : Icons.lock_outline,
                color: status.isPremium ? Colors.amber.shade700 : Colors.grey,
              ),
              title: Text(status.isPremium ? 'Premium paket' : 'Free paket'),
              subtitle: Text(
                status.isPremium
                    ? (status.expiresAt == null
                        ? 'Aktif'
                        : 'Bitis: ${_fmtDate(status.expiresAt!)}')
                    : 'Premium\'a gecmek icin dokunun',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const UpgradeScreen()),
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Hakkinda'),
            subtitle: const Text('VetRota — gezici veteriner platformu'),
            trailing: const Text('v0.9 MVP'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cikis yap',
                style: TextStyle(color: Colors.red)),
            onTap: () => _confirmLogout(context, ref),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final pending = await ref.read(pendingCountProvider.future);
    if (!context.mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cikis yap'),
        content: Text(
          pending > 0
              ? 'Bekleyen $pending sync kaydi var. Cikis token\'i siler, '
                  'kayitlar cihazda kalir; tekrar giris yaptiginizda devam '
                  'eder.'
              : 'Cikis yapmak istediginize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Iptal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cikis yap'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(authRepositoryProvider).logout();
      ref.invalidate(sessionPresentProvider);
    }
  }

  static String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.'
      '${d.month.toString().padLeft(2, '0')}.${d.year}';

  static String _fmtFull(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.'
      '${d.month.toString().padLeft(2, '0')}.${d.year} '
      '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}';
}
