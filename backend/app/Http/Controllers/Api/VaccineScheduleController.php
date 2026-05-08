<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Animal;
use App\Models\VaccineSchedule;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Validator;

// M6.9: Asi plani CRUD endpoint'i.
// Klinik web panelinden veteriner asi sablonlari tanimlar.
// Mobile sync uzerinden de yazilabilir (sync_status sutunlari hazir).
class VaccineScheduleController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = VaccineSchedule::query()
            ->with(['drug:id,name,is_vaccine', 'animal:id,name,ear_tag,species']);

        if ($animalId = $request->string('animal_id')->value()) {
            $query->where('animal_id', $animalId);
        }
        if ($drugId = $request->string('drug_id')->value()) {
            $query->where('drug_id', $drugId);
        }
        if ($request->boolean('only_active', true)) {
            $query->where('is_active', true);
        }

        $perPage = min((int) $request->integer('per_page', 50), 200);

        return response()->json(
            $query->orderBy('next_due_date')->paginate($perPage)
        );
    }

    public function show(VaccineSchedule $vaccineSchedule): JsonResponse
    {
        $vaccineSchedule->load([
            'drug:id,name,is_vaccine,vaccine_duration_days',
            'animal:id,name,ear_tag,species',
        ]);
        return response()->json(['data' => $vaccineSchedule]);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $this->validated($request);

        // first_due_date verilmemisse next_due_date ile ayni.
        $data['first_due_date'] = $data['first_due_date'] ?? $data['next_due_date'];

        // clinic_id animal'dan al — multi-tenancy.
        $animal = Animal::findOrFail($data['animal_id']);
        $data['clinic_id'] = $animal->clinic_id;

        $schedule = VaccineSchedule::create($data);
        $schedule->load(['drug:id,name', 'animal:id,name,ear_tag']);

        return response()->json(['data' => $schedule], 201);
    }

    public function update(Request $request, VaccineSchedule $vaccineSchedule): JsonResponse
    {
        $data = $this->validated($request, isUpdate: true);
        $vaccineSchedule->update($data);
        $vaccineSchedule->load(['drug:id,name', 'animal:id,name,ear_tag']);

        return response()->json(['data' => $vaccineSchedule]);
    }

    public function destroy(VaccineSchedule $vaccineSchedule): JsonResponse
    {
        // Soft delete + is_active=false (data-model.md: deceased animal observer benzeri).
        $vaccineSchedule->update(['is_active' => false]);
        $vaccineSchedule->delete();

        return response()->json(null, 204);
    }

    /**
     * @return array<string, mixed>
     */
    private function validated(Request $request, bool $isUpdate = false): array
    {
        $rules = [
            'animal_id' => [$isUpdate ? 'sometimes' : 'required', 'uuid', 'exists:animals,id'],
            'drug_id' => [$isUpdate ? 'sometimes' : 'required', 'uuid', 'exists:drugs,id'],
            'interval_days' => [$isUpdate ? 'sometimes' : 'required', 'integer', 'min:1', 'max:3650'],
            'next_due_date' => [$isUpdate ? 'sometimes' : 'required', 'date'],
            'first_due_date' => ['sometimes', 'nullable', 'date'],
            'remind_days_before' => ['sometimes', 'integer', 'min:0', 'max:365'],
            'is_active' => ['sometimes', 'boolean'],
            'notes' => ['sometimes', 'nullable', 'string', 'max:2000'],
        ];

        return Validator::make($request->all(), $rules)->validate();
    }
}
