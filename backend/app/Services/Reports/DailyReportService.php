<?php

declare(strict_types=1);

namespace App\Services\Reports;

use App\Models\DailyReport;
use App\Models\MedicalRecord;
use App\Models\Route;
use App\Models\StockMovement;
use App\Models\User;
use Illuminate\Support\Carbon;

// M5.2: bir veterinerin bir gunu icin ozet uretir.
//   - kac muayene
//   - kac farkli hayvan ziyaret edildi
//   - toplam mesafe (route varsa)
//   - toplam hasilat (medical_records.service_fee toplami)
//   - kullanilan ilaclar (stock_movements type='usage' olanlardan toplam)
class DailyReportService
{
    public function compute(User $vet, string $date): DailyReport
    {
        $day = Carbon::parse($date)->startOfDay();
        $next = (clone $day)->addDay();

        $mrs = MedicalRecord::where('vet_id', $vet->id)
            ->where('clinic_id', $vet->clinic_id)
            ->whereBetween('examined_at', [$day, $next])
            ->whereNull('deleted_at')
            ->get();

        $animalIds = $mrs->pluck('animal_id')->unique()->values();
        $totalRevenue = (float) $mrs->sum('service_fee');

        $route = Route::where('vet_id', $vet->id)
            ->where('date', $day->toDateString())
            ->whereNull('deleted_at')
            ->first();

        // Bu vet'in bugun yaptigi usage hareketlerini ilac bazli grupla.
        // performed_by veterinerin id'si.
        $drugRows = StockMovement::query()
            ->where('clinic_id', $vet->clinic_id)
            ->where('movement_type', 'usage')
            ->where('performed_by', $vet->id)
            ->whereBetween('occurred_at', [$day, $next])
            ->with('drug:id,name,unit')
            ->get()
            ->groupBy('drug_id')
            ->map(fn ($g) => [
                'drug_id' => $g->first()->drug_id,
                'name' => optional($g->first()->drug)->name,
                'unit' => optional($g->first()->drug)->unit,
                // usage = negatif quantity; mutlak deger toplami.
                'total_quantity' => abs((float) $g->sum('quantity')),
            ])
            ->values()
            ->all();

        $report = DailyReport::updateOrCreate(
            ['vet_id' => $vet->id, 'date' => $day->toDateString()],
            [
                'clinic_id' => $vet->clinic_id,
                'animals_visited' => $animalIds->count(),
                'medical_records_count' => $mrs->count(),
                'total_distance_km' => $route?->total_distance_km,
                'total_revenue' => $totalRevenue,
                'drugs_used' => $drugRows,
                'generated_at' => now(),
            ],
        );

        return $report->fresh();
    }
}
