<?php

declare(strict_types=1);

namespace App\Services\Analytics;

use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

// M8.1: Klinik kazanci zaman serisi.
// - billed: medical_records.service_fee toplami (fatura edilen)
// - collected: payments.amount toplami (tahsil edilen)
// - outstanding: tum aralikta farmers.balance toplami (anlik durum)
// groupBy: day|week|month
class RevenueService
{
    /**
     * @return array{
     *   total_billed: float,
     *   total_collected: float,
     *   outstanding: float,
     *   series: array<int, array<string, mixed>>
     * }
     */
    public function summary(
        string $clinicId,
        Carbon $from,
        Carbon $to,
        string $groupBy = 'day',
    ): array {
        $bucket = match ($groupBy) {
            'week' => "date_trunc('week', examined_at)",
            'month' => "date_trunc('month', examined_at)",
            default => "date_trunc('day', examined_at)",
        };
        $bucketPay = str_replace('examined_at', 'paid_at', $bucket);

        $billed = DB::table('medical_records')
            ->where('clinic_id', $clinicId)
            ->whereBetween('examined_at', [$from, $to])
            ->whereNull('deleted_at')
            ->select([
                DB::raw("$bucket as bucket"),
                DB::raw('COALESCE(SUM(service_fee), 0) as amount'),
            ])
            ->groupBy('bucket')
            ->get()
            ->keyBy(fn ($r) => Carbon::parse($r->bucket)->toDateString());

        $collected = DB::table('payments')
            ->where('clinic_id', $clinicId)
            ->whereBetween('paid_at', [$from, $to])
            ->whereNull('deleted_at')
            ->select([
                DB::raw("$bucketPay as bucket"),
                DB::raw('COALESCE(SUM(amount), 0) as amount'),
            ])
            ->groupBy('bucket')
            ->get()
            ->keyBy(fn ($r) => Carbon::parse($r->bucket)->toDateString());

        $totalBilled = (float) $billed->sum('amount');
        $totalCollected = (float) $collected->sum('amount');

        // Outstanding = farmers.balance toplami (negatif = borc; pozitif degeri
        // ihmal et — alacak avansi). Anlik durum, tarih filtresinden bagimsiz.
        $outstanding = (float) DB::table('farmers')
            ->where('clinic_id', $clinicId)
            ->whereNull('deleted_at')
            ->where('balance', '<', 0)
            ->sum(DB::raw('-balance'));

        $keys = $billed->keys()->merge($collected->keys())->unique()->sort()->values();
        $series = $keys->map(fn ($key) => [
            'bucket' => $key,
            'billed' => (float) ($billed->get($key)->amount ?? 0),
            'collected' => (float) ($collected->get($key)->amount ?? 0),
        ])->all();

        return [
            'total_billed' => $totalBilled,
            'total_collected' => $totalCollected,
            'outstanding' => $outstanding,
            'series' => $series,
        ];
    }
}
