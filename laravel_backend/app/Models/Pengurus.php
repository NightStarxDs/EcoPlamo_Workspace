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
    public $timestamps = false;

    protected $fillable = [
        'id_pengguna',
        'jabatan',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'id_pengguna', 'id_pengguna');
    }
}