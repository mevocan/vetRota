import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/env.dart';
import '../../data/db/app_database.dart';
import '../../data/medical_records/medical_records_repository.dart';
import '../../data/photos/photos_repository.dart';

const Color _green = Color(Env.primaryColorHex);

// Bir hayvan icin yeni muayene formu. Tum yazma transaction icinde
// (medical_record + medical_record_drugs + stock_movements + stocks).
class MedicalRecordFormScreen extends ConsumerStatefulWidget {
  const MedicalRecordFormScreen({super.key, required this.animal});

  final AnimalRow animal;

  @override
  ConsumerState<MedicalRecordFormScreen> createState() =>
      _MedicalRecordFormScreenState();
}

class _MedicalRecordFormScreenState
    extends ConsumerState<MedicalRecordFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _chiefComplaintController = TextEditingController();
  final _symptomsController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _weightController = TextEditingController();
  final _serviceFeeController = TextEditingController();

  DateTime _examinedAt = DateTime.now();
  String _visitType = 'routine';
  bool _followUp = false;
  bool _saving = false;

  // Form ici ilac satirlari (lokal state).
  final List<_DrugLine> _drugLines = [];

  // Form ici cekilen fotograflar — kayit zamaninda PhotosRepository'ye
  // yazilir (muayene id'si oncesinde uretilir, transaction).
  final List<XFile> _pickedPhotos = [];
  final ImagePicker _picker = ImagePicker();

  static const _visitTypes = [
    ('routine', 'Rutin'),
    ('emergency', 'Acil'),
    ('vaccination', 'Asilama'),
    ('follow_up', 'Kontrol'),
  ];

  @override
  void dispose() {
    _chiefComplaintController.dispose();
    _symptomsController.dispose();
    _treatmentController.dispose();
    _temperatureController.dispose();
    _weightController.dispose();
    _serviceFeeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Ilac satirlarinin gecerliligi
    final usages = <DrugUsage>[];
    for (final line in _drugLines) {
      if (line.drugId == null) continue;
      final qty = double.tryParse(
        line.quantityController.text.trim().replaceAll(',', '.'),
      );
      if (qty == null || qty <= 0) {
        _showError('Ilac miktari gecerli olmali (>0)');
        return;
      }
      usages.add(DrugUsage(
        drugId: line.drugId!,
        quantity: qty,
        dosageInstructions: line.dosageController.text.trim().isEmpty
            ? null
            : line.dosageController.text.trim(),
      ));
    }

    setState(() => _saving = true);
    try {
      final mr = await ref.read(medicalRecordsRepositoryProvider).create(
            animalId: widget.animal.id,
            examinedAt: _examinedAt,
            visitType: _visitType,
            villageId: widget.animal.villageId,
            chiefComplaint: _trimOrNull(_chiefComplaintController.text),
            symptoms: _trimOrNull(_symptomsController.text),
            treatmentNotes: _trimOrNull(_treatmentController.text),
            temperatureCelsius: _parseDouble(_temperatureController.text),
            weightKg: _parseDouble(_weightController.text),
            serviceFee: _parseDouble(_serviceFeeController.text),
            followUpNeeded: _followUp,
            drugs: usages,
          );

      // Fotograflari kayit sonrasi disk'e kopyala + Drift'e yaz.
      // Sync queue (M4.5) sonra /sync/photos'a multipart yukler.
      if (_pickedPhotos.isNotEmpty) {
        final photosRepo = ref.read(photosRepositoryProvider);
        for (final picked in _pickedPhotos) {
          await photosRepo.savePickedPhoto(
            sourceFile: File(picked.path),
            medicalRecordId: mr.id,
            animalId: widget.animal.id,
            takenAt: _examinedAt,
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Muayene kaydedildi'
              '${_pickedPhotos.isNotEmpty ? ' (${_pickedPhotos.length} foto)' : ''}'
              ' (sync bekliyor)',
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showError('Kayit hatasi: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );
      if (picked == null) return;
      setState(() => _pickedPhotos.add(picked));
    } catch (e) {
      _showError('Foto alinamadi: $e');
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  String? _trimOrNull(String s) {
    final t = s.trim();
    return t.isEmpty ? null : t;
  }

  double? _parseDouble(String s) {
    final t = s.trim().replaceAll(',', '.');
    return t.isEmpty ? null : double.tryParse(t);
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _examinedAt,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_examinedAt),
    );
    if (time == null) return;
    setState(() {
      _examinedAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final drugsAsync = ref.watch(localDrugsProvider);
    final a = widget.animal;
    final animalLabel = a.name?.isNotEmpty == true
        ? a.name!
        : (a.earTag?.isNotEmpty == true ? 'Kupe ${a.earTag}' : 'Isimsiz');

    return Scaffold(
      appBar: AppBar(title: Text('Muayene · $animalLabel')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event),
                title: const Text('Muayene zamani'),
                subtitle: Text(
                  '${_examinedAt.toLocal()}'.split('.').first,
                ),
                trailing: TextButton(
                  onPressed: _pickDateTime,
                  child: const Text('Degistir'),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _visitType,
                decoration: const InputDecoration(
                  labelText: 'Ziyaret tipi',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final (v, l) in _visitTypes)
                    DropdownMenuItem(value: v, child: Text(l)),
                ],
                onChanged: (v) => setState(() => _visitType = v ?? 'routine'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _chiefComplaintController,
                decoration: const InputDecoration(
                  labelText: 'Ana sikayet',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _symptomsController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Belirtiler',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _treatmentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Tedavi notlari',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _temperatureController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [_decimalFormatter],
                      decoration: const InputDecoration(
                        labelText: 'Ates (°C)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [_decimalFormatter],
                      decoration: const InputDecoration(
                        labelText: 'Agirlik (kg)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _serviceFeeController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [_decimalFormatter],
                decoration: const InputDecoration(
                  labelText: 'Hizmet ucreti (TL)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Kontrol gerekli'),
                value: _followUp,
                onChanged: (v) => setState(() => _followUp = v),
              ),
              const Divider(height: 32),
              const Text(
                'Fotograflar',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _PhotoStrip(
                photos: _pickedPhotos,
                onRemove: (i) => setState(() => _pickedPhotos.removeAt(i)),
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => _pickPhoto(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Cek'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _pickPhoto(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Galeriden sec'),
                  ),
                ],
              ),
              const Divider(height: 32),
              const Text(
                'Kullanilan ilaclar (stok dususu)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              drugsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (e, _) => Text('Ilac listesi hatasi: $e'),
                data: (drugs) {
                  if (drugs.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Ilac katalogu henuz senkronize edilmedi. '
                        'Sync sonrasi bu kisimda ilac eklenebilir.',
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (var i = 0; i < _drugLines.length; i++)
                        _DrugLineRow(
                          line: _drugLines[i],
                          drugs: drugs,
                          onRemove: () => setState(() {
                            _drugLines[i].dispose();
                            _drugLines.removeAt(i);
                          }),
                          onChanged: () => setState(() {}),
                        ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => setState(
                            () => _drugLines.add(_DrugLine()),
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text('Ilac ekle'),
                        ),
                      ),
                    ],
                  );
                },
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

final _decimalFormatter =
    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'));

class _PhotoStrip extends StatelessWidget {
  const _PhotoStrip({required this.photos, required this.onRemove});
  final List<XFile> photos;
  final void Function(int index) onRemove;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Henuz foto eklenmedi.',
          style: TextStyle(color: Colors.black54),
        ),
      );
    }
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) => Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(photos[i].path),
                width: 96,
                height: 96,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: -4,
              right: -4,
              child: IconButton(
                iconSize: 18,
                icon: const CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.black54,
                  child: Icon(Icons.close, size: 14, color: Colors.white),
                ),
                onPressed: () => onRemove(i),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrugLine {
  String? drugId;
  final quantityController = TextEditingController();
  final dosageController = TextEditingController();

  void dispose() {
    quantityController.dispose();
    dosageController.dispose();
  }
}

class _DrugLineRow extends StatelessWidget {
  const _DrugLineRow({
    required this.line,
    required this.drugs,
    required this.onRemove,
    required this.onChanged,
  });

  final _DrugLine line;
  final List<DrugRow> drugs;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<String>(
              initialValue: line.drugId,
              decoration: const InputDecoration(
                labelText: 'Ilac',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              items: [
                for (final d in drugs)
                  DropdownMenuItem(value: d.id, child: Text(d.name)),
              ],
              onChanged: (v) {
                line.drugId = v;
                onChanged();
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: line.quantityController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [_decimalFormatter],
              decoration: const InputDecoration(
                labelText: 'Miktar',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onRemove,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }
}
