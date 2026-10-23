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
        Schema::create('verifikasi_laporan', function (Blueprint $table) {
            $table->id('id_verifikasi');
            $table->unsignedBigInteger('id_dlh')->nullable(); // pihak dlh yang memverifikasi
            $table->string('nip_pegawai', 50)->nullable();
            $table->unsignedTinyInteger('bulan'); // 1 - 12
            $table->unsignedSmallInteger('tahun'); // 2026
            $table->enum('status', ['menunggu', 'diverifikasi', 'ditolak'])->default('menunggu');
            $table->dateTime('tanggal_verifikasi')->nullable();
            $table->decimal('total_volume_kg', 15, 2)->default(0);
            $table->decimal('total_insentif_rp', 15, 2)->default(0);
            $table->text('catatan')->nullable();
            $table->timestamps();

            $table->foreign('id_dlh')
                ->references('id_pengguna')->on('pihak_dlh')
                ->cascadeOnUpdate()->nullOnDelete();

            $table->index(['bulan', 'tahun']);
            $table->index('status');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('verifikasi_laporan');
    }
};
