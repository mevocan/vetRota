<?php

declare(strict_types=1);

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreStockMovementRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'drug_id' => ['required', 'uuid', 'exists:drugs,id'],
            'movement_type' => ['required', Rule::in(['purchase', 'usage', 'transfer_in', 'transfer_out', 'adjustment', 'waste', 'return'])],
            'quantity' => ['required', 'numeric', 'not_in:0'],
            'unit_price' => ['nullable', 'numeric', 'min:0'],
            'batch_number' => ['nullable', 'string', 'max:64'],
            'expiry_date' => ['nullable', 'date'],
            'supplier_name' => ['nullable', 'string', 'max:191'],
            'related_medical_record_id' => ['nullable', 'uuid', 'exists:medical_records,id'],
            'notes' => ['nullable', 'string'],
            'occurred_at' => ['required', 'date'],
        ];
    }

    public function messages(): array
    {
        return [
            'drug_id.required' => 'İlaç seçimi zorunlu.',
            'drug_id.exists' => 'Seçilen ilaç bulunamadı.',
            'movement_type.required' => 'Hareket türü zorunlu.',
            'movement_type.in' => 'Geçersiz hareket türü.',
            'quantity.required' => 'Miktar zorunlu.',
            'quantity.not_in' => 'Miktar 0 olamaz (alım için pozitif, kullanım için negatif).',
            'occurred_at.required' => 'Hareket tarihi zorunlu.',
        ];
    }
}
