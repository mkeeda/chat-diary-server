package t::Intern::Diary::Service::Entry;

use strict;
use warnings;
use utf8;
use lib 't/lib';

use parent qw(Test::Class);

use Test::Intern::Diary;

use Test::More;
# use Test::Deep;
use Test::Exception;

use String::Random qw(random_regex);

use Intern::Diary::Context;

use Intern::Diary::Service::User;
use Intern::Diary::Service::Diary;
use Intern::Diary::Util;

sub _require : Test(startup => 1) {
    my ($self) = @_;
    require_ok 'Intern::Diary::Service::Entry';
}

sub find_entries_by_diary_id : Tests {
    my ($self) = @_;

    my $limit = 10;
    my $title = random_regex('test_diary_\w{15}');
    my $c = Intern::Diary::Context->new;

    #userをランダムなnameで生成
    my $name = random_regex('test_entry_\w{15}');
    $c->dbh->query(q[
        INSERT INTO user (name)
        VALUES (?)
        ], [ $name ]);

    my $user = Intern::Diary::Service::User->find_user_by_name($c->dbh, {
            name => $name,
        });

    #diaryを生成
    my $dbh = $c->dbh;
    $dbh->query(q[
        INSERT INTO diary (user_id, title)
        VALUES (?)
        ], [ $user->user_id, $title ]);
    my $diary_id = $dbh->last_insert_id;

    my $diary = Intern::Diary::Service::Diary->find_diary_by_id($c->dbh, {
            user => $user,
            diary_id => $diary_id,
        });

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
                    diary_id => $diary_id
                });
        };
    };

    subtest 'entries見つかる' => sub {
        #先にEntryを登録
        my $entry_titles = [];
        my $bodies = [];
        for my $index (0..3) {
            my $entry_title = random_regex('test_diary_\w{15}');
            my $body = random_regex('test_diary_\w{15}');

            push @$entry_titles, $entry_title;
            push @$bodies, $body;

            my $dbh = $c->dbh;
            $dbh->query(q[
                INSERT INTO entry (title, body, created_date, diary_id)
                VALUES (?)
                ], [ $title, $body,  Intern::Diary::Util->now, $diary_id]);
        }

        my $entries = Intern::Diary::Service::Entry->find_entries_by_diary_id($c->dbh, {
                diary_id => $diary_id,
                limit => $limit,
            });
        
        is scalar(@$entries), 4;
        ##TODO entriesの内容をテストする
    };
}


sub create : Tests {
    my ($self) = @_;

    my $c = Intern::Diary::Context->new;

    #titleをランダム生成
    my $title = random_regex('test_diary_\w{15}');
    #bodyをランダム生成
    my $body = random_regex('test_diary_\w{15}');

    #userをランダムなnameで生成
    my $name = random_regex('test_diary_\w{15}');
    $c->dbh->query(q[
        INSERT INTO user (name)
        VALUES (?)
        ], [ $name ]);

    my $user = Intern::Diary::Service::User->find_user_by_name($c->dbh, {
            name => $name,
        });

    #diaryを生成
    my $dbh = $c->dbh;
    $dbh->query(q[
        INSERT INTO diary (user_id, title)
        VALUES (?)
        ], [ $user->user_id, $title ]);
    my $diary_id = $dbh->last_insert_id;

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
#
# sub add_entry : Tests {
#     my ($self) = @_;
#     my $c = Intern::Diary::Context->new;
#
#     #titleをランダム生成
#     my $title = random_regex('test_entry_\w{15}');
#
#     #userをランダムなnameで生成
#     my $name = random_regex('test_entry_\w{15}');
#     $c->dbh->query(q[
#         INSERT INTO user (name)
#         VALUES (?)
#         ], [ $name ]);
#
#     my $user = Intern::Diary::Service::User->find_user_by_name($c->dbh, {
#             name => $name,
#         });
#
#     subtest 'userわたさないとき失敗する' => sub {
#         dies_ok {
#             Intern::Diary::Service::Entry->create($c->dbh, {
#                     entry_title => $title
#                 });
#         };
#     };
#
#     subtest 'titleわたさないとき失敗する' => sub {
#         dies_ok {
#             Intern::Diary::Service::Entry->create($c->dbh, {
#                     user => $user,
#                 });
#         };
#     };
#
#     subtest 'entryを追加できる' => sub {
#         #先にEntryを登録
#         my $dbh = $c->dbh;
#         $dbh->query(q[
#             INSERT INTO entry (title, body, diary_id,)
#             VALUES (?)
#             ], [ $user->user_id, $title ]);
#         my $entry_id = $dbh->last_insert_id;
#
#         Intern::Diary::Service::Entry->add_entry($c->dbh, {
#                 user=> $user,
#                 entry_title => $title,
#             });
#
#         my $entry = $c->dbh->select_row(q[
#             SELECT * FROM entry
#               WHERE
#                 entry_id = ?
#         ],  $entry_id);
#
#         ok $entry, 'entryができている';
#         is $entry->{user_id}, $user->user_id, 'user_idが一致する';
#         is $entry->{title}, $title, 'titleが一致する';
#     };
# }

__PACKAGE__->runtests;

1;
