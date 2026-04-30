<?php

declare(strict_types=1);

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreMedicalRecordRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'animal_id' => ['required', 'uuid', 'exists:animals,id'],
            'village_id' => ['nullable', 'uuid', 'exists:villages,id'],
            'lat' => ['nullable', 'numeric', 'between:-90,90'],
            'lng' => ['nullable', 'numeric', 'between:-180,180'],
            'visit_type' => ['required', Rule::in(['examination', 'vaccination', 'treatment', 'emergency', 'routine_check', 'pregnancy_check'])],
            'chief_complaint' => ['nullable', 'string'],
            'symptoms' => ['nullable', 'string'],
            'diagnosis_notes' => ['nullable', 'string'],
            'treatment_notes' => ['nullable', 'string'],
            'recommendations' => ['nullable', 'string'],
            'temperature_celsius' => ['nullable', 'numeric', 'between:30,50'],
            'weight_kg' => ['nullable', 'numeric', 'between:0,9999.99'],
            'heart_rate' => ['nullable', 'integer', 'between:0,500'],
            'respiratory_rate' => ['nullable', 'integer', 'between:0,200'],
            'service_fee' => ['nullable', 'numeric', 'between:0,99999999.99'],
            'examined_at' => ['required', 'date'],
            'follow_up_needed' => ['boolean'],
            'follow_up_date' => ['nullable', 'date', 'required_if:follow_up_needed,true'],
        ];
    }

    public function messages(): array
    {
        return [
            'animal_id.required' => 'Hayvan seçimi zorunlu.',
            'animal_id.exists' => 'Seçilen hayvan bulunamadı.',
            'visit_type.required' => 'Ziyaret türü zorunlu.',
            'visit_type.in' => 'Geçersiz ziyaret türü.',
            'examined_at.required' => 'Muayene tarihi zorunlu.',
            'examined_at.date' => 'Geçersiz tarih formatı.',
            'temperature_celsius.between' => 'Vücut sıcaklığı 30 ile 50 °C arasında olmalı.',
            'weight_kg.between' => 'Ağırlık 0 ile 9999.99 kg arasında olmalı.',
            'heart_rate.between' => 'Kalp atış hızı 0 ile 500 arasında olmalı.',
            'respiratory_rate.between' => 'Solunum hızı 0 ile 200 arasında olmalı.',
            'follow_up_date.required_if' => 'Takip işaretliyse takip tarihi de girilmeli.',
            'village_id.exists' => 'Seçilen köy bulunamadı.',
        ];
    }
}
