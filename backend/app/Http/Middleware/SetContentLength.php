<?php

declare(strict_types=1);

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\BinaryFileResponse;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\StreamedResponse;

/**
 * Yanita acik Content-Length ekler.
 *
 * Neden: `php artisan serve` (PHP yerlesik sunucu) buyuk JSON yanitlarini
 * Content-Length veya chunked encoding olmadan, sadece "Connection: close"
 * ile gonderebiliyor. Dart/Dio'nun HttpClient'i bu close-delimited buyuk
 * govdeyi tam toplayamayip JSON parse hatasi (FormatException) veriyordu.
 * Content-Length set edilince istemci kac bayt okuyacagini bilir; sorun biter.
 * Prod'da da zararsiz/faydalidir.
 */
class SetContentLength
{
    public function handle(Request $request, Closure $next): Response
    {
        /** @var Response $response */
        $response = $next($request);

        // Stream/binary yanitlarda govde bellekte degil; dokunma.
        if ($response instanceof StreamedResponse || $response instanceof BinaryFileResponse) {
            return $response;
        }

        // Zaten varsa veya govde bos degilse hesapla.
        if (!$response->headers->has('Content-Length')) {
            $content = $response->getContent();
            if ($content !== false) {
                $response->headers->set('Content-Length', (string) strlen($content));
            }
        }

        return $response;
    }
}
