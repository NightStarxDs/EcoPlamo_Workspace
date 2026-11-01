<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('kategori_sampah', function (Blueprint $table) {
            $table->id('id_kategori');
            $table->unsignedBigInteger('id_pengurus');
            $table->string('nama_kategori', 100);
            $table->text('deskripsi')->nullable();             // Deskripsi kategori sampah
            $table->decimal('harga_per_kg', 12, 2)->default(0); // Harga per kilogram/liter
            $table->string('satuan', 20)->default('Kg');       // Satuan: Kg atau Liter
            $table->string('jenis', 50)->nullable();           // Jenis sampah: Botol, Kardus, Logam, Minyak, dll
            $table->string('gambar')->nullable();              // Path gambar kategori
            $table->enum('status', ['aktif', 'nonaktif'])->default('aktif');
            $table->timestamps();

            $table->foreign('id_pengurus')
                ->references('id_pengguna')->on('pengurus_rtrw')
                ->cascadeOnUpdate()->restrictOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('kategori_sampah');
    }
};