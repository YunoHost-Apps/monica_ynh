<?php

use App\Kid;
use App\Event;
use App\Contact;
use App\Reminder;
use Carbon\Carbon;
use Faker\Factory as Faker;
use App\Helpers\RandomHelper;
use Illuminate\Database\Seeder;
use Illuminate\Database\Eloquent\Model;

class CreateUser extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        // populate account table
        $accountID = DB::table('accounts')->insertGetId([
            'api_key' => str_random(30),
        ]);

        // populate user table
        $userId = DB::table('users')->insertGetId([
            'account_id' => $accountID,
            'first_name' => 'yuno_firstname',
            'last_name' => 'yuno_lastname',
            'email' => 'yuno_email',
            'password' => bcrypt('admin'),
            'timezone' => 'America/New_York',
            'remember_token' => str_random(10),
        ]);

        $faker = Faker::create();

    }
}
