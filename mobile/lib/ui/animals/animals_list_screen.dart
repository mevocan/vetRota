import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/env.dart';
import '../../data/animals/animals_repository.dart';
import '../../data/auth/auth_repository.dart';
import '../../data/db/app_database.dart';
import '../../data/sync/sync_repository.dart';
import '../appointments/appointments_today_screen.dart';
import '../sync/conflicts_screen.dart';
import 'animal_detail_screen.dart';
import 'animal_form_screen.dart';
import 'bulk_vaccination_sheet.dart';
import 'upcoming_births_screen.dart';
import '../../data/animals/animals_repository.dart' show upcomingBirthsProvider;

const Color _green = Color(Env.primaryColorHex);

class AnimalsListScreen extends ConsumerStatefulWidget {
  const AnimalsListScreen({super.key});

  @override
  ConsumerState<AnimalsListScreen> createState() => _AnimalsListScreenState();
}

class _AnimalsListScreenState extends ConsumerState<AnimalsListScreen> {
  bool _syncing = false;

  // M7.5.1: secim modu — long-press ile baslar, set bosalinca cikar.
  final Set<String> _selectedIds = {};
  bool get _selectionMode => _selectedIds.isNotEmpty;

  void _toggleSelect(AnimalRow a) {
    setState(() {
      if (_selectedIds.contains(a.id)) {
        _selectedIds.remove(a.id);
      } else {
        _selectedIds.add(a.id);
      }
    });
  }

  void _clearSelection() => setState(_selectedIds.clear);

  Future<void> _openBulkVaccination(List<AnimalRow> all) async {
    final selected = all.where((a) => _selectedIds.contains(a.id)).toList();
    if (selected.isEmpty) return;

    // M7.5.4: ayni ciftci / ayni tur kisiti — farkliysa uyar.
    final farmerIds = selected.map((a) => a.farmerId).toSet();
    final speciesSet = selected.map((a) => a.species).toSet();
    if (farmerIds.length > 1 || speciesSet.length > 1) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Karisik secim'),
          content: Text(
            'Secili hayvanlar farkli '
            '${farmerIds.length > 1 ? "ciftcilere" : ""}'
            '${farmerIds.length > 1 && speciesSet.length > 1 ? " ve " : ""}'
            '${speciesSet.length > 1 ? "turlere" : ""}'
            ' ait. Devam etmek istiyor musunuz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Iptal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Devam et'),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

    final done = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BulkVaccinationSheet(animals: selected),
    );

