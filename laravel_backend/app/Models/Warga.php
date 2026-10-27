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
    public $timestamps = false;
    protected $fillable = [
        'id_pengguna',
        'tipe_hunian',
        'alamat',
        'nomor_hunian',
        'total_saldo',
    ];

    // Relasi balik (Inverse) ke tabel Users
    public function user()
    {
        return $this->belongsTo(User::class, 'id_pengguna', 'id_pengguna');
    }
}