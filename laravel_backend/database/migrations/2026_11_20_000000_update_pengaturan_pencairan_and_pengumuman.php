<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('pengaturan_pencairan', function (Blueprint $table) {
            if (!Schema::hasColumn('pengaturan_pencairan', 'maksimal_per_warga')) {
                $table->decimal('maksimal_per_warga', 15, 2)->nullable()->after('target_minimal');
            }
            if (!Schema::hasColumn('pengaturan_pencairan', 'kuota_warga')) {
                $table->unsignedInteger('kuota_warga')->nullable()->after('maksimal_per_warga');
            }
            if (!Schema::hasColumn('pengaturan_pencairan', 'maksimal_total_jadwal')) {
                $table->decimal('maksimal_total_jadwal', 15, 2)->nullable()->after('kuota_warga');
            }
            if (!Schema::hasColumn('pengaturan_pencairan', 'catatan_aturan')) {
                $table->text('catatan_aturan')->nullable()->after('tanggal_selesai');
            }
        });

        Schema::table('pengumuman', function (Blueprint $table) {
            if (!Schema::hasColumn('pengumuman', 'kategori')) {
                $table->string('kategori', 50)->default('Pengumuman')->after('judul');
            }
        });
    }

    public function down(): void
    {
        Schema::table('pengaturan_pencairan', function (Blueprint $table) {
            $table->dropColumn(['maksimal_per_warga', 'kuota_warga', 'maksimal_total_jadwal', 'catatan_aturan']);
        });

        Schema::table('pengumuman', function (Blueprint $table) {
            $table->dropColumn(['kategori']);
        });
    }
};

