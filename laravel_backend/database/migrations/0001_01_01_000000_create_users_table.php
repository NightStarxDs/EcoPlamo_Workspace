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
        Schema::create('users', function (Blueprint $table) {
            $table->id('id_pengguna'); // Biarkan bawaan Laravel

            // Ganti 'name' menjadi 'nama' agar sesuai ERD
            $table->string('nama_lengkap'); 
            
            // Ganti 'email' menjadi 'no_whatsapp'
            $table->string('no_whatsapp')->unique(); 
            
            // Ganti 'email_verified_at' menjadi verifikasi whatsapp (opsional jika pakai OTP)
            $table->timestamp('whatsapp_verified_at')->nullable(); 
            
            $table->string('password');
            
            // TAMBAHAN WAJIB: Kolom role dari ERD
            $table->enum('role', ['warga', 'pengurus', 'dlh'])->default('warga');
            
            $table->rememberToken();
            $table->timestamps();
        });

        Schema::create('password_reset_tokens', function (Blueprint $table) {
            $table->string('no_whatsapp')->primary();
            $table->string('token');
            $table->timestamp('created_at')->nullable();
        });

        Schema::create('sessions', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->foreignId('user_id')->nullable()->index();
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();
            $table->longText('payload');
            $table->integer('last_activity')->index();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('users');
        Schema::dropIfExists('password_reset_tokens');
        Schema::dropIfExists('sessions');
    }
};
