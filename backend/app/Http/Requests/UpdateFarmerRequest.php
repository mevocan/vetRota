<?php

declare(strict_types=1);

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateFarmerRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $farmerId = $this->route('farmer')?->id;

        return [
            'village_id' => ['sometimes', 'nullable', 'uuid', 'exists:villages,id'],
            'first_name' => ['sometimes', 'required', 'string', 'max:128'],
            'last_name' => ['sometimes', 'required', 'string', 'max:128'],
            'phone' => ['sometimes', 'required', 'string', 'max:32', Rule::unique('farmers', 'phone')->ignore($farmerId)->whereNull('deleted_at')],
            'email' => ['nullable', 'email', 'max:191'],
            'address_detail' => ['nullable', 'string'],
            'balance' => ['nullable', 'numeric', 'between:-9999999999.99,9999999999.99'],
            'sms_notifications_enabled' => ['boolean'],
            'preferred_sms_language' => ['nullable', 'string', 'max:10'],
            'notes' => ['nullable', 'string'],
        ];
    }

    public function messages(): array
    {
        return [
            'first_name.required' => 'Ad zorunlu.',
            'last_name.required' => 'Soyad zorunlu.',
            'phone.required' => 'Telefon zorunlu.',
            'phone.unique' => 'Bu telefon numarası başka bir çiftçide kayıtlı.',
            'email.email' => 'Geçerli bir e-posta girin.',
            'village_id.exists' => 'Seçilen köy bulunamadı.',
        ];
    }
}
