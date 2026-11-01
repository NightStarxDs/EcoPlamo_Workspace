<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

echo "========================================\n";
echo "EcoPlamo Database Check\n";
echo "========================================\n\n";

$categories = \App\Models\KategoriSampah::all();
echo "Total Kategori Sampah: " . $categories->count() . "\n\n";

if ($categories->count() > 0) {
    echo "Kategori Sampah List:\n";
    echo "----------------------------------------\n";
    foreach ($categories as $cat) {
        echo sprintf(
            "ID: %d | %-20s | Rp %s/%s\n",
            $cat->id_kategori,
            $cat->nama_kategori,
            number_format($cat->harga_per_kg, 0, ',', '.'),
            $cat->satuan
        );
    }
} else {
    echo "⚠️  WARNING: No data found!\n";
    echo "Please run: php artisan db:seed\n";
}

echo "\n========================================\n";

$users = \App\Models\User::count();
$warga = \App\Models\Warga::count();
$pengurus = \App\Models\Pengurus::count();

echo "Total Users: $users\n";
echo "Total Warga: $warga\n";
echo "Total Pengurus: $pengurus\n";
echo "========================================\n";
