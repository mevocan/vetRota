import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';

import '../../config/env.dart';
import '../../data/prescriptions/prescriptions_repository.dart';

const Color _green = Color(Env.primaryColorHex);

class PrescriptionsListScreen extends ConsumerStatefulWidget {
  const PrescriptionsListScreen({super.key});

  @override
  ConsumerState<PrescriptionsListScreen> createState() =>
      _PrescriptionsListScreenState();
}

class _PrescriptionsListScreenState
    extends ConsumerState<PrescriptionsListScreen> {
  String _query = '';
  String? _downloadingId;

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(prescriptionsListProvider(_query));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receteler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
            onPressed: () =>
                ref.invalidate(prescriptionsListProvider(_query)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Ara (no, ciftci, hayvan)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (v) => setState(() => _query = v),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(Icons.cloud, size: 14, color: Colors.grey),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Receteler online listelenir; internet gerekli.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: list.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off,
                          size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text(
                          'Receteler alinamadi. Internet baglantisini kontrol edin.'),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () =>
                            ref.invalidate(prescriptionsListProvider(_query)),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tekrar dene'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (rows) {
                if (rows.isEmpty) {
                  return const Center(child: Text('Recete yok'));
                }
                return ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final p = rows[i];
                    final downloading = _downloadingId == p.id;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _green.withValues(alpha: 0.15),
                        child: const Icon(Icons.receipt, color: _green),
                      ),
                      title: Text(
                        p.prescriptionNumber ?? p.id.substring(0, 8),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        [
                          if (p.animal != null) p.animal!.label,
                          if (p.farmer != null) p.farmer!.fullName,
                          if (p.createdAt != null) _fmtDate(p.createdAt!),
                        ].join(' · '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: downloading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2),
                            )
                          : IconButton(
                              icon: const Icon(Icons.picture_as_pdf),
                              tooltip: 'PDF indir',
                              onPressed: () => _download(p.id),
                            ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _download(String id) async {
    setState(() => _downloadingId = id);
    try {
      final file = await ref
          .read(prescriptionsRepositoryProvider)
          .downloadPdf(id);
      if (!mounted) return;
      await OpenFilex.open(file.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF indirilemedi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _downloadingId = null);
    }
  }

  static String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.'
      '${d.month.toString().padLeft(2, '0')}.${d.year}';
}
