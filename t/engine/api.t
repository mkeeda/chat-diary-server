package t::Intern::Diary::Engine::API;

use strict;
use warnings;
use utf8;
use lib 't/lib';

use parent qw(Test::Class);

use JSON::XS qw(decode_json);
use String::Random qw(random_regex);

use Test::MockTime::HiRes qw(mock_time);
use Test::More;

use Test::Intern::Diary;
use Test::Intern::Diary::Mechanize;
use Test::Intern::Diary::Factory;

use Intern::Diary::Context;

sub truncate_tables : Test(startup) {
    my $c = Intern::Diary::Context->new;
    my $tables = $c->dbh->table_info('', '', '%', 'TABLE')->fetchall_arrayref({});
    $c->dbh->do("TRUNCATE `$_`") for map { $_->{TABLE_NAME} } @$tables;
}

sub diaries : Tests {
    my $user = create_user(name => 'testname');
    my $diaries = [];
    mock_time {
        for (0..4) {
            sleep 3;
            my $diary = create_diary(
                user => $user
            );
            push @$diaries, $diary;
        }
    } time;

    subtest 'アクセスできる' => sub {
        my $mech = create_mech;
        $mech->get('/api/diaries');
        is $mech->res->code, 200, '200が返る';

        my $res = decode_json $mech->res->content;
        ok $res, 'JSONが返っている';
    };

    subtest '正しいJSONの内容が返ること' => sub {
        my $mech = create_mech;
        $mech->get('/api/diaries');

        my $res = decode_json $mech->res->content;
        ok $res;
        is_deeply $res, {
            diaries => [ map { $_->json_hash } @$diaries ],
        }, '内容が正しい';
    };
}

sub diary : Tests {
    truncate_tables;
    my $user = create_user(name => 'testname');
    my $diary = create_diary(
        user => $user
    );
    my $entries = [];
    mock_time {
        for (0..30) {
            sleep 3;
            my $entry = create_entry(
                diary_id => $diary->diary_id
            );
            push @$entries, $entry;
        }
    } time;

    my $uri = '/api/diaries/' . $diary->diary_id;
    print $uri . "\n";

    subtest 'アクセスできる' => sub {
        my $mech = create_mech;
        $mech->get($uri . '?page=1');
        is $mech->res->code, 200, '200が返る';

        my $res = decode_json $mech->res->content;
        ok $res, 'JSONが返っている';
    };

    subtest '正しいJSONの内容が返ること' => sub {
        my $mech = create_mech;
        subtest '1ページ目' => sub {
            $mech->get($uri . '?page=1');

            my $res = decode_json $mech->res->content;
            ok $res;
            is_deeply $res, {
                entries => [ reverse map { $_->json_hash } @$entries[21..30] ],
                per_page => 10,
                has_next => 1,
            }, '内容が正しい';
        };
        subtest '2ページ目' => sub {
            $mech->get($uri . '?page=2');

            my $res = decode_json $mech->res->content;
            ok $res;
            is_deeply $res, {
                entries => [ reverse map { $_->json_hash } @$entries[11..20] ],
                per_page => 10,
                has_next => 1,
            }, '内容が正しい';
        };
        subtest '3ページ目' => sub {
            $mech->get($uri . '?page=3');

            my $res = decode_json $mech->res->content;
            ok $res;
            is_deeply $res, {
                entries => [ reverse map { $_->json_hash } @$entries[1..10] ],
                per_page => 10,
                has_next => 1,
            }, '内容が正しい';
        };
        subtest '4ページ目' => sub {
            $mech->get($uri . '?page=4');

            my $res = decode_json $mech->res->content;
            ok $res;
            is_deeply $res, {
                entries => [ reverse map { $_->json_hash } @$entries[0] ],
                per_page => 10,
                has_next => 0,
            }, '内容が正しい';
        };
    };
    
}

__PACKAGE__->runtests;

1;
