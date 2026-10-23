<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Pengumuman extends Model
{
    use HasFactory;

    protected $table = 'pengumuman';
    protected $primaryKey = 'id_pengumuman';
    public $timestamps = false;

    protected $fillable = [
        'id_pengurus',
        'judul',
        'isi',
        'created_at',
    ];

    protected $casts = [
        'created_at' => 'datetime',
    ];

    public function pengurus()
    {
        return $this->belongsTo(Pengurus::class, 'id_pengurus', 'id_pengguna');
    }
}
