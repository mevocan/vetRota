<?php

declare(strict_types=1);

namespace App\Services\Analytics;

use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

// M8.1: Veteriner basina muayene sayisi, toplam km, toplam fatura tutari.
// Km routes.total_distance_km'den; fatura medical_records.service_fee'den.
class VetPerformanceService
{
    /**
     * @return array<int, array<string, mixed>>
     */
    public function summary(string $clinicId, Carbon $from, Carbon $to): array
    {
        $mr = DB::table('medical_records as mr')
            ->join('users as u', 'u.id', '=', 'mr.vet_id')
            ->where('mr.clinic_id', $clinicId)
            ->whereBetween('mr.examined_at', [$from, $to])
            ->whereNull('mr.deleted_at')
            ->select([
                'u.id as vet_id',
                'u.name as vet_name',
                DB::raw('COUNT(*) as exam_count'),
                DB::raw('COALESCE(SUM(mr.service_fee), 0) as total_fee'),
            ])
            ->groupBy('u.id', 'u.name')
            ->get()
            ->keyBy('vet_id');

        $km = DB::table('routes')
            ->where('clinic_id', $clinicId)
            ->whereBetween('date', [$from->toDateString(), $to->toDateString()])
            ->whereNull('deleted_at')
            ->select([
                'vet_id',
                DB::raw('COALESCE(SUM(total_distance_km), 0) as total_km'),
                DB::raw('COUNT(*) as days_active'),
            ])
            ->groupBy('vet_id')
            ->get()
            ->keyBy('vet_id');

        $vetIds = $mr->keys()->merge($km->keys())->unique()->values();

        $rows = [];
        foreach ($vetIds as $vetId) {
            $m = $mr->get($vetId);
            $k = $km->get($vetId);
            $exam = (int) ($m->exam_count ?? 0);
            $days = (int) ($k->days_active ?? 0);
            $rows[] = [
                'vet_id' => $vetId,
                'vet_name' => $m->vet_name ?? null,
                'exam_count' => $exam,
                'total_fee' => (float) ($m->total_fee ?? 0),
                'total_km' => (float) ($k->total_km ?? 0),
                'days_active' => $days,
                'avg_exam_per_day' => $days > 0 ? round($exam / $days, 1) : null,
            ];
        }

        usort($rows, fn ($a, $b) => $b['exam_count'] <=> $a['exam_count']);
        return $rows;
    }
}
