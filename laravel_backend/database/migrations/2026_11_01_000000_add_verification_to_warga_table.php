<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('warga', function (Blueprint $table) {
            if (!Schema::hasColumn('warga', 'status_verifikasi')) {
                $table->enum('status_verifikasi', ['menunggu', 'terverifikasi', 'ditolak'])
                      ->default('menunggu')
                      ->after('total_saldo');
            }
            if (!Schema::hasColumn('warga', 'nomor_tiket')) {
                $table->string('nomor_tiket', 50)->nullable()->after('status_verifikasi');
            }
            if (!Schema::hasColumn('warga', 'uang_pendaftaran')) {
                $table->decimal('uang_pendaftaran', 15, 2)->default(0)->after('nomor_tiket');
            }
            if (!Schema::hasColumn('warga', 'status_pembayaran')) {
                $table->enum('status_pembayaran', ['belum_lunas', 'lunas'])
                      ->default('lunas')
                      ->after('uang_pendaftaran');
            }
            if (!Schema::hasColumn('warga', 'verified_at')) {
                $table->timestamp('verified_at')->nullable()->after('status_pembayaran');
            }
            if (!Schema::hasColumn('warga', 'verified_by')) {
                $table->unsignedBigInteger('verified_by')->nullable()->after('verified_at');
            }
            if (!Schema::hasColumn('warga', 'catatan_verifikasi')) {
                $table->text('catatan_verifikasi')->nullable()->after('verified_by');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('warga', function (Blueprint $table) {
            $table->dropColumn([
                'status_verifikasi',
                'nomor_tiket',
                'uang_pendaftaran',
                'status_pembayaran',
                'verified_at',
                'verified_by',
                'catatan_verifikasi',
            ]);
        });
    }
};
