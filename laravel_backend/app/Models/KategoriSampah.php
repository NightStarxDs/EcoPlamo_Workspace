<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class KategoriSampah extends Model
{
    protected $table = 'kategori_sampah';

    protected $primaryKey = 'id_kategori';

    protected $fillable = [
        'id_pengurus',
        'nama_kategori',
        'deskripsi',
        'harga_per_kg',
        'satuan',
        'jenis',
        'gambar',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'harga_per_kg' => 'decimal:2',
        ];
    }
}