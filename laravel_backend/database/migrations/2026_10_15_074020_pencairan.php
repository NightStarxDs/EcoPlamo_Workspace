<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pencairan', function (Blueprint $table) {
            $table->id('id_pencairan');
            $table->unsignedBigInteger('id_warga');
            $table->unsignedBigInteger('id_pengaturan');
            $table->unsignedBigInteger('id_pengurus_validasi')->nullable();
            $table->decimal('nominal_pencairan', 15, 2);
            $table->enum('status', ['menunggu', 'disetujui', 'ditolak'])->default('menunggu');
            $table->dateTime('tanggal_pengajuan');
            $table->dateTime('tanggal_validasi')->nullable();
            $table->timestamps();

            $table->foreign('id_warga')
                ->references('id_pengguna')->on('warga')
                ->cascadeOnUpdate()->restrictOnDelete();
            $table->foreign('id_pengaturan')
                ->references('id_pengaturan')->on('pengaturan_pencairan')
                ->cascadeOnUpdate()->restrictOnDelete();
            $table->foreign('id_pengurus_validasi')
                ->references('id_pengguna')->on('pengurus_rtrw')
                ->cascadeOnUpdate()->nullOnDelete();

            $table->index('status');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pencairan');
    }
};