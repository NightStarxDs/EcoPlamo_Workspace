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
            $table->string('deskripsi')->nullable();           // contoh: "Kering dan diikat rapi"
            $table->decimal('harga_per_kg', 12, 2)->default(0);
            $table->string('satuan', 20)->default('Kg');       // Kg atau Liter
            $table->string('jenis', 50)->nullable();           // untuk chip filter: Botol, Kardus, dll
            $table->string('gambar')->nullable();              // path gambar (opsional)
            $table->enum('status', ['aktif', 'nonaktif'])->default('aktif');
            $table->timestamps(); // created_at & updated_at

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