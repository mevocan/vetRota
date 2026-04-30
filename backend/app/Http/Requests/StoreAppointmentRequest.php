<?php

declare(strict_types=1);

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreAppointmentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'farmer_id' => ['required', 'uuid', 'exists:farmers,id'],
            'animal_id' => ['nullable', 'uuid', 'exists:animals,id'],
            'village_id' => ['nullable', 'uuid', 'exists:villages,id'],
            'scheduled_at' => ['required', 'date'],
            'estimated_duration_minutes' => ['nullable', 'integer', 'min:5', 'max:480'],
            'appointment_type' => ['required', Rule::in(['visit', 'vaccination', 'follow_up', 'emergency', 'routine_check'])],
            'reason' => ['nullable', 'string'],
            'notes' => ['nullable', 'string'],
            'status' => ['nullable', Rule::in(['planned', 'confirmed', 'in_progress', 'completed', 'cancelled', 'no_show'])],
        ];
    }

    public function messages(): array
    {
        return [
            'farmer_id.required' => 'Çiftçi seçimi zorunlu.',
            'farmer_id.exists' => 'Seçilen çiftçi bulunamadı.',
            'animal_id.exists' => 'Seçilen hayvan bulunamadı.',
            'village_id.exists' => 'Seçilen köy bulunamadı.',
            'scheduled_at.required' => 'Randevu tarihi zorunlu.',
            'scheduled_at.date' => 'Geçersiz tarih formatı.',
            'appointment_type.required' => 'Randevu türü zorunlu.',
            'appointment_type.in' => 'Geçersiz randevu türü.',
            'estimated_duration_minutes.min' => 'Süre en az 5 dakika olmalı.',
            'estimated_duration_minutes.max' => 'Süre en fazla 480 dakika (8 saat) olabilir.',
            'status.in' => 'Geçersiz durum.',
        ];
    }
}
