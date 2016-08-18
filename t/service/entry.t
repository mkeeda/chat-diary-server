package t::Intern::Diary::Service::Entry;

use strict;
use warnings;
use utf8;
use lib 't/lib';

use parent qw(Test::Class);

use Test::Intern::Diary;
use Test::Intern::Diary::Factory;

use Test::More;
use Test::Deep;
# use Test::Time time => 1;
use Test::Exception;

use String::Random qw(random_regex);

use Intern::Diary::Context;

use Intern::Diary::Service::User;
use Intern::Diary::Service::Diary;
use Intern::Diary::Model::Entry;
use Intern::Diary::Util;
use Data::Dumper;

sub _require : Test(startup => 1) {
    my ($self) = @_;
    require_ok 'Intern::Diary::Service::Entry';
}

sub find_entries_by_diary_id : Tests {
    my ($self) = @_;

    my $limit = 10;
    my $c = Intern::Diary::Context->new;
    my $diary= create_diary;

    subtest 'diary_idないとき失敗する' => sub {
        dies_ok {
            my $entry = Intern::Diary::Service::Entry->find_entries_by_diary_id($c->dbh, {
                    limit => $limit
                });
        };
    };

    subtest 'limitないとき失敗する' => sub {
        dies_ok {
            my $entry = Intern::Diary::Service::Entry->find_entries_by_diary_id($c->dbh, {
                    diary_id => $diary->diary_id
                });
        };
    };

    subtest 'entries見つかる' => sub {
        #先にEntryを登録
        my $entry_ids = [];
        my $entry_titles = [];
        my $bodies = [];
        my $created_dates = [];
        for (0..1) {
            my $entry_title = random_regex('test_diary_\w{15}');
            my $body = random_regex('test_diary_\w{15}');
            my $created_date = Intern::Diary::Util->now;

            my $dbh = $c->dbh;
            $dbh->query(q[
                INSERT INTO entry (title, body, created_date, diary_id)
                VALUES (?)
                ], [ $entry_title, $body,  $created_date, $diary->diary_id]);

            my $entry_id = $dbh->last_insert_id;
          
            push @$entry_ids, $entry_id;
            push @$entry_titles, $entry_title;
            push @$bodies, $body;
            push @$created_dates, $created_date;

            sleep 1;
        }


        my $got_entries = Intern::Diary::Service::Entry->find_entries_by_diary_id($c->dbh, {
                diary_id => $diary->diary_id,
                limit => $limit,
            });
        
        is scalar(@$got_entries), 2;

        ##TODO entriesの内容をテストする
        my $expected_entries = [];
        for my $index (0..1) {
            push @$expected_entries, 
            Intern::Diary::Model::Entry->new(
                entry_id => $entry_ids->[$index],
                title => $entry_titles->[$index],
                body => $bodies->[$index],
                created_date => DateTime::Format::MySQL->format_datetime($created_dates->[$index]),
                diary_id => $diary->diary_id,
            );
        }
        cmp_deeply $got_entries, $expected_entries, '内容が一致する';

    };
}

sub create : Tests {
    my ($self) = @_;

    my $c = Intern::Diary::Context->new;

    #titleをランダム生成
    my $title = random_regex('test_diary_\w{15}');
    #bodyをランダム生成
    my $body = random_regex('test_diary_\w{15}');

    #diaryを生成
    my $diary = create_diary;
    my $diary_id = $diary->diary_id;
    subtest 'diary_idわたさないとき失敗する' => sub {
        dies_ok {
            Intern::Diary::Service::Entry->create($c->dbh, {
                    title => $title,
                    body => $body
                });
        };
    };

    subtest 'titleわたさないとき失敗する' => sub {
        dies_ok {
            Intern::Diary::Service::Entry->create($c->dbh, {
                    diary_id => $diary_id,
                    body => $body
                });
        };
    };

    subtest 'bodyわたさないとき失敗する' => sub {
        dies_ok {
            Intern::Diary::Service::Entry->create($c->dbh, {
                    diary_id => $diary_id,
                    title => $title,
                });
        };
    };

    subtest 'entryを作成できる' => sub {

        my $dbh = $c->dbh;
        Intern::Diary::Service::Entry->create($dbh, {
                diary_id => $diary_id,
                title => $title,
                body => $body
            });

        my $entry_id = $dbh->last_insert_id;
        my $entry = $c->dbh->select_row(q[
            SELECT * FROM entry
              WHERE
                entry_id = ?
        ],  $entry_id);

        ok $entry, 'エントリできている';
        is $entry->{title}, $title, 'titleが一致する';
        is $entry->{body}, $body, 'bodyが一致する';
    };
}

