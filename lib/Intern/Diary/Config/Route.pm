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

        connect '/diaries/{diary_id}/entries/add' => {
            engine => 'Entry',
            action => 'add_get',
        } => { method => 'GET' };
        connect '/entries' => {
            engine => 'Entry',
            action => 'add_post',
        } => { method => 'POST' };

        connect '/entries/{entry_id}/delete' => {
            engine => 'Entry',
            action => 'delete_get',
        } => { method => 'GET' };
        connect '/entries/delete' => {
            engine => 'Entry',
            action => 'delete_post',
        } => { method => 'POST' };
    };
}

1;
