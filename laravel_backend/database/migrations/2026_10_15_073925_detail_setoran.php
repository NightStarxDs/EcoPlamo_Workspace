<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('detail_setoran', function (Blueprint $table) {
            $table->id('id_detail');
            $table->unsignedBigInteger('id_setoran');
            $table->unsignedBigInteger('id_kategori');
            $table->decimal('berat_kg', 10, 2);
            $table->decimal('harga_saat_setor', 12, 2); // snapshot harga per kg saat setor
            $table->decimal('subtotal_rp', 15, 2);
            $table->timestamps();

            $table->foreign('id_setoran')
                ->references('id_setoran')->on('setoran')
                ->cascadeOnUpdate()->cascadeOnDelete();
            $table->foreign('id_kategori')
                ->references('id_kategori')->on('kategori_sampah')
                ->cascadeOnUpdate()->restrictOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('detail_setoran');
    }
};