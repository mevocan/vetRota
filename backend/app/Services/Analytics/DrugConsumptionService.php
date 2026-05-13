<?php

declare(strict_types=1);

namespace App\Services\Analytics;

use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

// M8.1: Ilac tuketim analitigi.
// Aralikta toplam kullanim (medical_record_drugs.quantity); mevcut stok
// stocks.current_quantity'den (clinic bazli birden fazla stok satiri varsa
// toplanir); gunluk ortalama tuketim + tahmini bitis gunu.
class DrugConsumptionService
{
    /**
     * @return array<int, array<string, mixed>>
     */
    public function summary(string $clinicId, Carbon $from, Carbon $to): array
    {
        $days = max(1, (int) $from->diffInDays($to) + 1);

        $usage = DB::table('medical_record_drugs as mrd')
            ->join('medical_records as mr', 'mr.id', '=', 'mrd.medical_record_id')
            ->join('drugs as d', 'd.id', '=', 'mrd.drug_id')
            ->where('mrd.clinic_id', $clinicId)
            ->whereBetween('mr.examined_at', [$from, $to])
            ->whereNull('mrd.deleted_at')
            ->whereNull('mr.deleted_at')
            ->select([
                'd.id as drug_id',
                'd.name as drug_name',
                'd.unit',
                'd.is_vaccine',
                DB::raw('COALESCE(SUM(mrd.quantity), 0) as total_used'),
                DB::raw('COUNT(*) as usage_count'),
            ])
            ->groupBy('d.id', 'd.name', 'd.unit', 'd.is_vaccine')
            ->get();

        $stocks = DB::table('stocks')
            ->where('clinic_id', $clinicId)
            ->whereNull('deleted_at')
            ->select([
                'drug_id',
                DB::raw('COALESCE(SUM(current_quantity), 0) as remaining'),
            ])
            ->groupBy('drug_id')
            ->get()
            ->keyBy('drug_id');

        $rows = [];
        foreach ($usage as $u) {
            $remaining = (float) ($stocks->get($u->drug_id)->remaining ?? 0);
            $totalUsed = (float) $u->total_used;
            $perDay = $totalUsed / $days;
            $daysLeft = ($perDay > 0 && $remaining > 0)
                ? (int) floor($remaining / $perDay)
                : null;

            $rows[] = [
                'drug_id' => $u->drug_id,
                'drug_name' => $u->drug_name,
                'unit' => $u->unit,
                'is_vaccine' => (bool) $u->is_vaccine,
                'total_used' => $totalUsed,
                'usage_count' => (int) $u->usage_count,
                'remaining' => $remaining,
                'avg_per_day' => round($perDay, 3),
                'days_until_empty' => $daysLeft,
            ];
        }

        usort($rows, fn ($a, $b) => $b['total_used'] <=> $a['total_used']);
        return $rows;
    }
}
