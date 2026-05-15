import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/env.dart';
import '../../data/db/app_database.dart';
import '../../data/farmers/farmers_repository.dart';

const Color _green = Color(Env.primaryColorHex);

// Yeni / mevcut ciftci formu. Offline-first: Drift'e yazilir, sync push
// arkadan gonderir. createMode=true ise yeni ciftci, false ise duzenleme.
class FarmerFormScreen extends ConsumerStatefulWidget {
  const FarmerFormScreen({super.key, this.existing});

  final FarmerRow? existing;

  bool get isEdit => existing != null;

  @override
  ConsumerState<FarmerFormScreen> createState() => _FarmerFormScreenState();
}

class _FarmerFormScreenState extends ConsumerState<FarmerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _address;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _firstName = TextEditingController(text: e?.firstName ?? '');
    _lastName = TextEditingController(text: e?.lastName ?? '');
    _phone = TextEditingController(text: e?.phone ?? '');
    _email = TextEditingController(text: e?.email ?? '');
    _address = TextEditingController(text: e?.addressDetail ?? '');
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final repo = ref.read(farmersRepositoryProvider);
      final fn = _firstName.text.trim();
      final ln = _lastName.text.trim();
      final ph = _phone.text.trim().isEmpty ? null : _phone.text.trim();
      final em = _email.text.trim().isEmpty ? null : _email.text.trim();
      final ad = _address.text.trim().isEmpty ? null : _address.text.trim();

      FarmerRow result;
      if (widget.isEdit) {
        await repo.update(
          id: widget.existing!.id,
          firstName: fn,
          lastName: ln,
          phone: ph,
          email: em,
          addressDetail: ad,
        );
        result = widget.existing!;
      } else {
        result = await repo.create(
          firstName: fn,
          lastName: ln,
          phone: ph,
          email: em,
          addressDetail: ad,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEdit
              ? 'Ciftci guncellendi (sync bekliyor)'
              : 'Ciftci eklendi (sync bekliyor)'),
        ),
      );
      Navigator.of(context).pop<FarmerRow>(result);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Ciftciyi duzenle' : 'Yeni ciftci'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _firstName,
                decoration: const InputDecoration(
                  labelText: 'Ad',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Ad zorunlu' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastName,
                decoration: const InputDecoration(
                  labelText: 'Soyad',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Soyad zorunlu' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefon (opsiyonel)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-posta (opsiyonel)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _address,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Adres detayi (opsiyonel)',
                  border: OutlineInputBorder(),
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
