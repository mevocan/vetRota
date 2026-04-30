<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreMedicalRecordRequest;
use App\Http\Requests\UpdateMedicalRecordRequest;
use App\Models\Animal;
use App\Models\MedicalRecord;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MedicalRecordController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = MedicalRecord::query()
            ->with([
                'animal:id,ear_tag,name,species,farmer_id,village_id',
                'animal.farmer:id,first_name,last_name',
                'vet:id,name',
                'village:id,name,district',
            ]);

        if ($animalId = $request->string('animal_id')->value()) {
            $query->where('animal_id', $animalId);
        }
        if ($vetId = $request->string('vet_id')->value()) {
            $query->where('vet_id', $vetId);
        }
        if ($visitType = $request->string('visit_type')->value()) {
            $query->where('visit_type', $visitType);
        }
        if ($from = $request->string('from')->value()) {
            $query->where('examined_at', '>=', $from);
        }
        if ($to = $request->string('to')->value()) {
            $query->where('examined_at', '<=', $to);
        }
        if ($request->boolean('follow_up_due')) {
            $query->where('follow_up_needed', true)
                  ->whereNotNull('follow_up_date');
        }

        $perPage = min((int) $request->integer('per_page', 25), 100);

        return response()->json($query->orderByDesc('examined_at')->paginate($perPage));
    }

    public function show(MedicalRecord $medicalRecord): JsonResponse
    {
        $medicalRecord->load([
            'animal:id,ear_tag,name,species,farmer_id,village_id',
            'animal.farmer:id,first_name,last_name,phone',
            'animal.village:id,name,district,city',
            'vet:id,name,email',
            'village:id,name,district,city',
        ]);

        return response()->json(['data' => $medicalRecord]);
    }

    public function store(StoreMedicalRecordRequest $request): JsonResponse
    {
        $data = $request->validated();
        // Vet otomatik = giris yapan kullanici (M2 tek klinik varsayimiyla).
        $data['vet_id'] = $request->user()->id;

        // village_id verilmemisse hayvanin koyunden al.
        if (empty($data['village_id'])) {
            $animal = Animal::find($data['animal_id']);
            $data['village_id'] = $animal?->village_id;
        }

        $record = MedicalRecord::create($data);
        $record->load([
            'animal:id,ear_tag,name,species',
            'vet:id,name',
            'village:id,name,district',
        ]);

        return response()->json(['data' => $record], 201);
    }

    public function update(UpdateMedicalRecordRequest $request, MedicalRecord $medicalRecord): JsonResponse
    {
        $medicalRecord->update($request->validated());
        $medicalRecord->load([
            'animal:id,ear_tag,name,species',
            'vet:id,name',
            'village:id,name,district',
        ]);

        return response()->json(['data' => $medicalRecord]);
    }

    public function destroy(MedicalRecord $medicalRecord): JsonResponse
    {
        $medicalRecord->delete();

        return response()->json(null, 204);
    }
}
