<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SmsMessage extends Model
{
    use HasFactory, HasUuids;

    protected $fillable = [
        'id', 'clinic_id', 'farmer_id', 'phone', 'body', 'sender_id',
        'trigger_type', 'trigger_reference_type', 'trigger_reference_id',
        'portal_token_id', 'status', 'provider', 'provider_message_id',
        'attempts', 'last_error', 'queued_at', 'sent_at', 'delivered_at',
        'cost', 'sms_segment_count',
    ];

    protected $casts = [
        'queued_at' => 'datetime',
        'sent_at' => 'datetime',
        'delivered_at' => 'datetime',
        'cost' => 'decimal:4',
        'attempts' => 'integer',
        'sms_segment_count' => 'integer',
    ];

    public function clinic(): BelongsTo
    {
        return $this->belongsTo(Clinic::class);
    }

    public function farmer(): BelongsTo
    {
        return $this->belongsTo(Farmer::class);
    }
}
