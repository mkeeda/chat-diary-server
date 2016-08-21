package Test::Intern::Diary::Factory;

use strict;
use warnings;
use utf8;

use String::Random qw(random_regex);
use Exporter::Lite;

our @EXPORT = qw(
    create_user
    create_entry
    create_diary
);

use Intern::Diary::Util;
use Intern::Diary::Context;
use Intern::Diary::Service::User;
use Intern::Diary::Service::Entry;
use Intern::Diary::Service::Diary;

sub create_user {
    my %args = @_;
    my $name = $args{name} // random_regex('test_user_\w{15}');

    my $c = Intern::Diary::Context->new;
    my $dbh = $c->dbh;
    $dbh->query(q[
        INSERT INTO user (name)
          VALUES (?)
    ], [ $name ]);

    return Intern::Diary::Service::User->find_user_by_name($dbh, {
        name => $name
    });
}

sub create_diary {
    my %args = @_;
    my $user  = $args{user}  // create_user();
    my $title = $args{title} // random_regex('\w{50}');

    #diaryを生成
    my $c = Intern::Diary::Context->new;
    my $dbh = $c->dbh;
    $dbh->query(q[
        INSERT INTO diary (user_id, title)
        VALUES (?)
        ], [ $user->user_id, $title ]);
    my $diary_id = $dbh->last_insert_id;

    return Intern::Diary::Service::Diary->find_diary_by_id($dbh, {
            user => $user,
            diary_id => $diary_id,
        });
}

sub create_entry {
    my %args = @_;
    my $title = $args{title} // random_regex('\w{50}');
    my $body = $args{body} // random_regex('\w{50}');
    my $created_date = $args{created_date} // Intern::Diary::Util::now;
    my $diary_id = $args{diary_id} // create_diary->diary_id;

    #entryを生成
    my $c = Intern::Diary::Context->new;
    my $dbh = $c->dbh;
    $dbh->query(q[
        INSERT INTO entry (diary_id, title, body, created_date)
        VALUES (?)
        ], [ $diary_id, $title, $body, $created_date ]);
    my $entry_id = $dbh->last_insert_id;

    return Intern::Diary::Service::Entry->find_entry_by_entry_id($dbh, {
            entry_id => $entry_id,
        });
}

1;
