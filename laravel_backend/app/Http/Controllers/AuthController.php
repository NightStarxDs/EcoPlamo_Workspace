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

            Warga::create([
                'id_pengguna' => $user->id_pengguna,
                'alamat' => $request->alamat,
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
     * Registrasi akun warga dari aplikasi Flutter (FR-01).
     * POST /api/register
     */
    public function register(Request $request)
    {
        // Normalisasi nomor WhatsApp: hilangkan karakter non-angka
        $cleanWhatsapp = preg_replace('/[^0-9]/', '', (string) $request->no_whatsapp);
        $request->merge(['clean_whatsapp' => $cleanWhatsapp]);

        $validator = Validator::make($request->all(), [
            'nama_lengkap'   => 'required|string|max:255',
            'no_whatsapp'    => 'required|string',
            'clean_whatsapp' => ['required', 'regex:/^08[0-9]{8,11}$/', 'unique:users,no_whatsapp'],
            'alamat'         => 'required|string|max:500',
            'password'       => 'required|string|min:8',
        ], [
            'nama_lengkap.required'   => 'Nama lengkap wajib diisi.',
            'no_whatsapp.required'    => 'Nomor WhatsApp wajib diisi.',
            'clean_whatsapp.regex'    => 'Nomor WhatsApp harus diawali 08 dan berisi 10-13 digit.',
            'clean_whatsapp.unique'   => 'Nomor WhatsApp sudah terdaftar.',
            'alamat.required'         => 'Blok & nomor rumah wajib diisi.',
            'password.required'       => 'Kata sandi wajib diisi.',
            'password.min'            => 'Kata sandi minimal 8 karakter.',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => $validator->errors()->first(),
                'errors'  => $validator->errors(),
            ], 422);
        }

        try {
            // Simpan ke tabel users dan warga dalam satu transaksi.
            // Jika salah satu gagal, keduanya dibatalkan.
            $user = DB::transaction(function () use ($request, $cleanWhatsapp) {
                // 1. Buat record di superclass 'users'
                // Catatan: password di-hash otomatis oleh cast 'hashed' di User model
                $user = User::create([
                    'nama_lengkap' => $request->nama_lengkap,
                    'no_whatsapp'  => $cleanWhatsapp,
                    'password'     => $request->password, // auto-hashed via model cast
                    'role'         => 'warga', // registrasi mandiri selalu sebagai warga
                ]);

                // 2. Buat record di subclass 'warga' (Generalisasi ERD)
                Warga::create([
                    'id_pengguna' => $user->id_pengguna,
                    'alamat'      => $request->alamat,
                    'total_saldo' => 0,
                ]);

                return $user;
            });

            // Buat token otentikasi Sanctum langsung setelah registrasi
            $token = $user->createToken('eco_plamo_token')->plainTextToken;

            return response()->json([
                'success' => true,
                'message' => 'Pendaftaran akun berhasil! Selamat datang di Eco Plamo.',
                'data'    => [
                    'token' => $token,
                    'user'  => [
                        'id_pengguna'  => $user->id_pengguna,
                        'nama_lengkap' => $user->nama_lengkap,
                        'no_whatsapp'  => $user->no_whatsapp,
                        'role'         => $user->role,
                        'role_data'    => $user->getRoleData(),
                    ],
                ],
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mendaftar akun: ' . $e->getMessage(),
            ], 500);
        }
    }
    /**
     * Handle login request from Flutter app.
     */
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'no_whatsapp' => 'required|string',
            'password'    => 'required|string',
        ], [
            'no_whatsapp.required' => 'Nomor WhatsApp wajib diisi.',
            'password.required'    => 'Kata sandi wajib diisi.',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => $validator->errors()->first(),
                'errors'  => $validator->errors(),
            ], 422);
        }

        // Normalisasi nomor WhatsApp: hilangkan spasi atau strip jika ada
        $noWhatsapp = preg_replace('/[^0-9]/', '', $request->no_whatsapp);
        $user = User::with(['warga', 'pengurus', 'dlh'])
            ->where('no_whatsapp', $request->no_whatsapp)
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
            'data'    => [
                'token' => $token,
                'user'  => [
                    'id_pengguna'  => $user->id_pengguna,
                    'nama_lengkap' => $user->nama_lengkap,
                    'no_whatsapp'  => $user->no_whatsapp,
                    'role'         => $user->role,
                    'peran'        => $user->role,
                    'role_data'    => $user->getRoleData(),
                ],
            ],
        ], 200);
    }

    /**
     * Get authenticated user profile.
     */
    public function me(Request $request)
    {
        $user = $request->user()->loadMissing(['warga', 'pengurus', 'dlh']);

        return response()->json([
            'success' => true,
            'data' => [
                'id_pengguna' => $user->id_pengguna,
                'nama_lengkap' => $user->nama_lengkap,
                'no_whatsapp' => $user->no_whatsapp,
                'role' => $user->role,
                'peran' => $user->role,
                'role_data' => $user->getRoleData(),
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

    /**
     * Update user profile (nama_lengkap, alamat).
     */
    public function updateProfile(Request $request)
    {
        $user = $request->user();

        $validator = Validator::make($request->all(), [
            'nama_lengkap' => 'required|string|max:255',
            'alamat'       => 'nullable|string|max:500',
        ], [
            'nama_lengkap.required' => 'Nama lengkap wajib diisi.',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => $validator->errors()->first(),
            ], 422);
        }

        $user->nama_lengkap = $request->nama_lengkap;
        $user->save();

        if ($request->has('alamat') && $user->warga) {
            $user->warga->alamat = $request->alamat;
            $user->warga->save();
        }

        return response()->json([
            'success' => true,
            'message' => 'Profil berhasil diperbarui.',
            'data'    => [
                'user' => [
                    'id_pengguna'  => $user->id_pengguna,
                    'nama_lengkap' => $user->nama_lengkap,
                    'no_whatsapp'  => $user->no_whatsapp,
                    'role'         => $user->role,
                    'role_data'    => $user->getRoleData(),
                ],
            ],
        ]);
    }

    /**
     * Change user password.
     */
    public function changePassword(Request $request)
    {
        $user = $request->user();

        $validator = Validator::make($request->all(), [
            'current_password' => 'required|string',
            'new_password'     => 'required|string|min:8|different:current_password',
        ], [
            'current_password.required' => 'Kata sandi saat ini wajib diisi.',
            'new_password.required'     => 'Kata sandi baru wajib diisi.',
            'new_password.min'          => 'Kata sandi baru minimal 8 karakter.',
            'new_password.different'    => 'Kata sandi baru harus berbeda dari kata sandi saat ini.',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => $validator->errors()->first(),
            ], 422);
        }

        if (!Hash::check($request->current_password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Kata sandi saat ini tidak sesuai.',
            ], 400);
        }

        $user->password = $request->new_password;
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Kata sandi berhasil diperbarui.',
        ]);
    }
}
