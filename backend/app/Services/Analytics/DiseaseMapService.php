<?php

declare(strict_types=1);

namespace App\Services\Analytics;

use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

// M7.6: Hastalik haritasi servisi.
// Verilen tarih araliginda (ve opsiyonel turde) muayene sayilari koy
// bazinda gruplanir. En sik gecen 3 keyword chief_complaint + symptoms
// metinlerinden cikarilir (basit kelime frekansi; stemming yok).
class DiseaseMapService
{
    // Cok genel kelimeleri filtrele — keyword'lerin anlamli olmasi icin.
    private const STOPWORDS = [
        've','ile','bir','icin','olarak','yok','var','ama','de','da','mi',
        'her','en','bu','su','o','ki','gibi','degil','daha','cok','az',
        'the','and','or','of','to','a','in','on','at','for','is','are',
    ];

    /**
     * @return array<int, array<string, mixed>>
     */
    public function villages(
        string $clinicId,
        Carbon $from,
        Carbon $to,
        ?string $species = null,
    ): array {
        $base = DB::table('medical_records as mr')
            ->join('animals as a', 'a.id', '=', 'mr.animal_id')
            ->join('villages as v', 'v.id', '=', 'mr.village_id')
            ->where('mr.clinic_id', $clinicId)
            ->whereBetween('mr.examined_at', [$from, $to])
            ->whereNull('mr.deleted_at')
            ->whereNotNull('mr.village_id');

        if ($species !== null && $species !== '') {
            $base->where('a.species', $species);
        }

        $counts = (clone $base)
            ->select([
                'v.id as village_id',
                'v.name as village_name',
                'v.district',
                'v.lat',
                'v.lng',
                DB::raw('COUNT(*) as case_count'),
            ])
            ->groupBy('v.id', 'v.name', 'v.district', 'v.lat', 'v.lng')
            ->orderByDesc('case_count')
            ->get();

        $rows = (clone $base)
            ->select(['mr.village_id', 'mr.chief_complaint', 'mr.symptoms'])
            ->get();

        // village_id => [keyword => count]
        $byVillage = [];
        foreach ($rows as $r) {
            $text = mb_strtolower(
                trim(($r->chief_complaint ?? '') . ' ' . ($r->symptoms ?? '')),
                'UTF-8'
            );
            if ($text === '') {
                continue;
            }
            $words = preg_split('/[^\p{L}\p{N}]+/u', $text) ?: [];
            foreach ($words as $w) {
                $w = trim($w);
                if (mb_strlen($w, 'UTF-8') < 3) {
                    continue;
                }
                if (in_array($w, self::STOPWORDS, true)) {
                    continue;
                }
                $byVillage[$r->village_id][$w] = ($byVillage[$r->village_id][$w] ?? 0) + 1;
            }
        }

        return $counts->map(function ($v) use ($byVillage) {
            $keywords = $byVillage[$v->village_id] ?? [];
            arsort($keywords);
            $top = array_slice(array_keys($keywords), 0, 3);
            return [
                'village_id' => $v->village_id,
                'village_name' => $v->village_name,
                'district' => $v->district,
                'lat' => $v->lat !== null ? (float) $v->lat : null,
                'lng' => $v->lng !== null ? (float) $v->lng : null,
                'case_count' => (int) $v->case_count,
                'top_keywords' => $top,
            ];
        })->all();
    }
}
