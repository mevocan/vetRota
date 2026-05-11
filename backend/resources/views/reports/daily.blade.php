<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <title>Gunluk Rapor — {{ $date }}</title>
    <style>
        * { font-family: "DejaVu Sans", sans-serif; }
        body { font-family: "DejaVu Sans", sans-serif; font-size: 12px; color: #1a1a1a; }
        h1 { color: #2E7D32; font-size: 20px; margin-bottom: 4px; }
        .meta { color: #555; margin-bottom: 16px; }
        .summary-grid { width: 100%; border-collapse: collapse; margin-bottom: 16px; }
        .summary-grid td { padding: 8px 12px; border: 1px solid #ddd; }
        .summary-grid td.label { background: #f5f5f5; width: 40%; font-weight: bold; }
        h2 { color: #2E7D32; font-size: 14px; margin-top: 20px; border-bottom: 2px solid #2E7D32; padding-bottom: 4px; }
        table.drugs { width: 100%; border-collapse: collapse; margin-top: 8px; }
        table.drugs th, table.drugs td { padding: 6px 10px; border: 1px solid #ddd; text-align: left; }
        table.drugs th { background: #2E7D32; color: white; }
        .footer { margin-top: 32px; text-align: center; color: #888; font-size: 10px; }
    </style>
</head>
<body>
    <h1>VetRota — Gunluk Rapor</h1>
    <div class="meta">
        <strong>Veteriner:</strong> {{ $vetName }}<br>
        <strong>Tarih:</strong> {{ $date }}<br>
        <strong>Olusturuldu:</strong> {{ $generatedAt }}
    </div>

    <table class="summary-grid">
        <tr><td class="label">Ziyaret edilen hayvan</td><td>{{ $report->animals_visited }}</td></tr>
        <tr><td class="label">Muayene sayisi</td><td>{{ $report->medical_records_count }}</td></tr>
        <tr><td class="label">Toplam mesafe</td><td>{{ $report->total_distance_km !== null ? number_format((float) $report->total_distance_km, 2) . ' km' : '-' }}</td></tr>
        <tr><td class="label">Toplam hasilat</td><td>{{ number_format((float) $report->total_revenue, 2) }} TL</td></tr>
    </table>

    <h2>Kullanilan ilaclar</h2>
    @if (empty($report->drugs_used))
        <p>Bugun ilac kullanilmadi.</p>
    @else
        <table class="drugs">
            <thead>
                <tr><th>Ilac</th><th>Miktar</th><th>Birim</th></tr>
            </thead>
            <tbody>
                @foreach ($report->drugs_used as $row)
                    <tr>
                        <td>{{ $row['name'] ?? '(adsiz)' }}</td>
                        <td>{{ number_format((float) ($row['total_quantity'] ?? 0), 2) }}</td>
                        <td>{{ $row['unit'] ?? '-' }}</td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    @endif

    <div class="footer">
        VetRota · Gezici veteriner saha yonetim platformu
    </div>
</body>
</html>
