<?php

declare(strict_types=1);

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreAnimalRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'farmer_id' => ['required', 'uuid', 'exists:farmers,id'],
            'village_id' => ['nullable', 'uuid', 'exists:villages,id'],
            'ear_tag' => ['nullable', 'string', 'max:64'],
            'name' => ['nullable', 'string', 'max:128'],
            'species' => ['required', Rule::in(['cattle', 'sheep', 'goat', 'poultry', 'other'])],
            'breed' => ['nullable', 'string', 'max:128'],
            'birth_date' => ['nullable', 'date', 'before_or_equal:today'],
            'gender' => ['required', Rule::in(['male', 'female', 'unknown'])],
            'weight_kg' => ['nullable', 'numeric', 'between:0,9999.99'],
            'color' => ['nullable', 'string', 'max:64'],
            'is_pregnant' => ['boolean'],
            'status' => ['nullable', Rule::in(['alive', 'sold', 'deceased', 'lost'])],
            'notes' => ['nullable', 'string'],
        ];
    }

    public function messages(): array
    {
        return [
            'farmer_id.required' => 'Çiftçi seçimi zorunlu.',
            'farmer_id.exists' => 'Seçilen çiftçi bulunamadı.',
            'species.required' => 'Tür seçimi zorunlu.',
            'species.in' => 'Geçersiz tür seçimi.',
            'gender.required' => 'Cinsiyet seçimi zorunlu.',
            'birth_date.before_or_equal' => 'Doğum tarihi gelecekte olamaz.',
            'weight_kg.between' => 'Ağırlık 0 ile 9999.99 kg arasında olmalı.',
        ];
    }
}
