<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class FitWithSajuAdminSeeder extends Seeder
{
    public function run(): void
    {
        $email = env('FITWITHSAJU_ADMIN_EMAIL');
        $password = env('FITWITHSAJU_ADMIN_PASSWORD');

        if (! $email || ! $password) {
            $this->command?->warn('Skipping admin creation. Set FITWITHSAJU_ADMIN_EMAIL and FITWITHSAJU_ADMIN_PASSWORD first.');
            return;
        }

        $user = User::firstOrNew(['email' => $email]);
        $user->forceFill([
            'name' => env('FITWITHSAJU_ADMIN_NAME', 'FitWithSaju Admin'),
            'password' => Hash::make($password),
            'is_admin' => true,
        ])->save();
    }
}
