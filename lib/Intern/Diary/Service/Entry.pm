package Intern::Diary::Service::Entry;

use strict;
use warnings;
use utf8;

use Carp qw(croak);

use Intern::Diary::Model::Entry;


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

1;
