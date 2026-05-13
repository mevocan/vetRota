<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <title>VetRota Recete — {{ $prescription->prescription_number }}</title>
    <style>
        * { font-family: "DejaVu Sans", sans-serif; }
        body { margin: 0; padding: 0; color: #1a1a1a; font-size: 11px; }
        .wrap { padding: 24px 28px; }
        .brand { color: #2E7D32; font-weight: bold; font-size: 16px; letter-spacing: 2px; }
        .header { border-bottom: 2px solid #2E7D32; padding-bottom: 8px; margin-bottom: 14px; }
        .header .right { float: right; text-align: right; color: #555; font-size: 10px; }
        .title { font-size: 18px; font-weight: bold; margin: 10px 0 12px 0; }
        .section { margin-bottom: 12px; }
        .section h3 { color: #1B5E20; font-size: 12px; margin: 0 0 4px 0; }
        table { width: 100%; border-collapse: collapse; margin-top: 4px; }
        th { background: #f0f4f0; color: #1B5E20; text-align: left; padding: 6px 8px; font-size: 10px; border-bottom: 1px solid #cfd8cf; }
        td { padding: 6px 8px; border-bottom: 1px solid #eee; font-size: 10px; vertical-align: top; }
        .meta { color: #555; font-size: 10px; }
        .meta strong { color: #1a1a1a; }
        .notes { background: #fafaf6; padding: 8px 10px; border-left: 3px solid #FF9800; color: #333; }
        .sign { margin-top: 36px; }
        .sign .line { border-top: 1px solid #888; width: 200px; padding-top: 4px; color: #555; font-size: 10px; }
        .footer { color: #888; font-size: 8px; text-align: center; margin-top: 24px; border-top: 1px solid #eee; padding-top: 6px; }
    </style>
</head>
<body>
<div class="wrap">
    <div class="header">
        <div class="right">
            <div><strong>{{ $prescription->prescription_number }}</strong></div>
            <div>{{ $prescription->created_at->format('d.m.Y H:i') }}</div>
        </div>
        <div class="brand">VETROTA</div>
        <div class="meta">{{ $clinic?->name }} @if($clinic?->city) · {{ $clinic->city }} @endif</div>
    </div>

    <div class="title">Recete</div>

    <div class="section">
        <h3>Ciftci</h3>
        <div class="meta">
            <strong>{{ $farmer->first_name }} {{ $farmer->last_name }}</strong>
            @if($farmer->phone) · {{ $farmer->phone }} @endif
        </div>
    </div>

    <div class="section">
        <h3>Hayvan</h3>
        <div class="meta">
            <strong>{{ $animal->name ?: $animal->ear_tag }}</strong>
            · {{ $animal->species }}
            @if($animal->breed) · {{ $animal->breed }} @endif
            @if($animal->ear_tag) · Kupe: {{ $animal->ear_tag }} @endif
        </div>
    </div>

    <div class="section">
        <h3>Tani</h3>
        <div class="meta">
            @if($mr->chief_complaint)<div><strong>Sikayet:</strong> {{ $mr->chief_complaint }}</div>@endif
            @if($mr->diagnosis_notes)<div><strong>Tani:</strong> {{ $mr->diagnosis_notes }}</div>@endif
        </div>
    </div>

    <div class="section">
        <h3>Ilaclar</h3>
        @if($drugs->isEmpty())
            <div class="meta">Ilac yok.</div>
        @else
            <table>
                <thead>
                <tr>
                    <th>Ilac</th>
                    <th>Doz</th>
                    <th>Yol</th>
                    <th>Kullanim</th>
                </tr>
                </thead>
                <tbody>
                @foreach($drugs as $d)
                    <tr>
                        <td><strong>{{ $d->drug?->name ?? '—' }}</strong>@if($d->drug?->active_ingredient) <br><span style="color:#888">{{ $d->drug->active_ingredient }}</span>@endif</td>
                        <td>{{ rtrim(rtrim(number_format((float)$d->quantity, 3, '.', ''), '0'), '.') }} {{ $d->unit }}</td>
                        <td>{{ $d->route ?: '—' }}</td>
                        <td>{{ $d->frequency ?: '—' }}</td>
                    </tr>
                    @if($d->notes)
                        <tr><td colspan="4" style="color:#666;font-style:italic;">{{ $d->notes }}</td></tr>
                    @endif
                @endforeach
                </tbody>
            </table>
        @endif
    </div>

    @if($prescription->notes)
        <div class="section">
            <h3>Notlar</h3>
            <div class="notes">{!! nl2br(e($prescription->notes)) !!}</div>
        </div>
    @endif

    @if($mr->recommendations)
        <div class="section">
            <h3>Oneriler</h3>
            <div class="meta">{!! nl2br(e($mr->recommendations)) !!}</div>
        </div>
    @endif

    <div class="sign">
        <div class="line">
            {{ $vet?->name ?? 'Veteriner' }}<br>
            <span style="color:#888">Veteriner Hekim · Imza</span>
        </div>
    </div>

    <div class="footer">VetRota · Gezici veteriner platformu · {{ $prescription->prescription_number }}</div>
</div>
</body>
</html>
