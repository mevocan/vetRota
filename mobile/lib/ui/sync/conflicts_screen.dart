import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/sync/sync_repository.dart';

// Sync sirasinda LWW karsilastirmasi sonrasi server tarafindan kaydedilen
// conflict log'u — burada sadece liste; "kazanan" ve server_version
// gosterilir.
class ConflictsScreen extends ConsumerWidget {
  const ConflictsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(syncConflictsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Senkronizasyon catismalari')),
      body: asyncList.when(
        loading: () => const SizedBox.shrink(),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (rows) {
          if (rows.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Catisma yok.'),
              ),
            );
          }
          return ListView.separated(
            itemCount: rows.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final r = rows[i];
              final when = r.observedAt.toLocal().toString().split('.').first;
              return ListTile(
                leading: Icon(
                  r.resolution == 'client_won'
                      ? Icons.cloud_upload
                      : Icons.cloud_download,
                  color: Colors.orange,
                ),
                title: Text('${r.targetTable} · ${r.recordId.substring(0, 8)}…'),
                subtitle: Text(
                  'Cozum: ${r.resolution}'
                  '${r.serverVersion != null ? ' · sunucu v${r.serverVersion}' : ''}'
                  '\n$when',
                ),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}
