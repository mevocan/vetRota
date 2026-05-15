import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/env.dart';
import '../../data/db/app_database.dart';
import '../../data/medical_records/medical_records_repository.dart';

const Color _green = Color(Env.primaryColorHex);

// Mevcut muayene icin "basit" duzenleme — sadece metin/vital alanlar.
// Ilac listesi degistirilmez (stok ledger karmasiklik).
class MedicalRecordEditScreen extends ConsumerStatefulWidget {
  const MedicalRecordEditScreen({super.key, required this.record});

  final MedicalRecordRow record;

  @override
  ConsumerState<MedicalRecordEditScreen> createState() =>
      _MedicalRecordEditScreenState();
}

class _MedicalRecordEditScreenState
    extends ConsumerState<MedicalRecordEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _chief;
  late final TextEditingController _symptoms;
  late final TextEditingController _diagnosis;
  late final TextEditingController _treatment;
  late final TextEditingController _reco;
  late final TextEditingController _temperature;
  late final TextEditingController _weight;
  late final TextEditingController _hr;
  late final TextEditingController _rr;
  late final TextEditingController _fee;
  late DateTime _examinedAt;
  late String _visitType;
  late bool _followUp;
  DateTime? _followUpDate;
  bool _saving = false;

  static const _visitTypes = [
    ('routine', 'Rutin'),
    ('emergency', 'Acil'),
    ('vaccination', 'Asilama'),
    ('follow_up', 'Kontrol'),
  ];

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    _chief = TextEditingController(text: r.chiefComplaint ?? '');
    _symptoms = TextEditingController(text: r.symptoms ?? '');
    _diagnosis = TextEditingController(text: r.diagnosisNotes ?? '');
    _treatment = TextEditingController(text: r.treatmentNotes ?? '');
    _reco = TextEditingController(text: r.recommendations ?? '');
    _temperature =
        TextEditingController(text: r.temperatureCelsius?.toString() ?? '');
    _weight = TextEditingController(text: r.weightKg?.toString() ?? '');
    _hr = TextEditingController(text: r.heartRate?.toString() ?? '');
    _rr = TextEditingController(text: r.respiratoryRate?.toString() ?? '');
    _fee = TextEditingController(text: r.serviceFee?.toString() ?? '');
    _examinedAt = r.examinedAt;
    _visitType = r.visitType;
    _followUp = r.followUpNeeded;
    _followUpDate = r.followUpDate;
  }

  @override
  void dispose() {
    _chief.dispose();
    _symptoms.dispose();
    _diagnosis.dispose();
    _treatment.dispose();
    _reco.dispose();
    _temperature.dispose();
    _weight.dispose();
    _hr.dispose();
    _rr.dispose();
    _fee.dispose();
    super.dispose();
  }

  Future<void> _pickExaminedAt() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _examinedAt,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_examinedAt),
    );
    if (time == null) return;
    setState(() => _examinedAt =
        DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  Future<void> _pickFollowUp() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _followUpDate ??
          DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _followUpDate = picked);
  }

  double? _parseDouble(String s) =>
      double.tryParse(s.trim().replaceAll(',', '.'));
  int? _parseInt(String s) => int.tryParse(s.trim());

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(medicalRecordsRepositoryProvider).updateBasic(
            id: widget.record.id,
            examinedAt: _examinedAt,
            visitType: _visitType,
            chiefComplaint: _chief.text.trim().isEmpty
                ? null
                : _chief.text.trim(),
            symptoms: _symptoms.text.trim().isEmpty
                ? null
                : _symptoms.text.trim(),
            diagnosisNotes: _diagnosis.text.trim().isEmpty
                ? null
                : _diagnosis.text.trim(),
            treatmentNotes: _treatment.text.trim().isEmpty
                ? null
                : _treatment.text.trim(),
            recommendations: _reco.text.trim().isEmpty
                ? null
                : _reco.text.trim(),
            temperatureCelsius: _parseDouble(_temperature.text),
            weightKg: _parseDouble(_weight.text),
            heartRate: _parseInt(_hr.text),
            respiratoryRate: _parseInt(_rr.text),
            serviceFee: _parseDouble(_fee.text),
            followUpNeeded: _followUp,
            followUpDate: _followUp ? _followUpDate : null,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Muayene guncellendi (sync bekliyor)')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kayit hatasi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dt = _examinedAt;
    return Scaffold(
      appBar: AppBar(title: const Text('Muayeneyi duzenle')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              InkWell(
                onTap: _pickExaminedAt,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Muayene zamani',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${dt.day.toString().padLeft(2, '0')}.'
                    '${dt.month.toString().padLeft(2, '0')}.${dt.year} '
                    '${dt.hour.toString().padLeft(2, '0')}:'
                    '${dt.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _visitType,
                decoration: const InputDecoration(
                  labelText: 'Tip',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final (v, l) in _visitTypes)
                    DropdownMenuItem(value: v, child: Text(l)),
                ],
                onChanged: (v) =>
                    setState(() => _visitType = v ?? 'routine'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _chief,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Sikayet',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _symptoms,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Belirtiler',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _diagnosis,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Tani',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _treatment,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Tedavi notlari',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _reco,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Oneriler',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _temperature,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9.,]')),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Sicaklik (°C)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _weight,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9.,]')),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Agirlik (kg)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _hr,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Nabiz',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _rr,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Solunum',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _fee,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Hizmet bedeli (TL)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Takip gerekli'),
                value: _followUp,
                activeThumbColor: _green,
                onChanged: (v) => setState(() => _followUp = v),
              ),
              if (_followUp)
                InkWell(
                  onTap: _pickFollowUp,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Takip tarihi',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.event),
                    ),
                    child: Text(
                      _followUpDate == null
                          ? 'Sec...'
                          : '${_followUpDate!.day.toString().padLeft(2, '0')}.'
                              '${_followUpDate!.month.toString().padLeft(2, '0')}.'
                              '${_followUpDate!.year}',
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: _green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Kaydet', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
