<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class VerifikasiLaporan extends Model
{
    use HasFactory;

    protected $table = 'verifikasi_laporan';
    protected $primaryKey = 'id_verifikasi';

    protected $fillable = [
        'id_dlh',
        'nip_pegawai',
        'bulan',
        'tahun',
        'status',
        'tanggal_verifikasi',
        'total_volume_kg',
        'total_insentif_rp',
        'catatan',
    ];

    protected $casts = [
        'bulan' => 'integer',
        'tahun' => 'integer',
        'tanggal_verifikasi' => 'datetime',
        'total_volume_kg' => 'float',
        'total_insentif_rp' => 'float',
    ];

    public function dlh()
    {
        return $this->belongsTo(Dlh::class, 'id_dlh', 'id_pengguna');
    }

}
