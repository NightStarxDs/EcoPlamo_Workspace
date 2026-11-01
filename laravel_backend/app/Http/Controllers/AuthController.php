<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Warga;     
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;       
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
        /**
     * Registrasi akun warga dari aplikasi Flutter (FR-01).
     * POST /api/register
     */
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nama_lengkap' => 'required|string|max:100',
            'no_whatsapp' => ['required', 'regex:/^08[0-9]{8,11}$/', 'unique:users,no_whatsapp'],
            'alamat' => 'required|string|max:255',
            'password' => 'required|string|min:8',
        ], [
            'nama_lengkap.required' => 'Nama lengkap wajib diisi.',
            'no_whatsapp.required' => 'Nomor WhatsApp wajib diisi.',
            'no_whatsapp.regex' => 'Nomor WhatsApp harus diawali 08 dan berisi 10-13 digit.',
            'no_whatsapp.unique' => 'Nomor WhatsApp sudah digunakan.',
            'alamat.required' => 'Blok & nomor rumah wajib diisi.',
            'password.required' => 'Kata sandi wajib diisi.',
            'password.min' => 'Kata sandi minimal 8 karakter.',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => $validator->errors()->first(),
                'errors' => $validator->errors(),
            ], 422);
        }

        // Simpan ke tabel users dan warga sekaligus.
        // Jika salah satu gagal, keduanya dibatalkan.
        $user = DB::transaction(function () use ($request) {
            $user = User::create([
                'nama_lengkap' => $request->nama_lengkap,
                'no_whatsapp' => $request->no_whatsapp,
                'password' => $request->password, // otomatis di-hash (casts di model User)
                'role' => 'warga', // registrasi mandiri selalu sebagai warga
            ]);

            $nomorTiket = 'REG-' . date('Ymd') . '-' . str_pad($user->id_pengguna, 4, '0', STR_PAD_LEFT);

            Warga::create([
                'id_pengguna' => $user->id_pengguna,
                'alamat' => $request->alamat,
                'status_verifikasi' => 'menunggu',
                'nomor_tiket' => $nomorTiket,
                'uang_pendaftaran' => 10000.00,
                'status_pembayaran' => 'belum_lunas',
            ]);

            return $user;
        });

        $warga = $user->warga;
        $nomorTiket = $warga->nomor_tiket ?? ('REG-' . date('Ymd') . '-' . str_pad($user->id_pengguna, 4, '0', STR_PAD_LEFT));

        return response()->json([
            'success' => true,
            'message' => 'Pendaftaran berhasil! Silakan bawa nomor tiket ke posko RT/RW untuk verifikasi domisili dan pembayaran kas posko.',
            'nomor_tiket' => $nomorTiket,
            'data' => [
                'id_pengguna' => $user->id_pengguna,
                'nama_lengkap' => $user->nama_lengkap,
                'no_whatsapp' => $user->no_whatsapp,
                'role' => $user->role,
                'nomor_tiket' => $nomorTiket,
                'status_verifikasi' => 'menunggu',
                'biaya_pendaftaran' => 10000,
            ],
        ], 201);
    }
    
    /**
     * Handle login request from Flutter app.
     */
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'no_whatsapp' => 'required|string',
            'password' => 'required|string',
        ], [
            'no_whatsapp.required' => 'Nomor WhatsApp atau username wajib diisi.',
            'password.required' => 'Kata sandi wajib diisi.',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => $validator->errors()->first(),
                'errors' => $validator->errors(),
            ], 422);
        }

        // Cari user berdasarkan no_whatsapp
        // Hilangkan spasi atau strip jika ada
        $noWhatsapp = preg_replace('/[^0-9]/', '', $request->no_whatsapp);
        $user = User::where('no_whatsapp', $request->no_whatsapp)
            ->orWhere('no_whatsapp', $noWhatsapp)
            ->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Nomor WhatsApp atau kata sandi tidak sesuai.',
            ], 401);
        }

        // Jika warga, periksa status verifikasi domisili & pembayaran posko
        if ($user->role === 'warga' && $user->warga) {
            if ($user->warga->status_verifikasi === 'menunggu') {
                return response()->json([
                    'success' => false,
                    'is_pending_verification' => true,
                    'nomor_tiket' => $user->warga->nomor_tiket,
                    'message' => 'Akun Anda sedang menunggu verifikasi oleh Pengurus RT/RW dan pembayaran kas posko. Nomor Tiket: ' . ($user->warga->nomor_tiket ?? '-'),
                ], 403);
            }

            if ($user->warga->status_verifikasi === 'ditolak') {
                return response()->json([
                    'success' => false,
                    'is_rejected' => true,
                    'message' => 'Pendaftaran akun Anda ditolak oleh Pengurus RT/RW: ' . ($user->warga->catatan_verifikasi ?? 'Data domisili tidak sesuai.'),
                ], 403);
            }
        }

        // Buat Sanctum token
        $token = $user->createToken('eco_plamo_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil! Selamat datang kembali, ' . $user->nama_lengkap,
            'data' => [
                'token' => $token,
                'user' => [
                    'id_pengguna' => $user->id_pengguna,
                    'nama_lengkap' => $user->nama_lengkap,
                    'no_whatsapp' => $user->no_whatsapp,
                    'role' => $user->role,
                ],
            ],
        ], 200);
    }

    /**
     * Get authenticated user profile.
     */
    public function me(Request $request)
    {
        $user = $request->user();

        return response()->json([
            'success' => true,
            'data' => [
                'id_pengguna' => $user->id_pengguna,
                'nama_lengkap' => $user->nama_lengkap,
                'no_whatsapp' => $user->no_whatsapp,
                'role' => $user->role,
            ],
        ]);
    }

    /**
     * Handle logout and revoke token.
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Berhasil keluar dari akun.',
        ]);
    }
}
