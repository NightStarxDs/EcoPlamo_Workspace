<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('warga', function (Blueprint $table) {
            $table->string('tipe_hunian', 30)->nullable()->after('id_pengguna');
            $table->string('nomor_hunian', 100)->nullable()->after('alamat');
        });
    }

    public function down(): void
    {
        Schema::table('warga', function (Blueprint $table) {
            $table->dropColumn(['tipe_hunian', 'nomor_hunian']);
        });
    }
};
