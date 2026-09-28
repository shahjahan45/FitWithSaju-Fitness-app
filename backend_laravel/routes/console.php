<?php

use Illuminate\Support\Facades\Artisan;

Artisan::command('fitwithsaju:status', function () {
    $this->info('FitWithSaju backend is installed.');
})->purpose('Verify that the FitWithSaju Laravel application boots.');
