import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/env.dart';
import '../../data/animals/animals_repository.dart';
import '../../data/auth/auth_repository.dart';
import '../../data/sync/sync_repository.dart';
import '../animals/animals_list_screen.dart';
import '../animals/upcoming_births_screen.dart';
import '../appointments/appointments_list_screen.dart';
import '../farmers/farmers_list_screen.dart';
import '../medical_records/medical_records_list_screen.dart';
import '../medications/medications_list_screen.dart';
import '../sync/conflicts_screen.dart';

const Color _green = Color(Env.primaryColorHex);

// VetRota ana panel. Login sonrasi gelinen ekran.
// - Ust ozet kartlar (bugunku randevu, pending sync, yaklasan dogum)
// - Modul grid kartlari
// - AppBar: sync, catismalar, cikis
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _syncing = false;

  Future<void> _runSync() async {
    if (_syncing) return;
    setState(() => _syncing = true);
    try {
      final result = await ref.read(syncRepositoryProvider).sync();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sync: ${result.acceptedCount} kabul'
            '${result.conflictCount > 0 ? ' · ${result.conflictCount} catisma' : ''}'
            '${result.rejectedCount > 0 ? ' · ${result.rejectedCount} reddedildi' : ''}'
            '${result.photosUploaded > 0 ? ' · ${result.photosUploaded} foto' : ''}'
            '${result.photosFailed > 0 ? ' · ${result.photosFailed} foto-hata' : ''}'
            ' · ${result.pulledCount} cekildi',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_friendlySyncError(e))),
      );
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  String _friendlySyncError(Object e) {
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionError:
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Internet yok. Kayitlariniz cihazda saklandi, '
              'baglanti gelince Sync\'e tekrar basin.';
        case DioExceptionType.badResponse:
          final code = e.response?.statusCode;
          if (code == 401) {
            return 'Oturum suresi doldu. Lutfen tekrar giris yapin.';
          }
          if (code != null && code >= 500) {
            return 'Sunucu hatasi ($code). Birazdan tekrar deneyin.';
          }
          return 'Sunucu reddetti ($code).';
        case DioExceptionType.cancel:
          return 'Sync iptal edildi.';
        case DioExceptionType.badCertificate:
        case DioExceptionType.unknown:
          return 'Baglanti hatasi. Internet baglantinizi kontrol edin.';
      }
    }
    return 'Sync hatasi: $e';
  }

  Future<void> _logout() async {
    await ref.read(authRepositoryProvider).logout();
    ref.invalidate(sessionPresentProvider);
  }

  @override
  Widget build(BuildContext context) {
    final pendingAsync = ref.watch(pendingCountProvider);
    final conflictsAsync = ref.watch(syncConflictsProvider);
    final birthsAsync = ref.watch(upcomingBirthsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Image.asset(
                'assets/branding/logo2.png',
                height: 28,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            const Text('VetRota'),
          ],
        ),
        actions: [
          conflictsAsync.maybeWhen(
            data: (rows) => rows.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: Badge(
                      label: Text('${rows.length}'),
                      child: const Icon(Icons.warning_amber),
                    ),
                    tooltip: 'Catismalar',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ConflictsScreen(),
                      ),
                    ),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
          pendingAsync.maybeWhen(
            data: (count) => IconButton(
              icon: Badge(
                isLabelVisible: count > 0,
                label: Text('$count'),
                child: _syncing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.sync),
              ),
              tooltip: 'Senkronize et',
              onPressed: _syncing ? null : _runSync,
            ),
            orElse: () => IconButton(
              icon: const Icon(Icons.sync),
              tooltip: 'Senkronize et',
              onPressed: _syncing ? null : _runSync,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cikis',
            onPressed: _logout,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _runSync,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Ust ozet seridi
              _SummaryStrip(
                pending: pendingAsync.maybeWhen(
                  data: (v) => v,
                  orElse: () => 0,
                ),
                conflicts: conflictsAsync.maybeWhen(
                  data: (v) => v.length,
                  orElse: () => 0,
                ),
                upcomingBirths: birthsAsync.maybeWhen(
                  data: (v) => v.length,
                  orElse: () => 0,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Moduller',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  _ModuleCard(
                    icon: Icons.pets,
                    label: 'Hayvanlar',
                    color: _green,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AnimalsListScreen(),
                      ),
                    ),
                  ),
                  _ModuleCard(
                    icon: Icons.people,
                    label: 'Ciftciler',
                    color: Colors.blue.shade700,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FarmersListScreen(),
                      ),
                    ),
                  ),
                  _ModuleCard(
                    icon: Icons.event,
                    label: 'Randevular',
                    color: Colors.orange.shade700,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AppointmentsListScreen(),
                      ),
                    ),
                  ),
                  _ModuleCard(
                    icon: Icons.pregnant_woman,
                    label: 'Yaklasan dogumlar',
                    color: Colors.pink.shade400,
                    badge: birthsAsync.maybeWhen(
                      data: (rows) => rows.isEmpty ? null : rows.length,
                      orElse: () => null,
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const UpcomingBirthsScreen(),
                      ),
                    ),
                  ),
                  _ModuleCard(
                    icon: Icons.medication,
                    label: 'Ilaclar',
                    color: Colors.teal.shade600,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MedicationsListScreen(),
                      ),
                    ),
                  ),
                  _ModuleCard(
                    icon: Icons.vaccines,
                    label: 'Asi planlari',
                    color: Colors.purple.shade400,
                    disabled: true,
                    onTap: () => _comingSoon(context, 'Asi planlari'),
                  ),
                  _ModuleCard(
                    icon: Icons.receipt_long,
                    label: 'Muayeneler',
                    color: Colors.indigo.shade400,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MedicalRecordsListScreen(),
                      ),
                    ),
                  ),
                  _ModuleCard(
                    icon: Icons.payments,
                    label: 'Borc / odeme',
                    color: Colors.brown.shade400,
                    disabled: true,
                    onTap: () => _comingSoon(context, 'Borc/odeme ledger'),
                  ),
                  _ModuleCard(
                    icon: Icons.map,
                    label: 'Hastalik haritasi',
                    color: Colors.red.shade400,
                    disabled: true,
                    onTap: () => _comingSoon(context, 'Hastalik haritasi'),
                  ),
                  _ModuleCard(
                    icon: Icons.settings,
                    label: 'Ayarlar',
                    color: Colors.grey.shade600,
                    disabled: true,
                    onTap: () => _comingSoon(context, 'Ayarlar'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _comingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label cok yakinda (M9)')),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({
    required this.pending,
    required this.conflicts,
    required this.upcomingBirths,
  });

  final int pending;
  final int conflicts;
  final int upcomingBirths;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Bekleyen sync',
            value: '$pending',
            color: pending > 0 ? Colors.orange : Colors.grey,
            icon: Icons.sync,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: 'Catismalar',
            value: '$conflicts',
            color: conflicts > 0 ? Colors.red : Colors.grey,
            icon: Icons.warning_amber,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: 'Yaklasan dogum',
            value: '$upcomingBirths',
            color: upcomingBirths > 0 ? Colors.pink : Colors.grey,
            icon: Icons.pregnant_woman,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: color.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.badge,
    this.disabled = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final int? badge;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final effective = disabled ? Colors.grey.shade400 : color;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: effective.withValues(alpha: 0.25)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, size: 40, color: effective),
                  if (badge != null && badge! > 0)
                    Positioned(
                      right: -12,
                      top: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.pink,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$badge',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: effective,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (disabled)
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Text(
                    'yakinda',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
