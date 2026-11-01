<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Pengurus extends Model
{
    use HasFactory;

    protected $table = 'pengurus_rtrw';
    protected $primaryKey = 'id_pengguna';
    public $incrementing = false;
    public $timestamps = true;

    protected $fillable = [
        'id_pengguna',
        'jabatan',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'id_pengguna', 'id_pengguna');
    }

    public function setoranDicatat()
    {
        return $this->hasMany(Setoran::class, 'id_pengurus', 'id_pengguna');
    }

    public function kategoriSampah()
    {
        return $this->hasMany(KategoriSampah::class, 'id_pengurus', 'id_pengguna');
    }

    public function pengaturanPencairan()
    {
        return $this->hasMany(PengaturanPencairan::class, 'id_pengurus', 'id_pengguna');
    }

    public function pengumuman()
    {
        return $this->hasMany(Pengumuman::class, 'id_pengurus', 'id_pengguna');
    }
}