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
        connect '/entries/{entry_id}/delete' => {
            engine => 'Entry',
            action => 'delete_post',
        } => { method => 'POST' };

        connect '/entries/{entry_id}/update' => {
            engine => 'Entry',
            action => 'update_get',
        } => { method => 'GET' };
        connect '/entries/{entry_id}/update' => {
            engine => 'Entry',
            action => 'update_post',
        } => { method => 'POST' };

        #API
        connect '/api/diaries' => {
            engine => 'API',
            action => 'diaries',
        }=> { method => 'GET' };

        connect '/api/diaries/{diary_id}' => {
            engine => 'API',
            action => 'diary',
        }=> { method => 'GET' };

        connect '/api/entries' => {
            engine => 'API',
            action => 'add_entry',
        }=> { method => 'POST' };

        connect '/api/chat' => {
            engine => 'API',
            action => 'chat',
        }=> { method => 'POST' };

    };
}

1;
