<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('warga', function (Blueprint $table) {
            $table->id('id_warga');
            $table->unsignedBigInteger('id_pengguna');
            
            // Atribut spesifik sesuai ERD
            $table->text('alamat')->nullable();
            $table->decimal('total_saldo', 15, 2)->default(0); 
            
            $table->timestamps();

            // Relasi Foreign Key ke tabel users
            $table->foreign('id_pengguna')
                  ->references('id_pengguna')->on('users')
                  ->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('warga');
    }
};