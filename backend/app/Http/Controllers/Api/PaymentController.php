<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Payment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

// M7.3: Odeme CRUD (silme yok, sadece read/create/update — ledger sozlesmesi).
class PaymentController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        /** @var \App\Models\User $user */
        $user = auth()->user();
        $q = Payment::where('clinic_id', $user->clinic_id);

        if ($farmer = $request->query('farmer_id')) {
            $q->where('farmer_id', $farmer);
        }
        $perPage = min((int) $request->integer('per_page', 25), 100);
        return response()->json($q->orderByDesc('paid_at')->paginate($perPage));
    }

    public function store(Request $request): JsonResponse
    {
        /** @var \App\Models\User $user */
        $user = auth()->user();

        $data = Validator::make($request->all(), [
            'farmer_id' => 'required|uuid|exists:farmers,id',
            'amount' => 'required|numeric',
            'method' => 'nullable|string|max:32',
            'paid_at' => 'nullable|date',
            'notes' => 'nullable|string|max:500',
        ])->validate();

        $data['clinic_id'] = $user->clinic_id;
        $data['vet_id'] = $user->id;
        $data['method'] = $data['method'] ?? 'cash';
        $data['paid_at'] = $data['paid_at'] ?? now();

        $payment = Payment::create($data);
        return response()->json(['data' => $payment->fresh()], 201);
    }
}
