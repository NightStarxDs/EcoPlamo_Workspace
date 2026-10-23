<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('kategori_sampah', function (Blueprint $table) {
            // Kode jenis sampah sesuai daftar harga nasabah (contoh: P1, C1, K1, Mj)
            $table->string('kode', 20)->nullable()->after('id_pengurus');

            // Buat id_pengurus nullable agar data seeder tidak wajib punya pengurus
            $table->unsignedBigInteger('id_pengurus')->nullable()->change();
        });
    }

    public function down(): void
    {
        Schema::table('kategori_sampah', function (Blueprint $table) {
            $table->dropColumn('kode');
            $table->unsignedBigInteger('id_pengurus')->nullable(false)->change();
        });
    }
};
