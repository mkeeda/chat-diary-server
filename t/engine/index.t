package t::Intern::Diary::Engine::Index;

use strict;
use warnings;
use utf8;
use lib 't/lib';

use parent 'Test::Class';

use Test::Intern::Diary;
use Test::Intern::Diary::Mechanize;
use Test::Intern::Diary::Factory;

sub truncate_tables : Test(startup) {
    my $c = Intern::Diary::Context->new;
    my $tables = $c->dbh->table_info('', '', '%', 'TABLE')->fetchall_arrayref({});
    $c->dbh->do("TRUNCATE `$_`") for map { $_->{TABLE_NAME} } @$tables;
}

sub _get : Tests {
    my $diary = create_diary(
            user => create_user(name => 'testname')
        );

    my $mech = create_mech;
    $mech->get_ok('/', '/アクセスできるかのテスト');
    $mech->title_is('Intern::Diary', 'titleのテスト');
    $mech->content_contains($diary->title);
}

__PACKAGE__->runtests;

1;
