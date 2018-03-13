<?php

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run()
    {
        $password = env('ADMIN_PASSWORD');
        if (is_null($password) || empty($password)) {
            throw new InvalidArgumentException("Please fill the ADMIN_PASSWORD env variable");
        }

        $email = env('ADMIN_EMAIL');
        if (is_null($email) || empty($email)) {
            throw new InvalidArgumentException("Please fill the ADMIN_EMAIL env variable");
        }

        User::firstOrcreate(['email' => $email,], [
            'name' => 'admin',
            'email' => $email,
            'password' => Hash::make($password),
            'api_token' => str_random(32),
            'admin' => true
        ]);
    }
}
