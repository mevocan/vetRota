<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Reports;

use App\Http\Controllers\Controller;
use App\Services\Reports\DailyReportService;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\Response;

class DailyReportController extends Controller
{
    public function __construct(
        private readonly DailyReportService $service,
    ) {}

    // GET /api/v1/reports/daily/{date}  (date = YYYY-MM-DD)
    // ?format=pdf  -> binary PDF (download header)
    // default     -> JSON
    public function show(Request $request, string $date): Response
    {
        /** @var \App\Models\User $vet */
        $vet = auth()->user();
        $report = $this->service->compute($vet, $date);

        if ($request->query('format') === 'pdf') {
            $pdf = Pdf::loadView('reports.daily', [
                'report' => $report,
                'date' => $date,
                'vetName' => $vet->name ?? $vet->email,
                'generatedAt' => $report->generated_at?->format('Y-m-d H:i') ?? now()->format('Y-m-d H:i'),
            ])->setPaper('a4');

            // Diske de kaydet (yeniden uretim ucretsiz, ama M8 analitik
            // veya istemcide cache icin path).
            $relPath = "reports/{$vet->clinic_id}/vet-{$vet->id}/{$date}.pdf";
            Storage::disk('local')->put($relPath, $pdf->output());
            $report->update(['pdf_path' => $relPath]);

            return response($pdf->output(), 200, [
                'Content-Type' => 'application/pdf',
                'Content-Disposition' => "attachment; filename=\"vetrota-{$date}.pdf\"",
            ]);
        }

        return response()->json([
            'date' => $date,
            'vet_id' => $vet->id,
            'animals_visited' => $report->animals_visited,
            'medical_records_count' => $report->medical_records_count,
            'total_distance_km' => $report->total_distance_km,
            'total_revenue' => $report->total_revenue,
            'drugs_used' => $report->drugs_used ?? [],
            'generated_at' => $report->generated_at?->toIso8601String(),
        ]);
    }
}
