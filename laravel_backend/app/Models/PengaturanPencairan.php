<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PengaturanPencairan extends Model
{
    use HasFactory;

    protected $table = 'pengaturan_pencairan';
    protected $primaryKey = 'id_pengaturan';
    public $timestamps = false;

    protected $fillable = [
        'id_pengurus',
        'target_minimal',
        'maksimal_per_warga',
        'kuota_warga',
        'maksimal_total_jadwal',
        'tanggal_mulai',
        'tanggal_selesai',
        'catatan_aturan',
        'created_at',
    ];

    protected $casts = [
        'target_minimal' => 'float',
        'maksimal_per_warga' => 'float',
        'kuota_warga' => 'integer',
        'maksimal_total_jadwal' => 'float',
        'tanggal_mulai' => 'date',
        'tanggal_selesai' => 'date',
        'created_at' => 'datetime',
    ];

    public function pengurus()
    {
        return $this->belongsTo(Pengurus::class, 'id_pengurus', 'id_pengguna');
    }

    public function pencairan()
    {
        return $this->hasMany(Pencairan::class, 'id_pengaturan', 'id_pengaturan');
    }
}
