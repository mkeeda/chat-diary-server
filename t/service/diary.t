package t::Intern::Diary::Service::Diary;

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

sub _require : Test(startup => 1) {
    my ($self) = @_;
    require_ok 'Intern::Diary::Service::Diary';
}

sub find_diary_by_id : Tests {
    my ($self) = @_;

    #userをランダムなnameで生成
    my $c = Intern::Diary::Context->new;
    my $name = random_regex('test_diary_\w{15}');
    $c->dbh->query(q[
        INSERT INTO user (name)
        VALUES (?)
        ], [ $name ]);

    my $user = Intern::Diary::Service::User->find_user_by_name($c->dbh, {
            name => $name,
        });

    subtest 'userないとき失敗する' => sub {
        my $diary_id = 1;
        dies_ok {
            my $diary = Intern::Diary::Service::Diary->find_diary_by_name($c->dbh, {
                    diary_id => $diary_id
                });
        };
    };

    subtest 'diary_idないとき失敗する' => sub {
        dies_ok {
            my $diary = Intern::Diary::Service::Diary->find_diary_by_name($c->dbh, {
                    user => $user
                });
        };
    };

    subtest 'diary見つかる' => sub {
        #titleをランダム生成
        my $title = random_regex('test_diary_\w{15}');
        #先にDiaryを登録
        my $dbh = $c->dbh;
        $dbh->query(q[
            INSERT INTO diary (user_id, title)
            VALUES (?)
            ], [ $user->user_id, $title ]);
        my $diary_id = $dbh->last_insert_id;

        my $diary = Intern::Diary::Service::Diary->find_diary_by_id($c->dbh, {
                user => $user,
                diary_id => $diary_id
            });

        ok $diary, 'diaryが引ける';
        isa_ok $diary, 'Intern::Diary::Model::Diary', 'blessされている';
        is $diary->user_id, $user->user_id, 'user_idが一致する';
        is $diary->title, $title, 'titleが一致する';
    };
}


sub create : Tests {
    my ($self) = @_;

    my $c = Intern::Diary::Context->new;

    #titleをランダム生成
    my $title = random_regex('test_diary_\w{15}');

    #userをランダムなnameで生成
    my $name = random_regex('test_diary_\w{15}');
    $c->dbh->query(q[
        INSERT INTO user (name)
        VALUES (?)
        ], [ $name ]);

    my $user = Intern::Diary::Service::User->find_user_by_name($c->dbh, {
            name => $name,
        });

    subtest 'user_idわたさないとき失敗する' => sub {
        dies_ok {
            Intern::Diary::Service::Diary->create($c->dbh, {
                    title => $title
                });
        };
    };

    subtest 'titleわたさないとき失敗する' => sub {
        dies_ok {
            Intern::Diary::Service::Diary->create($c->dbh, {
                    user_id => $user->user_id,
                });
        };
    };

    subtest 'diaryを作成できる' => sub {

        my $dbh = $c->dbh;
        Intern::Diary::Service::Diary->create($dbh, {
                user_id => $user->user_id,
                title => $title,
            });

        my $diary_id = $dbh->last_insert_id;
        my $diary = $c->dbh->select_row(q[
            SELECT * FROM diary
              WHERE
                diary_id = ?
        ],  $diary_id);

        ok $diary, 'ユーザーできている';
        is $diary->{user_id}, $user->user_id, 'user_idが一致する';
        is $diary->{title}, $title, 'titleが一致する';
    };
}

sub add_diary : Tests {
    my ($self) = @_;
    my $c = Intern::Diary::Context->new;

    #titleをランダム生成
    my $title = random_regex('test_diary_\w{15}');

    #userをランダムなnameで生成
    my $name = random_regex('test_diary_\w{15}');
    $c->dbh->query(q[
        INSERT INTO user (name)
        VALUES (?)
        ], [ $name ]);

    my $user = Intern::Diary::Service::User->find_user_by_name($c->dbh, {
            name => $name,
        });

    subtest 'userわたさないとき失敗する' => sub {
        dies_ok {
            Intern::Diary::Service::Diary->create($c->dbh, {
                    diary_title => $title
                });
        };
    };

    subtest 'titleわたさないとき失敗する' => sub {
        dies_ok {
            Intern::Diary::Service::Diary->create($c->dbh, {
                    user => $user,
                });
        };
    };

    subtest 'diaryを追加できる' => sub {

        my $dbh = $c->dbh;
        Intern::Diary::Service::Diary->add_diary($dbh, {
                user=> $user,
                diary_title => $title,
            });
        my $diary_id = $dbh->last_insert_id;

        my $diary = $c->dbh->select_row(q[
            SELECT * FROM diary
              WHERE
                diary_id = ?
        ],  $diary_id);

        ok $diary, 'diaryができている';
        is $diary->{user_id}, $user->user_id, 'user_idが一致する';
        is $diary->{title}, $title, 'titleが一致する';
    };
}

__PACKAGE__->runtests;

1;
