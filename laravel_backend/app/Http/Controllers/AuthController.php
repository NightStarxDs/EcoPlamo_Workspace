<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
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
