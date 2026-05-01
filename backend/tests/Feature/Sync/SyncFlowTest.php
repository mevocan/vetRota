<?php

declare(strict_types=1);

namespace Tests\Feature\Sync;

use App\Models\Animal;
use App\Models\Clinic;
use App\Models\Drug;
use App\Models\Farmer;
use App\Models\Stock;
use App\Models\StockMovement;
use App\Models\SyncConflict;
use App\Models\User;
use App\Models\Village;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use PHPOpenSourceSaver\JWTAuth\Facades\JWTAuth;
use Tests\TestCase;

// sync-api.md §12 madde 6: 8 entegrasyon senaryosu.
class SyncFlowTest extends TestCase
{
    use RefreshDatabase;

    private string $deviceA = '11111111-1111-1111-1111-111111111111';
    private string $deviceB = '22222222-2222-2222-2222-222222222222';
    private Clinic $clinic;
    private User $vet;
    private Village $village;
    private Farmer $farmer;

    protected function setUp(): void
    {
        parent::setUp();

        $this->clinic = Clinic::create(['name' => 'Test Klinik', 'city' => 'Ankara']);
        $this->vet = User::create([
            'name' => 'Test Vet',
            'email' => 'vet@test.local',
            'password' => 'sifre1234',
            'clinic_id' => $this->clinic->id,
            'role' => 'vet',
        ]);
        $this->village = Village::create(['name' => 'Test Koy', 'district' => 'X', 'city' => 'Ankara']);
        $this->farmer = Farmer::create([
            'clinic_id' => $this->clinic->id,
            'village_id' => $this->village->id,
            'first_name' => 'Test',
            'last_name' => 'Cifci',
            'phone' => '5550000001',
        ]);
    }

    private function tokenFor(string $deviceId): string
    {
        return JWTAuth::claims([
            'clinic_id' => $this->clinic->id,
            'device_id' => $deviceId,
            'role' => $this->vet->role,
        ])->fromUser($this->vet);
    }

