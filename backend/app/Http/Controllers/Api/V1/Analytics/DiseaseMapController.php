<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Analytics;

use App\Http\Controllers\Controller;
use App\Services\Analytics\DiseaseMapService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

// M7.6.2: Hastalik haritasi endpoint'i.
// GET /api/v1/analytics/disease-map?from=&to=&species=
class DiseaseMapController extends Controller
{
    public function __construct(
        private readonly DiseaseMapService $service,
    ) {}

    public function __invoke(Request $request): JsonResponse
    {
        $data = $request->validate([
            'from' => ['nullable', 'date'],
            'to' => ['nullable', 'date'],
            'species' => ['nullable', 'string', 'max:32'],
        ]);

        $to = isset($data['to']) ? Carbon::parse($data['to'])->endOfDay() : now()->endOfDay();
        $from = isset($data['from'])
            ? Carbon::parse($data['from'])->startOfDay()
            : $to->copy()->subDays(30)->startOfDay();

        /** @var \App\Models\User $user */
        $user = auth()->user();
        $villages = $this->service->villages(
            clinicId: (string) $user->clinic_id,
            from: $from,
            to: $to,
            species: $data['species'] ?? null,
        );

        $total = array_sum(array_map(fn ($v) => $v['case_count'], $villages));

        return response()->json([
            'from' => $from->toDateString(),
            'to' => $to->toDateString(),
            'species' => $data['species'] ?? null,
            'total_cases' => $total,
            'villages' => $villages,
        ]);
    }
}
