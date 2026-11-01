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
        Schema::create('mutasi_saldo', function (Blueprint $table) {
            $table->id('id_mutasi');
            $table->unsignedBigInteger('id_warga');
            $table->unsignedBigInteger('id_setoran')->nullable();
            $table->unsignedBigInteger('id_pencairan')->nullable();
            $table->enum('tipe', ['kredit', 'debit']);
            $table->decimal('nominal', 15, 2);
            $table->decimal('saldo_setelah_mutasi', 15, 2);
            $table->timestamps();

            $table->foreign('id_warga')
                ->references('id_pengguna')->on('warga')
                ->cascadeOnUpdate()->restrictOnDelete();
            $table->foreign('id_setoran')
                ->references('id_setoran')->on('setoran')
                ->cascadeOnUpdate()->nullOnDelete();
            $table->foreign('id_pencairan')
                ->references('id_pencairan')->on('pencairan')
                ->cascadeOnUpdate()->nullOnDelete();

            $table->index('tipe');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('mutasi_saldo');
    }
};
