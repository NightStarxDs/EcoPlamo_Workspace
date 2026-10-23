<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pihak_dlh', function (Blueprint $table) {
            // Generalisasi: id_pengguna sebagai Primary Key sekaligus Foreign Key ke users
            $table->unsignedBigInteger('id_pengguna')->primary();
            
            $table->string('nip_pegawai')->unique();
            
            $table->timestamps();

            $table->foreign('id_pengguna')
                  ->references('id_pengguna')->on('users')
                  ->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pihak_dlh');
    }
};