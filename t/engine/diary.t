package t::Intern::Diary::Engine::Diary;

use strict;
use warnings;
use utf8;
use lib 't/lib';

use parent qw(Test::Class);

use Test::Intern::Diary;
use Test::Intern::Diary::Mechanize;
use Test::Intern::Diary::Factory;
use Test::Time;
use Test::More;

sub truncate_tables : Test(startup) {
    my $c = Intern::Diary::Context->new;
    my $tables = $c->dbh->table_info('', '', '%', 'TABLE')->fetchall_arrayref({});
    $c->dbh->do("TRUNCATE `$_`") for map { $_->{TABLE_NAME} } @$tables;
}

sub diary : Tests {
    my $diary = create_diary(
        user => create_user(name => 'testname')
    );
    my $entry1 = create_entry(
        diary_id => $diary->diary_id,
    );

    subtest 'エントリがひとつ' => sub {

        my $mech = create_mech;
        $mech->get_ok('/diaries/'. $diary->diary_id. '?page=1', '/アクセスできるかのテスト');
        $mech->content_contains(sprintf("%s - %s", $entry1->title, $entry1->body), '表示が正しいか');
    };

    subtest 'ページのテスト' => sub {
        my $entry2 = create_entry(
            diary_id => $diary->diary_id,
        );

        my $mech = create_mech;
        $mech->get_ok('/diaries/'. $diary->diary_id. '?page=1', '/アクセスできるかのテスト');
        $mech->content_contains(sprintf("%s - %s", $entry2->title, $entry2->body), '1ページ分の表示ができているか');
        $mech->content_lacks(sprintf("%s - %s", $entry1->title, $entry1->body), '1ページ分以上の表示はないか');

        $mech->get_ok('/diaries/'. $diary->diary_id. '?page=2', '/ページ切替テスト');
        $mech->content_contains(sprintf("%s - %s", $entry1->title, $entry1->body), '1ページ分の表示ができているか');
        $mech->content_lacks(sprintf("%s - %s", $entry2->title, $entry2->body), '1ページ分以上の表示はないか');
    };
}

__PACKAGE__->runtests;

1;
