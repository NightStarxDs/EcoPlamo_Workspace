<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class MutasiSaldo extends Model
{
    use HasFactory;

    protected $table = 'mutasi_saldo';
    protected $primaryKey = 'id_mutasi';

    protected $fillable = [
        'id_warga',
        'id_setoran',
        'id_pencairan',
        'tipe',
        'nominal',
        'saldo_setelah_mutasi',
    ];

    protected $casts = [
        'nominal' => 'float',
        'saldo_setelah_mutasi' => 'float',
    ];

    public function warga()
    {
        return $this->belongsTo(Warga::class, 'id_warga', 'id_pengguna');
    }

    public function setoran()
    {
        return $this->belongsTo(Setoran::class, 'id_setoran', 'id_setoran');
    }

    public function pencairan()
    {
        return $this->belongsTo(Pencairan::class, 'id_pencairan', 'id_pencairan');
    }
}
