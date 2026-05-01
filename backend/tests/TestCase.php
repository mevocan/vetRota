<?php

namespace Tests;

use Illuminate\Foundation\Testing\TestCase as BaseTestCase;

abstract class TestCase extends BaseTestCase
{
    // Container DB_DATABASE=vetrota env'i Dotenv-immutable nedeniyle
    // .env.testing tarafindan ezilemiyor; testler ana DB'ye gidiyor ve
    // RefreshDatabase ana DB'yi wipe ediyor. Burada putenv ile zorla
    // override ediyoruz; Application::boot oncesi.
    protected function setUp(): void
    {
        putenv('DB_DATABASE=vetrota_testing');
        $_ENV['DB_DATABASE'] = 'vetrota_testing';
        $_SERVER['DB_DATABASE'] = 'vetrota_testing';

        parent::setUp();
    }
}
