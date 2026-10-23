<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Warga extends Model
{
    use HasFactory;

    // Beri tahu Laravel nama tabel spesifiknya
    protected $table = 'warga';

    // Beri tahu Laravel nama Primary Key-nya
    protected $primaryKey = 'id_pengguna';
    public $incrementing = false;
<<<<<<< Updated upstream
    public $timestamps = false;
=======
    public $timestamps = true;
>>>>>>> Stashed changes
    protected $fillable = [
        'id_pengguna',
        'alamat',
        'total_saldo',
    ];

    // Relasi balik (Inverse) ke tabel Users
    public function user()
    {
        return $this->belongsTo(User::class, 'id_pengguna', 'id_pengguna');
    }

    public function setoran()
    {
        return $this->hasMany(Setoran::class, 'id_warga', 'id_pengguna');
    }

    public function pencairan()
    {
        return $this->hasMany(Pencairan::class, 'id_warga', 'id_pengguna');
    }
}