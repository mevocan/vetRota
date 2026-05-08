<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\FarmerPortal;

use App\Http\Controllers\Controller;
use App\Services\FarmerPortal\TokenService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

// M6.7: Ciftci portal endpoint'i.
// Auth'suz public route — token ile dogrulanir.
// Cevap: ciftci adi + hayvanlari + son 5 muayene + yaklasan asilar.
class FarmerPortalController extends Controller
{
    public function __construct(
        private readonly TokenService $tokenService,
    ) {}

    public function show(Request $request, string $token): JsonResponse
    {
        $portalToken = $this->tokenService->verify($token);
        if ($portalToken === null) {
            // Detay vermeden 410: bulunamadi/expired/revoked hepsi ayni mesaj
            // (token enumeration'i zorlastirir).
            return response()->json([
                'error' => 'invalid_or_expired_token',
                'message' => 'Bu link gecersiz veya suresi gecmis. Lutfen klinik ile iletisime gecin.',
            ], 410);
        }

        $this->tokenService->recordAccess(
            $portalToken,
            $request->ip(),
            (string) $request->userAgent(),
        );

        $farmer = $portalToken->farmer()->with([
            'animals' => fn ($q) => $q->whereNull('deleted_at'),
            'animals.medicalRecords' => fn ($q) => $q
                ->whereNull('deleted_at')
                ->orderBy('examined_at', 'desc')
                ->limit(5),
            'clinic',
        ])->first();

        if ($farmer === null) {
            return response()->json([
                'error' => 'farmer_not_found',
                'message' => 'Bu link gecersiz.',
            ], 410);
        }

        // Yaklasan asilar — onumuzdeki 60 gun.
        $upcomingVaccinations = \App\Models\VaccineSchedule::query()
            ->where('clinic_id', $farmer->clinic_id)
            ->whereIn('animal_id', $farmer->animals->pluck('id'))
            ->where('is_active', true)
            ->whereDate('next_due_date', '<=', now()->addDays(60))
            ->with('drug:id,name')
            ->orderBy('next_due_date')
            ->get()
            ->map(fn ($s) => [
                'id' => $s->id,
                'animal_id' => $s->animal_id,
                'drug_name' => $s->drug?->name,
                'next_due_date' => $s->next_due_date->toDateString(),
                'interval_days' => $s->interval_days,
            ]);

        return response()->json([
            'clinic' => [
                'id' => $farmer->clinic?->id,
                'name' => $farmer->clinic?->name,
                'city' => $farmer->clinic?->city,
                'district' => $farmer->clinic?->district,
            ],
            'farmer' => [
                'id' => $farmer->id,
                'first_name' => $farmer->first_name,
                'last_name' => $farmer->last_name,
            ],
            'token' => [
                'scope' => $portalToken->scope,
                'expires_at' => $portalToken->expires_at->toIso8601String(),
            ],
            'animals' => $farmer->animals->map(fn ($a) => [
                'id' => $a->id,
                'name' => $a->name,
                'ear_tag' => $a->ear_tag,
                'species' => $a->species,
                'breed' => $a->breed,
                'birth_date' => $a->birth_date?->toDateString(),
                'medical_records' => $a->medicalRecords->map(fn ($mr) => [
                    'id' => $mr->id,
                    'examined_at' => $mr->examined_at?->toIso8601String(),
                    'visit_type' => $mr->visit_type,
                    'chief_complaint' => $mr->chief_complaint,
                    'diagnosis_notes' => $mr->diagnosis_notes,
                    'treatment_notes' => $mr->treatment_notes,
                    'recommendations' => $mr->recommendations,
                ]),
            ])->values(),
            'upcoming_vaccinations' => $upcomingVaccinations,
        ]);
    }
}
