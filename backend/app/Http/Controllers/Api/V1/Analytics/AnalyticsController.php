<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Analytics;

use App\Http\Controllers\Controller;
use App\Services\Analytics\DrugConsumptionService;
use App\Services\Analytics\RevenueService;
use App\Services\Analytics\VetPerformanceService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

// M8.1: Klinik sahibi analitik paneli endpoint'leri.
// from/to opsiyonel (default son 30 gun).
class AnalyticsController extends Controller
{
    public function __construct(
        private readonly VetPerformanceService $vetService,
        private readonly DrugConsumptionService $drugService,
        private readonly RevenueService $revenueService,
    ) {}

    public function vetPerformance(Request $request): JsonResponse
    {
        [$from, $to] = $this->resolveRange($request);
        $rows = $this->vetService->summary($this->clinicId(), $from, $to);

        return response()->json([
            'from' => $from->toDateString(),
            'to' => $to->toDateString(),
            'rows' => $rows,
        ]);
    }

    public function drugConsumption(Request $request): JsonResponse
    {
        [$from, $to] = $this->resolveRange($request);
        $rows = $this->drugService->summary($this->clinicId(), $from, $to);

        return response()->json([
            'from' => $from->toDateString(),
            'to' => $to->toDateString(),
            'rows' => $rows,
        ]);
    }

    public function revenue(Request $request): JsonResponse
    {
        $request->validate([
            'group_by' => ['nullable', 'in:day,week,month'],
        ]);
        [$from, $to] = $this->resolveRange($request);
        $groupBy = $request->string('group_by', 'day')->toString();

        $data = $this->revenueService->summary(
            $this->clinicId(),
            $from,
            $to,
            $groupBy,
        );

        return response()->json([
            'from' => $from->toDateString(),
            'to' => $to->toDateString(),
            'group_by' => $groupBy,
            ...$data,
        ]);
    }

    /** @return array{0: Carbon, 1: Carbon} */
    private function resolveRange(Request $request): array
    {
        $request->validate([
            'from' => ['nullable', 'date'],
            'to' => ['nullable', 'date'],
        ]);
        $to = $request->filled('to')
            ? Carbon::parse((string) $request->input('to'))->endOfDay()
            : now()->endOfDay();
        $from = $request->filled('from')
            ? Carbon::parse((string) $request->input('from'))->startOfDay()
            : $to->copy()->subDays(30)->startOfDay();

        return [$from, $to];
    }

    private function clinicId(): string
    {
        /** @var \App\Models\User $user */
        $user = auth()->user();
        return (string) $user->clinic_id;
    }
}
