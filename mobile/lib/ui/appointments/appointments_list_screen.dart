import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/env.dart';
import '../../data/appointments/appointments_repository.dart';
import 'appointment_detail_screen.dart';
import 'appointment_form_screen.dart';
import 'appointments_today_screen.dart';

const Color _green = Color(Env.primaryColorHex);

class AppointmentsListScreen extends ConsumerStatefulWidget {
  const AppointmentsListScreen({super.key});

  @override
  ConsumerState<AppointmentsListScreen> createState() =>
      _AppointmentsListScreenState();
}

class _AppointmentsListScreenState
    extends ConsumerState<AppointmentsListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Randevular'),
        actions: [
          IconButton(
            tooltip: 'Bugun (harita + rota)',
            icon: const Icon(Icons.map),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AppointmentsTodayScreen(),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Bugun'),
            Tab(text: 'Yaklasan'),
            Tab(text: 'Gecmis'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Yeni'),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AppointmentFormScreen()),
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _AppointmentTab(
            asyncList: ref.watch(todayAppointmentsProvider),
            emptyText: 'Bugun randevu yok',
          ),
          _AppointmentTab(
            asyncList: ref.watch(upcomingAppointmentsProvider),
            emptyText: 'Yaklasan randevu yok',
            groupByDay: true,
          ),
          _AppointmentTab(
            asyncList: ref.watch(pastAppointmentsProvider),
            emptyText: 'Gecmis randevu yok',
            groupByDay: true,
          ),
        ],
      ),
    );
  }
}

class _AppointmentTab extends StatelessWidget {
  const _AppointmentTab({
    required this.asyncList,
    required this.emptyText,
    this.groupByDay = false,
  });

  final AsyncValue<List<AppointmentWithMeta>> asyncList;
  final String emptyText;
  final bool groupByDay;

  @override
  Widget build(BuildContext context) {
    return asyncList.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Hata: $e')),
      data: (rows) {
        if (rows.isEmpty) return Center(child: Text(emptyText));
        if (!groupByDay) {
          return ListView.separated(
            itemCount: rows.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) => _AppointmentTile(item: rows[i]),
          );
        }
        // Tarihe gore grupla.
        final groups = <DateTime, List<AppointmentWithMeta>>{};
        for (final r in rows) {
          final d = DateTime(r.row.scheduledAt.year,
              r.row.scheduledAt.month, r.row.scheduledAt.day);
          groups.putIfAbsent(d, () => []).add(r);
        }
        final keys = groups.keys.toList();
        return ListView.builder(
          itemCount: keys.length,
          itemBuilder: (_, i) {
            final day = keys[i];
            final items = groups[day]!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: Colors.grey.shade100,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  child: Text(
                    _formatDay(day),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
                for (final it in items) ...[
                  _AppointmentTile(item: it),
                  const Divider(height: 1),
                ],
              ],
            );
          },
        );
      },
    );
  }

  static const _months = [
    '', 'Oca', 'Sub', 'Mar', 'Nis', 'May', 'Haz',
    'Tem', 'Agu', 'Eyl', 'Eki', 'Kas', 'Ara'
  ];

  static String _formatDay(DateTime d) {
    final today = DateTime.now();
    final t = DateTime(today.year, today.month, today.day);
    if (d == t) return 'Bugun';
    if (d == t.add(const Duration(days: 1))) return 'Yarin';
    if (d == t.subtract(const Duration(days: 1))) return 'Dun';
    return '${d.day} ${_months[d.month]} ${d.year}';
  }
}

class _AppointmentTile extends StatelessWidget {
  const _AppointmentTile({required this.item});
  final AppointmentWithMeta item;

  @override
  Widget build(BuildContext context) {
    final dt = item.row.scheduledAt;
    final time =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    final status = item.row.status;
    final crossed = status == 'completed' || status == 'cancelled';
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _statusColor(status).withValues(alpha: 0.15),
        child: Icon(_statusIcon(status), color: _statusColor(status)),
      ),
      title: Text(
        item.title,
        style: TextStyle(
          decoration: crossed ? TextDecoration.lineThrough : null,
          color: crossed ? Colors.grey : null,
        ),
      ),
      subtitle: Text(
        [time, item.subtitle].where((s) => s.isNotEmpty).join(' · '),
      ),
      trailing: item.row.reason != null && item.row.reason!.isNotEmpty
          ? const Icon(Icons.notes, size: 16, color: Colors.grey)
          : null,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AppointmentDetailScreen(
            appointmentId: item.row.id,
          ),
        ),
      ),
    );
  }

  static IconData _statusIcon(String s) {
    switch (s) {
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'in_progress':
        return Icons.play_circle;
      case 'no_show':
        return Icons.remove_circle;
      case 'confirmed':
        return Icons.event_available;
      default:
        return Icons.event;
    }
  }

  static Color _statusColor(String s) {
    switch (s) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'in_progress':
        return Colors.blue;
      case 'no_show':
        return Colors.grey;
      case 'confirmed':
        return Colors.teal;
      default:
        return Colors.orange;
    }
  }
}
