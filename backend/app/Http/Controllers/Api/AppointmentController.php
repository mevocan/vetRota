<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreAppointmentRequest;
use App\Http\Requests\UpdateAppointmentRequest;
use App\Models\Animal;
use App\Models\Appointment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AppointmentController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Appointment::query()
            ->with([
                'farmer:id,first_name,last_name,phone',
                'animal:id,ear_tag,name,species',
                'vet:id,name',
                'village:id,name,district',
            ]);

        if ($farmerId = $request->string('farmer_id')->value()) {
            $query->where('farmer_id', $farmerId);
        }
        if ($animalId = $request->string('animal_id')->value()) {
            $query->where('animal_id', $animalId);
        }
        if ($status = $request->string('status')->value()) {
            $query->where('status', $status);
        }
        if ($type = $request->string('appointment_type')->value()) {
            $query->where('appointment_type', $type);
        }
        if ($from = $request->string('from')->value()) {
            $query->where('scheduled_at', '>=', $from);
        }
        if ($to = $request->string('to')->value()) {
            $query->where('scheduled_at', '<=', $to);
        }

        // Default sort: yaklasan randevular oncedir.
        $sortDir = $request->string('sort')->value() === 'desc' ? 'desc' : 'asc';

        $perPage = min((int) $request->integer('per_page', 50), 200);

        return response()->json($query->orderBy('scheduled_at', $sortDir)->paginate($perPage));
    }

    public function show(Appointment $appointment): JsonResponse
    {
        $appointment->load([
            'farmer:id,first_name,last_name,phone,email',
            'animal:id,ear_tag,name,species,farmer_id,village_id',
            'vet:id,name,email',
            'village:id,name,district,city',
        ]);

        return response()->json(['data' => $appointment]);
    }

    public function store(StoreAppointmentRequest $request): JsonResponse
    {
        $data = $request->validated();
        $data['vet_id'] = $request->user()->id;

        // village_id verilmemisse: hayvanin koyunden veya cifcinin koyunden al.
        if (empty($data['village_id'])) {
            if (!empty($data['animal_id'])) {
                $animal = Animal::find($data['animal_id']);
                $data['village_id'] = $animal?->village_id;
            }
            if (empty($data['village_id'])) {
                $farmerVillage = \App\Models\Farmer::where('id', $data['farmer_id'])->value('village_id');
                $data['village_id'] = $farmerVillage;
            }
        }

        $data['status'] = $data['status'] ?? 'planned';
        $data['status_changed_at'] = now();

        $appointment = Appointment::create($data);
        $appointment->load([
            'farmer:id,first_name,last_name,phone',
            'animal:id,ear_tag,name,species',
            'vet:id,name',
            'village:id,name,district',
        ]);

        return response()->json(['data' => $appointment], 201);
    }

    public function update(UpdateAppointmentRequest $request, Appointment $appointment): JsonResponse
    {
        $data = $request->validated();

        // Status degisirse status_changed_at'i guncelle.
        if (isset($data['status']) && $data['status'] !== $appointment->status) {
            $data['status_changed_at'] = now();
        }

        $appointment->update($data);
        $appointment->load([
            'farmer:id,first_name,last_name,phone',
            'animal:id,ear_tag,name,species',
            'vet:id,name',
            'village:id,name,district',
        ]);

        return response()->json(['data' => $appointment]);
    }

    public function destroy(Appointment $appointment): JsonResponse
    {
        $appointment->delete();

        return response()->json(null, 204);
    }
}