sub update : Tests {
    my ($self) = @_;

    my $c = Intern::Diary::Context->new;


    #diaryを生成
    my $diary = create_diary;
    my $diary_id = $diary->diary_id;

    #titleをランダム生成
    my $before_title = random_regex('test_diary_\w{15}');
    #bodyをランダム生成
    my $before_body = random_regex('test_diary_\w{15}');

    #エントリ生成
    my $entry = create_entry(
        title => $before_title,
        body => $before_body,
    );
    my $entry_id = $entry->entry_id;

    #titleをランダム生成
    my $after_title = random_regex('test_diary_\w{15}');
    #bodyをランダム生成
    my $after_body = random_regex('test_diary_\w{15}');

    subtest 'entry_idわたさないとき失敗する' => sub {
        dies_ok {
            Intern::Diary::Service::Entry->update($c->dbh, {
                    title => $after_title,
                    body => $after_body
                });
        };
    };

    subtest 'titleわたさないとき失敗する' => sub {
        dies_ok {
            Intern::Diary::Service::Entry->update($c->dbh, {
                    entry_id => $entry_id,
                    body => $after_body
                });
        };
    };

    subtest 'bodyわたさないとき失敗する' => sub {
        dies_ok {
            Intern::Diary::Service::Entry->update($c->dbh, {
                    entry_id => $entry_id,
                    title => $after_title,
                });
        };
    };

    subtest 'entryを更新できる' => sub {

        my $dbh = $c->dbh;
        Intern::Diary::Service::Entry->update($c->dbh, {
                entry_id => $entry_id,
                title => $after_title,
                body => $after_body
            });

        my $entry = $c->dbh->select_row(q[
            SELECT * FROM entry
              WHERE
                entry_id = ?
        ],  $entry_id);

        ok $entry, 'エントリできている';
        is $entry->{title}, $after_title, '更新後のtitleが一致する';
        is $entry->{body}, $after_body, '更新後のbodyが一致する';
    };
}

sub add_entry : Tests {
    my ($self) = @_;

    my $c = Intern::Diary::Context->new;

    #titleをランダム生成
    my $title = random_regex('test_diary_\w{15}');
    #bodyをランダム生成
    my $body = random_regex('test_diary_\w{15}');

    my $diary = create_diary;
    my $diary_id = $diary->diary_id;
    subtest 'diaryわたさないとき失敗する' => sub {
        dies_ok {
            Intern::Diary::Service::Entry->add_entry($c->dbh, {
                    title => $title,
                    body => $body
                });
        };
    };

    subtest 'titleわたさないとき失敗する' => sub {
        dies_ok {
            Intern::Diary::Service::Entry->add_entry($c->dbh, {
                    diary => $diary,
                    body => $body
                });
        };
    };

    subtest 'bodyわたさないとき失敗する' => sub {
        dies_ok {
            Intern::Diary::Service::Entry->add_entry($c->dbh, {
                    diary => $diary,
                    title => $title,
                });
        };
    };

    subtest 'entryを作成できる' => sub {

        my $dbh = $c->dbh;
        Intern::Diary::Service::Entry->add_entry($dbh, {
                diary => $diary,
                entry_title => $title,
                body => $body
            });

        my $entry_id = $dbh->last_insert_id;
        my $entry = $c->dbh->select_row(q[
            SELECT * FROM entry
              WHERE
                entry_id = ?
        ],  $entry_id);

        ok $entry, 'エントリできている';
        is $entry->{title}, $title, 'titleが一致する';
        is $entry->{body}, $body, 'bodyが一致する';
        is $entry->{diary_id}, $diary_id, 'diary_idが一致する';
    };
}

__PACKAGE__->runtests;

1;
