package t::Intern::Diary::Engine::Entry;

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

use String::Random qw(random_regex);
use Intern::Diary::Service::Entry;

sub truncate_tables : Test(startup) {
    my $c = Intern::Diary::Context->new;
    my $tables = $c->dbh->table_info('', '', '%', 'TABLE')->fetchall_arrayref({});
    $c->dbh->do("TRUNCATE `$_`") for map { $_->{TABLE_NAME} } @$tables;
}

sub add : Tests {
    my $diary = create_diary(
        user => create_user(name => 'testname')
    );
    my $title = random_regex('\w{50}');
    my $body = random_regex('\w{50}');
    my $c = Intern::Diary::Context->new;

    subtest '新規作成' => sub {
        my $mech = create_mech;
        $mech->get_ok('/diaries/' . $diary->diary_id . '/entries/add');
        $mech->submit_form_ok({
            fields => {
                diary_id => $diary->diary_id,
                title => $title,
                body  => $body,
            },
        });

        #追加日時順に降順ソートされている
        my $entries = Intern::Diary::Service::Entry->find_entries_by_diary_id($c->dbh, {
                diary_id => $diary->diary_id,
                limit => 1,
        });
        ok $entries, '記事が生成されている';
        is $entries->[0]->title, $title, 'タイトル一致';
        is $entries->[0]->body, $body, '本文一致';

    };

}

__PACKAGE__->runtests;

1;
