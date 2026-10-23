<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pengaturan_pencairan', function (Blueprint $table) {
            $table->id('id_pengaturan');
            $table->unsignedBigInteger('id_pengurus');
            $table->decimal('target_minimal', 15, 2); // saldo minimal untuk mencairkan
            $table->date('tanggal_mulai');
            $table->date('tanggal_selesai');
            $table->timestamp('created_at')->useCurrent();

            $table->foreign('id_pengurus')
                ->references('id_pengguna')->on('pengurus_rtrw')
                ->cascadeOnUpdate()->restrictOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pengaturan_pencairan');
    }
};