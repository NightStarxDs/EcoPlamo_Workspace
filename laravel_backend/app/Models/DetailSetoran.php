<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DetailSetoran extends Model
{
    use HasFactory;

    protected $table = 'detail_setoran';
    protected $primaryKey = 'id_detail';

    protected $fillable = [
        'id_setoran',
        'id_kategori',
        'berat_kg',
        'harga_saat_setor',
        'subtotal_rp',
    ];

    protected $casts = [
        'berat_kg' => 'float',
        'harga_saat_setor' => 'float',
        'subtotal_rp' => 'float',
    ];

    public function setoran()
    {
        return $this->belongsTo(Setoran::class, 'id_setoran', 'id_setoran');
    }

    public function kategori()
    {
        return $this->belongsTo(KategoriSampah::class, 'id_kategori', 'id_kategori');
    }
}
