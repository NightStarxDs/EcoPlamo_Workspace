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
            'tipe_hunian' => 'required|in:kos_kontrakan,rumah_biasa',
            'alamat' => 'required_if:tipe_hunian,rumah_biasa|nullable|string|max:255',
            'nomor_hunian' => 'required_if:tipe_hunian,kos_kontrakan|nullable|string|max:100',
            'password' => 'required|string|min:8',
        ], [
            'nama_lengkap.required' => 'Nama lengkap wajib diisi.',
            'no_whatsapp.required' => 'Nomor WhatsApp wajib diisi.',
            'no_whatsapp.regex' => 'Nomor WhatsApp harus diawali 08 dan berisi 10-13 digit.',
            'no_whatsapp.unique' => 'Nomor WhatsApp sudah digunakan.',
            'tipe_hunian.required' => 'Tipe tempat tinggal wajib dipilih.',
            'tipe_hunian.in' => 'Tipe tempat tinggal tidak valid.',
            'alamat.required_if' => 'Alamat rumah wajib diisi.',
            'nomor_hunian.required_if' => 'Nomor pintu atau nomor kontrakan wajib diisi.',
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

            Warga::create([
                'id_pengguna' => $user->id_pengguna,
                'tipe_hunian' => $request->tipe_hunian,
                'alamat' => $request->alamat,
                'nomor_hunian' => $request->nomor_hunian,
            ]);

            return $user;
        });

        return response()->json([
            'success' => true,
            'message' => 'Pendaftaran berhasil. Silakan masuk.',
            'data' => [
                'id_pengguna' => $user->id_pengguna,
                'nama_lengkap' => $user->nama_lengkap,
                'no_whatsapp' => $user->no_whatsapp,
                'role' => $user->role,
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
