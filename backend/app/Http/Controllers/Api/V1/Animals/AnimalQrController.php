<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Animals;

use App\Http\Controllers\Controller;
use App\Models\Animal;
use Barryvdh\DomPDF\Facade\Pdf;
use Endroid\QrCode\Builder\Builder;
use Endroid\QrCode\Writer\PngWriter;
use Illuminate\Http\Response;

// M7.2: Hayvan icin QR etiket PDF.
// QR icerigi: {SMS_PORTAL_BASE_URL}/animal/{ear_tag} — public hayvan
// sayfasi sonradan eklenecek (yer tutucu URL).
//
// Cikti: A6 boyutunda tek sayfa, ortada kupe + ad + tur + QR.
class AnimalQrController extends Controller
{
    public function __invoke(Animal $animal): Response
    {
        /** @var \App\Models\User $user */
        $user = auth()->user();
        abort_unless($animal->clinic_id === $user->clinic_id, 404);

        $tag = $animal->ear_tag ?? $animal->id;
        $baseUrl = rtrim(config('app.portal_base_url') ?? env('SMS_PORTAL_BASE_URL') ?? 'https://vetrota.com.tr', '/');
        $url = $baseUrl . '/animal/' . $tag;

        $qrResult = Builder::create()
            ->writer(new PngWriter())
            ->data($url)
            ->size(380)
            ->margin(0)
            ->build();
        $qrBase64 = 'data:image/png;base64,' . base64_encode($qrResult->getString());

        $pdf = Pdf::loadView('reports.animal_qr', [
            'animal' => $animal,
            'qrBase64' => $qrBase64,
            'url' => $url,
        ])->setPaper('a6');

        return response($pdf->output(), 200, [
            'Content-Type' => 'application/pdf',
            'Content-Disposition' => 'attachment; filename="vetrota-' . $tag . '.pdf"',
        ]);
    }
}
