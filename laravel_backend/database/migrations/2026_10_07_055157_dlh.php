<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('dlh', function (Blueprint $table) {
            $table->id('id_dlh');
            $table->unsignedBigInteger('id_pengguna');
            
            // Atribut spesifik sesuai ERD
            $table->string('nip_pegawai')->unique();
            
            $table->timestamps();

            $table->foreign('id_pengguna')
                  ->references('id_pengguna')->on('users')
                  ->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('dlh');
    }
};