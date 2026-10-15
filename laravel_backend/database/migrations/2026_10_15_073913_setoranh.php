<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('setoran', function (Blueprint $table) {
            $table->id('id_setoran');
            $table->unsignedBigInteger('id_warga');
            $table->unsignedBigInteger('id_pengurus'); // pengurus yang mencatat
            $table->date('tanggal');
            $table->decimal('total_berat_kg', 10, 2)->default(0);
            $table->decimal('total_nilai_rp', 15, 2)->default(0);
            $table->timestamps();

            $table->foreign('id_warga')
                ->references('id_pengguna')->on('warga')
                ->cascadeOnUpdate()->restrictOnDelete();
            $table->foreign('id_pengurus')
                ->references('id_pengguna')->on('pengurus_rtrw')
                ->cascadeOnUpdate()->restrictOnDelete();

            $table->index('tanggal');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('setoran');
    }
};