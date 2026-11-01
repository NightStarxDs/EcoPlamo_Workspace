<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Setoran extends Model
{
    use HasFactory;

    protected $table = 'setoran';
    protected $primaryKey = 'id_setoran';

    protected $fillable = [
        'id_warga',
        'id_pengurus',
        'tanggal',
        'total_berat_kg',
        'total_nilai_rp',
    ];

    protected $casts = [
        'tanggal' => 'date',
        'total_berat_kg' => 'float',
        'total_nilai_rp' => 'float',
    ];

    public function warga()
    {
        return $this->belongsTo(Warga::class, 'id_warga', 'id_pengguna');
    }

    public function pengurus()
    {
        return $this->belongsTo(Pengurus::class, 'id_pengurus', 'id_pengguna');
    }

    public function details()
    {
        return $this->hasMany(DetailSetoran::class, 'id_setoran', 'id_setoran');
    }
}
