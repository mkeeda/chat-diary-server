package Intern::Diary::Service::Diary;

use strict;
use warnings;
use utf8;

use Carp qw(croak);

use Intern::Diary::Util;
use Intern::Diary::Model::Diary;

sub find_diary_by_id {
    my ($class, $db, $args) = @_;

    my $user = $args->{user} // croak 'user required';
    my $diary_id = $args->{diary_id} // croak 'entry required';

    my $row = $db->select_row(q[
        SELECT * FROM diary
          WHERE user_id  = ? AND diary_id = ?
    ], $user->user_id, $diary_id) or return;
    return Intern::Diary::Model::Diary->new($row);
}

sub find_diarys_by_user {
    my ($class, $db, $args) = @_;

    my $user = $args->{user} // croak 'user required';
    my $limit = $args->{limit} // croak 'limit required';
    

    my $diarys = $db->select_all(q[
        SELECT * FROM diary
          WHERE user_id  = ?
          LIMIT ?
    ], $user->user_id, $limit) or return;
    return [ map {
        Intern::Diary::Model::Diary->new($_);
    } @$diarys ];
}

sub create {
    my ($class, $db, $args) = @_;

    my $user_id = $args->{user_id} // croak 'user_id required';
    my $title = $args->{title} // croak 'title required';

    $db->query(q[
        INSERT INTO diary (user_id, title)
        VALUES (?)
        ], [ $user_id, $title]);
}

sub update {
    my ($class, $db, $args) = @_;

    my $diary_id = $args->{diary_id} // croak 'diary_id required';
    my $comment = $args->{comment} // '';

    $db->query(q[
        UPDATE diary
        SET
        comment = ?,
        updated = ?
        WHERE
        diary_id = ?
        ], $comment, Intern::Diary::Util->now, $diary_id);
}

sub add_diary {
    my ($class, $db, $args) = @_;

    my $user = $args->{user} // croak 'user required';
    my $diary_title = $args->{diary_title} // croak 'diary_title required';


    $class->create($db, +{
            user_id  => $user->user_id,
            title    => $diary_title
        });

} 

1;