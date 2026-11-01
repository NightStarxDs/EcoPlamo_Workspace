<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Pencairan extends Model
{
    use HasFactory;

    protected $table = 'pencairan';
    protected $primaryKey = 'id_pencairan';

    protected $fillable = [
        'id_warga',
        'id_pengaturan',
        'id_pengurus_validasi',
        'nominal_pencairan',
        'status',
        'tanggal_pengajuan',
        'tanggal_validasi',
    ];

    protected $casts = [
        'nominal_pencairan' => 'float',
        'tanggal_pengajuan' => 'datetime',
        'tanggal_validasi' => 'datetime',
    ];

    public function warga()
    {
        return $this->belongsTo(Warga::class, 'id_warga', 'id_pengguna');
    }

    public function pengaturan()
    {
        return $this->belongsTo(PengaturanPencairan::class, 'id_pengaturan', 'id_pengaturan');
    }

    public function pengurusValidasi()
    {
        return $this->belongsTo(Pengurus::class, 'id_pengurus_validasi', 'id_pengguna');
    }
}
