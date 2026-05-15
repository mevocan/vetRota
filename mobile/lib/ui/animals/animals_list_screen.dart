import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/env.dart';
import '../../data/animals/animals_repository.dart';
import '../../data/db/app_database.dart';
import 'animal_detail_screen.dart';
import 'animal_form_screen.dart';
import 'bulk_vaccination_sheet.dart';

const Color _green = Color(Env.primaryColorHex);

class AnimalsListScreen extends ConsumerStatefulWidget {
  const AnimalsListScreen({super.key});

  @override
  ConsumerState<AnimalsListScreen> createState() => _AnimalsListScreenState();
}

class _AnimalsListScreenState extends ConsumerState<AnimalsListScreen> {
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
    if (!mounted) return;

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

  @override
  Widget build(BuildContext context) {
    final animalsAsync = ref.watch(animalsListProvider);

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
