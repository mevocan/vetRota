<?php

declare(strict_types=1);

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateDrugRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $drugId = $this->route('drug')?->id;

        return [
            'name' => ['sometimes', 'required', 'string', 'max:191', Rule::unique('drugs', 'name')->ignore($drugId)->whereNull('deleted_at')],
            'active_ingredient' => ['nullable', 'string', 'max:191'],
            'manufacturer' => ['nullable', 'string', 'max:191'],
            'barcode' => ['nullable', 'string', 'max:64'],
            'drug_type' => ['sometimes', 'required', Rule::in(['antibiotic', 'vaccine', 'antiparasitic', 'antiinflammatory', 'analgesic', 'vitamin', 'hormone', 'other'])],
            'requires_prescription' => ['boolean'],
            'unit' => ['sometimes', 'required', Rule::in(['ml', 'tablet', 'doz', 'g', 'flakon', 'ampul'])],
            'package_size' => ['nullable', 'numeric', 'min:0'],
            'is_vaccine' => ['boolean'],
            'vaccine_duration_days' => ['nullable', 'integer', 'min:1'],
            'suitable_species' => ['nullable', 'array'],
            'suitable_species.*' => [Rule::in(['cattle', 'sheep', 'goat', 'poultry', 'other'])],
            'default_price' => ['nullable', 'numeric', 'min:0'],
            'critical_threshold' => ['nullable', 'numeric', 'min:0'],
        ];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'İlaç adı zorunlu.',
            'name.unique' => 'Bu isimde bir ilaç zaten kayıtlı.',
            'drug_type.required' => 'İlaç türü zorunlu.',
            'drug_type.in' => 'Geçersiz ilaç türü.',
            'unit.required' => 'Birim zorunlu.',
            'unit.in' => 'Geçersiz birim.',
        ];
    }
}
