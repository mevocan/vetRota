<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <title>VetRota — {{ $animal->ear_tag ?? 'Hayvan' }}</title>
    <style>
        * { font-family: "DejaVu Sans", sans-serif; }
        body { margin: 0; padding: 0; color: #1a1a1a; }
        .wrap { padding: 14px 14px 10px 14px; text-align: center; }
        .brand { color: #2E7D32; font-weight: bold; font-size: 11px; letter-spacing: 1px; }
        .name { font-size: 14px; font-weight: bold; margin: 6px 0 2px 0; }
        .meta { color: #555; font-size: 9px; margin-bottom: 6px; }
        .tag {
            display: inline-block;
            background: #2E7D32;
            color: white;
            font-weight: bold;
            font-size: 11px;
            padding: 3px 10px;
            border-radius: 4px;
            margin-bottom: 6px;
        }
        .qr { width: 95px; height: 95px; margin: 0 auto; }
        .url { color: #888; font-size: 7px; margin-top: 4px; word-break: break-all; }
        .footer { color: #888; font-size: 7px; margin-top: 6px; }
    </style>
</head>
<body>
    <div class="wrap">
        <div class="brand">VETROTA</div>
        @if ($animal->name)
            <div class="name">{{ $animal->name }}</div>
        @endif
        <div class="meta">
            {{ $animal->species }}
            @if ($animal->breed) · {{ $animal->breed }} @endif
            @if ($animal->gender) · {{ $animal->gender === 'female' ? 'Disi' : ($animal->gender === 'male' ? 'Erkek' : $animal->gender) }} @endif
        </div>
        @if ($animal->ear_tag)
            <div class="tag">{{ $animal->ear_tag }}</div>
        @endif
        <img src="{{ $qrBase64 }}" class="qr" alt="QR" />
        <div class="url">{{ $url }}</div>
        <div class="footer">VetRota · Gezici veteriner platformu</div>
    </div>
</body>
</html>
