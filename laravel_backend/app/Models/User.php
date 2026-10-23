<?php

namespace App\Models;

use Laravel\Sanctum\HasApiTokens; 
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use App\Models\Warga;
use App\Models\Pengurus;
use App\Models\Dlh;


class User extends Authenticatable
{
    // Wajib ada HasApiTokens untuk komunikasi dengan Flutter
    use HasApiTokens, HasFactory, Notifiable;

    // Menyesuaikan dengan custom ID di database
    protected $primaryKey = 'id_pengguna';

    // Daftar kolom yang diizinkan untuk diisi
    protected $fillable = [
        'nama_lengkap',
        'no_whatsapp',
        'password',
        'role',
    ];

    // Menyembunyikan data sensitif saat diambil melalui API
    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'whatsapp_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    /**
     * Memberi tahu sistem Auth Laravel untuk menggunakan no_whatsapp
     * alih-alih email standar saat proses otentikasi.
     */
    public function username()
    {
        return 'no_whatsapp';
    }

    public function warga()
    {
        return $this->hasOne(Warga::class, 'id_pengguna', 'id_pengguna');
    }

    public function pengurus()
    {
        return $this->hasOne(Pengurus::class, 'id_pengguna', 'id_pengguna');
    }

    public function dlh()
    {
        return $this->hasOne(Dlh::class, 'id_pengguna', 'id_pengguna');
    }

    /**
     * Mengambil model spesialisasi / profil role terkait.
     */
    public function getRoleProfileAttribute()
    {
        return match ($this->role) {
            'warga' => $this->warga,
            'pengurus' => $this->pengurus,
            'dlh' => $this->dlh,
            default => null,
        };
    }

    /**
     * Format data role-spesifik untuk response API.
     */
    public function getRoleData(): ?array
    {
        return match ($this->role) {
            'warga' => [
                'alamat' => $this->warga?->alamat,
                'blok_rumah' => $this->warga?->alamat,
                'total_saldo' => (float) ($this->warga?->total_saldo ?? 0),
            ],
            'pengurus' => [
                'jabatan' => $this->pengurus?->jabatan ?? 'Pengurus RT/RW',
            ],
            'dlh' => [
                'nip_pegawai' => $this->dlh?->nip_pegawai ?? '-',
            ],
            default => null,
        };
    }
}