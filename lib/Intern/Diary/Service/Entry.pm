package Intern::Diary::Service::Entry;

use strict;
use warnings;
use utf8;

use Carp qw(croak);

use Intern::Diary::Model::Entry;

sub find_entries_by_diary_id {
    my ($class, $db, $args) = @_;

    my $diary_id = $args->{diary_id} // croak 'diary_id required';

    my $per_page = $args->{limit} // croak 'limit required';
    my $page = $args->{page};

    my $offset = 0;
    $offset = ($page - 1) * $per_page
        if defined $page && defined $per_page;

    my $entries = [];
    my $entries = $db->select_all(q[
        SELECT * FROM entry
        WHERE diary_id  = ?
        ORDER BY diary_id, created_date DESC
        LIMIT ?
        OFFSET ?
        ], $diary_id, $per_page, $offset) or return;
    return [ map {
        Intern::Diary::Model::Entry->new($_);
        } @$entries ];
}

sub find_entry_by_entry_id {
    my ($class, $db, $args) = @_;

    my $entry_id = $args->{entry_id} // croak 'entry_id required';

    my $row = $db->select_row(q[
        SELECT * FROM entry
          WHERE entry_id  = ?
    ], $entry_id) or return;
    return Intern::Diary::Model::Entry->new($row);
}

sub create {
    my ($class, $db, $args) = @_;

    my $diary_id = $args->{diary_id} // croak 'diary_id required';
    my $title = $args->{title} // croak 'title required';
    my $body = $args->{body} // croak 'body required';

    my $now = Intern::Diary::Util::now;

    $db->query(q[
        INSERT INTO entry (diary_id, title, body, created_date)
          VALUES (?)
    ], [ $diary_id, $title, $body, $now ]);
}

sub update {
    my ($class, $db, $args) = @_;

    my $entry_id = $args->{entry_id} // croak 'entry_id required';
    my $title = $args->{title} // croak 'title required';
    my $body = $args->{body} // croak 'body required';

    $db->query(q[
        UPDATE entry
          SET
            title = ?,
            body = ?
          WHERE
            entry_id = ?
    ], $title, $body, $entry_id );
}

sub delete_entry {
    my ($class, $db, $entry) = @_;

    $db->query(q[
        DELETE FROM entry
          WHERE
            entry_id = ?
    ], $entry->entry_id);
}

sub add_entry {
    my ($class, $db, $args) = @_;

    my $diary = $args->{diary} // croak 'diary required';
    my $entry_title = $args->{entry_title} // croak 'entry_title required';
    my $body = $args->{body} // croak 'body required';


    $class->create($db, +{
            diary_id  => $diary->diary_id,
            title    => $entry_title,
            body    => $body
        });

} 

sub delete_entry_by_entry_id {
    my ($class, $db, $args) = @_;

    my $entry_id = $args->{entry_id} // croak 'entry_id required';

   my $entry = $class->find_entry_by_entry_id($db, +{
           entry_id => $entry_id
       });

   $class->delete_entry($db, $entry);
}

1;