    if (!mounted) return;
    if (done != null && done > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$done hayvana asi uygulandi (sync bekliyor)')),
      );
      _clearSelection();
    }
  }

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

  // Saha kullanicisi icin teknik DioException yerine sadelestirilmis
  // mesaj. Pending kayitlar Drift'te kaliyor; internet gelince tekrar
  // sync etmesi yeterli.
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

  @override
  Widget build(BuildContext context) {
    final animalsAsync = ref.watch(animalsListProvider);
    final pendingAsync = ref.watch(pendingCountProvider);
    final conflictsAsync = ref.watch(syncConflictsProvider);
    final birthsAsync = ref.watch(upcomingBirthsProvider);

    return Scaffold(
      appBar: _selectionMode
          ? AppBar(
              backgroundColor: _green,
              foregroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Secimi iptal et',
                onPressed: _clearSelection,
              ),
              title: Text('${_selectedIds.length} secildi'),
              actions: [
                animalsAsync.maybeWhen(
                  data: (all) => IconButton(
                    icon: const Icon(Icons.vaccines),
                    tooltip: 'Toplu asi',
                    onPressed: () => _openBulkVaccination(all),
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            )
          : AppBar(
        title: const Text('Hayvanlar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.event),
            tooltip: 'Bugunun randevulari',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AppointmentsTodayScreen(),
                ),
              );
            },
          ),
          // Yaklasan dogumlar — badge'de sayi
          birthsAsync.maybeWhen(
            data: (rows) => rows.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: Badge(
                      label: Text('${rows.length}'),
                      backgroundColor: Colors.pink,
                      child: const Icon(Icons.pregnant_woman),
                    ),
                    tooltip: 'Yaklasan dogumlar',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const UpcomingBirthsScreen(),
                        ),
                      );
                    },
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
          // Catisma rozeti
          conflictsAsync.maybeWhen(
            data: (rows) => rows.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: Badge(
                      label: Text('${rows.length}'),
                      child: const Icon(Icons.warning_amber),
                    ),
                    tooltip: 'Catismalar',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ConflictsScreen(),
                        ),
                      );
                    },
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
          // Sync butonu + bekleyen sayisi
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
            onPressed: () async {
              await ref.read(authRepositoryProvider).logout();
              ref.invalidate(sessionPresentProvider);
            },
          ),
        ],
      ),
      floatingActionButton: _selectionMode
          ? null
          : FloatingActionButton.extended(
              backgroundColor: _green,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Yeni hayvan'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AnimalFormScreen()),
                );
              },
            ),
      body: animalsAsync.when(
        // Drift stream ilk ackta synchronously gelir — bu loading
        // gercekten kisa anlik bir state, "ag bekleme" degil.
        loading: () => const SizedBox.shrink(),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (animals) {
          if (animals.isEmpty) {
            return const _EmptyState();
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: animals.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) => _AnimalTile(
              animal: animals[i],
              selected: _selectedIds.contains(animals[i].id),
              selectionMode: _selectionMode,
              onLongPress: () => _toggleSelect(animals[i]),
              onTapInSelectionMode: () => _toggleSelect(animals[i]),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pets, size: 64, color: Colors.black26),
            const SizedBox(height: 16),
            const Text(
              'Henuz hayvan kaydi yok',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Sag alttaki "Yeni hayvan" butonu ile ekleyin.',
              style: TextStyle(color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimalTile extends StatelessWidget {
  const _AnimalTile({
    required this.animal,
    this.selected = false,
    this.selectionMode = false,
    this.onLongPress,
    this.onTapInSelectionMode,
  });
  final AnimalRow animal;
  final bool selected;
  final bool selectionMode;
  final VoidCallback? onLongPress;
  final VoidCallback? onTapInSelectionMode;

  @override
  Widget build(BuildContext context) {
    final title = animal.name?.isNotEmpty == true
        ? animal.name!
        : (animal.earTag?.isNotEmpty == true
            ? 'Kupe ${animal.earTag}'
            : 'Isimsiz hayvan');

    final subtitleParts = <String>[
      animal.species,
      if (animal.breed?.isNotEmpty == true) animal.breed!,
      if (animal.weightKg != null) '${animal.weightKg!.toStringAsFixed(0)} kg',
    ];

    return Builder(
      builder: (context) => ListTile(
        tileColor: selected ? _green.withValues(alpha: 0.12) : null,
        leading: selectionMode
            ? Checkbox(
                value: selected,
                onChanged: (_) => onTapInSelectionMode?.call(),
              )
            : const CircleAvatar(
                backgroundColor: _green,
                child: Icon(Icons.pets, color: Colors.white),
              ),
        title: Row(
          children: [
            Flexible(child: Text(title, overflow: TextOverflow.ellipsis)),
            if (animal.isPregnant) ...[
              const SizedBox(width: 6),
              const Tooltip(
                message: 'Gebe',
                child: Icon(Icons.pregnant_woman,
                    size: 16, color: Colors.pink),
              ),
            ],
          ],
        ),
        subtitle: Text(subtitleParts.join(' • ')),
        trailing: _SyncBadge(status: animal.localSyncStatus),
        onLongPress: onLongPress,
        onTap: () {
          if (selectionMode) {
            onTapInSelectionMode?.call();
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AnimalDetailScreen(animal: animal),
            ),
          );
        },
      ),
    );
  }
}

class _SyncBadge extends StatelessWidget {
  const _SyncBadge({required this.status});
  final LocalSyncStatus status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case LocalSyncStatus.synced:
        return const Icon(Icons.cloud_done, color: Colors.green, size: 20);
      case LocalSyncStatus.pending:
        return const Tooltip(
          message: 'Senkronizasyon bekliyor',
          child: Icon(Icons.cloud_upload, color: Colors.orange, size: 20),
        );
      case LocalSyncStatus.failed:
        return const Tooltip(
          message: 'Senkronizasyon basarisiz',
          child: Icon(Icons.cloud_off, color: Colors.red, size: 20),
        );
    }
  }
}
