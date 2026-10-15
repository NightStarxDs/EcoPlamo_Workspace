<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pengumuman', function (Blueprint $table) {
            $table->id('id_pengumuman');
            $table->unsignedBigInteger('id_pengurus');
            $table->string('judul', 200);
            $table->text('isi');
            $table->timestamp('created_at')->useCurrent();

            $table->foreign('id_pengurus')
                ->references('id_pengguna')->on('pengurus_rtrw')
                ->cascadeOnUpdate()->restrictOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pengumuman');
    }
};