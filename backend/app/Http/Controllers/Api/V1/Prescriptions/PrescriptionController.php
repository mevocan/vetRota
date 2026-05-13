<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Prescriptions;

use App\Http\Controllers\Controller;
use App\Models\MedicalRecord;
use App\Models\Prescription;
use App\Services\FarmerPortal\TokenService;
use App\Services\Prescriptions\PrescriptionService;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

// M7.4: Recete REST + PDF endpoint'leri.
// - POST /prescriptions : MR uzerinden recete olustur (auth)
// - GET /prescriptions/{prescription}/pdf : klinik PDF indir (auth)
// - GET /prescriptions/public/{token}/pdf : SMS link uzerinden public PDF
class PrescriptionController extends Controller
{
    public function __construct(
        private readonly PrescriptionService $service,
        private readonly TokenService $tokenService,
    ) {}

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'medical_record_id' => ['required', 'uuid', 'exists:medical_records,id'],
            'notes' => ['nullable', 'string', 'max:4000'],
        ]);

        /** @var \App\Models\User $user */
        $user = auth()->user();
        $mr = MedicalRecord::findOrFail($data['medical_record_id']);
        abort_unless($mr->clinic_id === $user->clinic_id, 404);

        $prescription = $this->service->createFromMedicalRecord($mr, $data['notes'] ?? null);
        $prescription->refresh();

        return response()->json([
            'data' => [
                'id' => $prescription->id,
                'prescription_number' => $prescription->prescription_number,
                'medical_record_id' => $prescription->medical_record_id,
                'farmer_id' => $prescription->farmer_id,
                'animal_id' => $prescription->animal_id,
                'sms_sent_at' => $prescription->sms_sent_at?->toIso8601String(),
                'created_at' => $prescription->created_at?->toIso8601String(),
            ],
        ], 201);
    }

    public function pdf(Prescription $prescription): Response
    {
        /** @var \App\Models\User $user */
        $user = auth()->user();
        abort_unless($prescription->clinic_id === $user->clinic_id, 404);

        return $this->renderPdf($prescription);
    }

    public function publicPdf(string $token): Response
    {
        $portalToken = $this->tokenService->verify($token);
        abort_if($portalToken === null, 410, 'Bu link gecersiz veya suresi gecmis.');
        abort_unless(
            $portalToken->scope === 'prescription'
                && $portalToken->resource_type === 'prescription',
            403,
            'Bu token recete icin gecersiz.'
        );

        $prescription = Prescription::find($portalToken->resource_id);
        abort_if($prescription === null, 404);

        return $this->renderPdf($prescription);
    }

    private function renderPdf(Prescription $prescription): Response
    {
        $prescription->load([
            'medicalRecord',
            'farmer',
            'animal',
            'vet:id,name',
            'medicalRecord.drugs.drug:id,name,active_ingredient',
        ]);

        $pdf = Pdf::loadView('reports.prescription', [
            'prescription' => $prescription,
            'mr' => $prescription->medicalRecord,
            'farmer' => $prescription->farmer,
            'animal' => $prescription->animal,
            'vet' => $prescription->vet,
            'clinic' => $prescription->clinic,
            'drugs' => $prescription->medicalRecord?->drugs ?? collect(),
        ])->setPaper('a4');

        $filename = 'recete-' . ($prescription->prescription_number ?: $prescription->id) . '.pdf';

        return response($pdf->output(), 200, [
            'Content-Type' => 'application/pdf',
            'Content-Disposition' => 'inline; filename="' . $filename . '"',
        ]);
    }
}
