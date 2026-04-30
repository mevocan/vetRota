<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreStockMovementRequest;
use App\Models\Drug;
use App\Models\StockMovement;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class StockMovementController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = StockMovement::query()
            ->with([
                'drug:id,name,unit',
                'performedBy:id,name',
            ]);

        if ($drugId = $request->string('drug_id')->value()) {
            $query->where('drug_id', $drugId);
        }
        if ($type = $request->string('movement_type')->value()) {
            $query->where('movement_type', $type);
        }
        if ($from = $request->string('from')->value()) {
            $query->where('occurred_at', '>=', $from);
        }
        if ($to = $request->string('to')->value()) {
            $query->where('occurred_at', '<=', $to);
        }

        $perPage = min((int) $request->integer('per_page', 50), 200);

        return response()->json($query->orderByDesc('occurred_at')->paginate($perPage));
    }

    public function store(StoreStockMovementRequest $request): JsonResponse
    {
        $data = $request->validated();

        // stock_id otomatik = ilaca ait stok kaydi (her drug'in tam 1 stock'u var).
        $drug = Drug::with('stock')->findOrFail($data['drug_id']);
        if (!$drug->stock) {
            return response()->json([
                'message' => 'Bu ilaç için stok kaydı bulunamadı.',
            ], 422);
        }

        $data['stock_id'] = $drug->stock->id;
        $data['performed_by'] = $request->user()->id;

        $movement = StockMovement::create($data);
        $movement->load(['drug:id,name,unit', 'performedBy:id,name']);

        return response()->json(['data' => $movement], 201);
    }
}