    private function pushAs(string $deviceId, string $syncId, array $batch)
    {
        return $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->tokenFor($deviceId),
            'X-Device-Id' => $deviceId,
            'Accept' => 'application/json',
        ])->postJson('/api/v1/sync/push', [
            'client_sync_id' => $syncId,
            'device_id' => $deviceId,
            'client_time' => now()->toIso8601String(),
            'batch' => $batch,
        ]);
    }

    private function pullAs(string $deviceId, string $since, array $extra = [])
    {
        return $this->withHeaders([
            'Authorization' => 'Bearer ' . $this->tokenFor($deviceId),
            'X-Device-Id' => $deviceId,
            'Accept' => 'application/json',
        ])->getJson('/api/v1/sync/pull?' . http_build_query(array_merge(['since' => $since], $extra)));
    }

    private function animalPayload(string $id, int $expectedVersion = 0, array $overrides = []): array
    {
        return [
            'op' => 'upsert',
            'id' => $id,
            'expected_version' => $expectedVersion,
            'client_last_modified_at' => now()->toIso8601String(),
            'data' => array_merge([
                'farmer_id' => $this->farmer->id,
                'village_id' => $this->village->id,
                'ear_tag' => 'TR-TEST-' . substr($id, 0, 4),
                'name' => 'Hayvan',
                'species' => 'cattle',
                'gender' => 'female',
                'status' => 'alive',
            ], $overrides),
        ];
    }

    public function test_basit_push_yeni_kayitlar_kabul_edilir(): void
    {
        $animalId = (string) Str::uuid();

        $resp = $this->pushAs($this->deviceA, 'sync-test-1', [
            'animals' => [$this->animalPayload($animalId)],
        ]);

        $resp->assertOk()
            ->assertJsonPath('results.accepted.0.table', 'animals')
            ->assertJsonPath('results.accepted.0.id', $animalId)
            ->assertJsonPath('results.accepted.0.new_version', 1)
            ->assertJsonCount(0, 'results.conflicts')
            ->assertJsonCount(0, 'results.rejected');

        $this->assertDatabaseHas('animals', [
            'id' => $animalId,
            'version' => 1,
            'origin_device_id' => $this->deviceA,
        ]);
    }

    public function test_update_push_version_eslesirse_kabul_edilir(): void
    {
        $animalId = (string) Str::uuid();
        $this->pushAs($this->deviceA, 'sync-test-1', ['animals' => [$this->animalPayload($animalId)]])->assertOk();

        $update = $this->animalPayload($animalId, 1, ['name' => 'Yeni Isim']);
        $resp = $this->pushAs($this->deviceA, 'sync-test-2', ['animals' => [$update]]);

        $resp->assertOk()
            ->assertJsonPath('results.accepted.0.new_version', 2)
            ->assertJsonCount(0, 'results.conflicts');

        $this->assertSame('Yeni Isim', Animal::find($animalId)->name);
        $this->assertSame(2, Animal::find($animalId)->version);
    }

    public function test_lww_conflict_client_kazanir(): void
    {
        $animalId = (string) Str::uuid();
        $this->pushAs($this->deviceA, 'sync-test-1', ['animals' => [$this->animalPayload($animalId)]])->assertOk();

        // Server version simdi 1; ama deviceB hala 0 oldugunu sanan bir update gonderiyor.
        $stale = $this->animalPayload($animalId, 0, ['name' => 'B Update']);
        $resp = $this->pushAs($this->deviceB, 'sync-test-2', ['animals' => [$stale]]);

        $resp->assertOk()
            ->assertJsonCount(0, 'results.accepted')
            ->assertJsonCount(1, 'results.conflicts')
            ->assertJsonPath('results.conflicts.0.resolution', 'client_won')
            ->assertJsonPath('results.conflicts.0.server_version', 2);

        $this->assertSame('B Update', Animal::find($animalId)->name);
        $this->assertDatabaseHas('sync_conflicts', [
            'record_id' => $animalId,
            'resolution' => 'resolved_local',
        ]);
    }

    public function test_delete_vs_update_cakismasi_server_won_deleted(): void
    {
        $animalId = (string) Str::uuid();
        $this->pushAs($this->deviceA, 'sync-test-1', ['animals' => [$this->animalPayload($animalId)]])->assertOk();

        // deviceA siler.
        $del = ['op' => 'delete', 'id' => $animalId, 'expected_version' => 1];
        $this->pushAs($this->deviceA, 'sync-test-2', ['animals' => [$del]])->assertOk();

        // deviceB silinmis kaydi update etmeye calisir.
        $update = $this->animalPayload($animalId, 1, ['name' => 'Geri Geldim']);
        $resp = $this->pushAs($this->deviceB, 'sync-test-3', ['animals' => [$update]]);

        $resp->assertOk()
            ->assertJsonCount(1, 'results.conflicts')
            ->assertJsonPath('results.conflicts.0.resolution', 'server_won_deleted');

        // Hayvan silinmis kalmali.
        $this->assertSoftDeleted('animals', ['id' => $animalId]);
    }

    public function test_pull_echo_prevention_kendi_yazdigini_almaz(): void
    {
        $animalId = (string) Str::uuid();
        $this->pushAs($this->deviceA, 'sync-test-1', ['animals' => [$this->animalPayload($animalId)]])->assertOk();

        // deviceA pull yapinca kendi push'unu görmemeli.
        $respA = $this->pullAs($this->deviceA, '1970-01-01T00:00:00Z');
        $respA->assertOk();
        $animalsA = collect($respA->json('data.animals'))->pluck('id')->all();
        $this->assertNotContains($animalId, $animalsA, 'echo prevention bozuk');

        // deviceB pull yapinca görmeli.
        $respB = $this->pullAs($this->deviceB, '1970-01-01T00:00:00Z');
        $animalsB = collect($respB->json('data.animals'))->pluck('id')->all();
        $this->assertContains($animalId, $animalsB);
    }

    public function test_idempotent_retry_ayni_sync_id_duplicate_yaratmaz(): void
    {
        $animalId = (string) Str::uuid();
        $payload = ['animals' => [$this->animalPayload($animalId)]];

        $r1 = $this->pushAs($this->deviceA, 'sync-retry-1', $payload);
        $r1->assertOk()->assertJsonPath('results.accepted.0.new_version', 1);

        // Ayni client_sync_id ile yeniden gonder.
        $r2 = $this->pushAs($this->deviceA, 'sync-retry-1', $payload);
        $r2->assertOk()->assertJsonPath('results.accepted.0.new_version', 1);

        $this->assertSame(1, Animal::where('id', $animalId)->count());
        $this->assertSame(1, Animal::find($animalId)->version, 'Retry version 2 yapmamali');
    }

    public function test_cursor_pagination_limit_asildiginda_devam_kursoru_doner(): void
    {
        // 5 hayvan ekle, limit=2 ile pull et, 3 sayfa olsun.
        $ids = [];
        for ($i = 0; $i < 5; $i++) {
            $id = (string) Str::uuid();
            $ids[] = $id;
            // farkli last_modified_at icin saniye araliyla insert.
            Animal::query()->forceCreate([
                'id' => $id,
                'clinic_id' => $this->clinic->id,
                'farmer_id' => $this->farmer->id,
                'village_id' => $this->village->id,
                'ear_tag' => "TR-PAG-$i",
                'name' => "Hayvan $i",
                'species' => 'cattle',
                'gender' => 'female',
                'status' => 'alive',
                'origin_device_id' => null, // pull'a görünür olsun
                'last_modified_at' => now()->addSeconds($i),
            ]);
        }

        $seen = [];
        $cursor = null;
        $loops = 0;
        do {
            $resp = $this->pullAs($this->deviceA, '1970-01-01T00:00:00Z', array_filter([
                'limit' => 2,
                'cursor' => $cursor,
            ]));
            $resp->assertOk();
            foreach ($resp->json('data.animals') ?? [] as $row) {
                $seen[] = $row['id'];
            }
            $cursor = $resp->json('next_cursor');
            $loops++;
        } while ($resp->json('has_more') && $loops < 10);

        $this->assertSame(sort($ids) ? $ids : $ids, sort($seen) ? $seen : $seen);
        $this->assertCount(5, array_unique($seen));
        $this->assertGreaterThan(1, $loops, 'pagination tek sayfada bitmemeli');
    }

    public function test_ledger_delete_reddedilir_stock_movements(): void
    {
        $drug = Drug::create([
            'clinic_id' => $this->clinic->id,
            'name' => 'Test Ilac',
            'drug_type' => 'antibiotic',
            'unit' => 'ml',
        ]);
        $stock = Stock::create([
            'clinic_id' => $this->clinic->id,
            'drug_id' => $drug->id,
            'current_quantity' => 100,
            'critical_threshold' => 10,
        ]);
        $movement = StockMovement::create([
            'clinic_id' => $this->clinic->id,
            'stock_id' => $stock->id,
            'drug_id' => $drug->id,
            'movement_type' => 'purchase',
            'quantity' => 100,
            'performed_by' => $this->vet->id,
            'occurred_at' => now(),
        ]);
        $movement->refresh(); // trigger version=1'i set etti, in-memory'ye yansit

        $resp = $this->pushAs($this->deviceA, 'sync-test-del-1', [
            'stock_movements' => [[
                'op' => 'delete',
                'id' => $movement->id,
                'expected_version' => $movement->version,
            ]],
        ]);

        $resp->assertOk()
            ->assertJsonCount(0, 'results.accepted')
            ->assertJsonCount(1, 'results.rejected')
            ->assertJsonPath('results.rejected.0.reason', 'ledger_immutable');

        // Ledger kayitlarinda soft delete yok; var olmali.
        $this->assertSame(1, StockMovement::where('id', $movement->id)->count());
    }
}
