<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Dlh extends Model
{
    use HasFactory;

    protected $table = 'dlh';
    protected $primaryKey = 'id_dlh';

    protected $fillable = [
        'id_pengguna',
        'nip_pegawai',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'id_pengguna', 'id_pengguna');
    }
}