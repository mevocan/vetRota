<?php

declare(strict_types=1);

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateAnimalRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'farmer_id' => ['sometimes', 'required', 'uuid', 'exists:farmers,id'],
            'village_id' => ['nullable', 'uuid', 'exists:villages,id'],
            'ear_tag' => ['nullable', 'string', 'max:64'],
            'name' => ['nullable', 'string', 'max:128'],
            'species' => ['sometimes', 'required', Rule::in(['cattle', 'sheep', 'goat', 'poultry', 'other'])],
            'breed' => ['nullable', 'string', 'max:128'],
            'birth_date' => ['nullable', 'date', 'before_or_equal:today'],
            'gender' => ['sometimes', 'required', Rule::in(['male', 'female', 'unknown'])],
            'weight_kg' => ['nullable', 'numeric', 'between:0,9999.99'],
            'color' => ['nullable', 'string', 'max:64'],
            'is_pregnant' => ['boolean'],
            'status' => ['nullable', Rule::in(['alive', 'sold', 'deceased', 'lost'])],
            'status_notes' => ['nullable', 'string'],
            'notes' => ['nullable', 'string'],
        ];
    }
}
