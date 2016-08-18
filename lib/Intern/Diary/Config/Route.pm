package Intern::Diary::Config::Route;

use strict;
use warnings;
use utf8;

use Intern::Diary::Config::Route::Declare;

sub make_router {
    return router {
        connect '/' => {
            engine => 'Index',
            action => 'default',
        };

        connect '/diaries/{diary_id}' => {
            engine => 'Diary',
            action => 'diary',
        };
    };
}

1;
