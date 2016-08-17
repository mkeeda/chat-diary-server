package Intern::Diary::Model::Entry;

use strict;
use warnings;
use utf8;

use Class::Accessor::Lite (
    ro => [qw(
        entry_id
        diary_id
        title
        body
    )],
    new => 1,
);


sub created_date {
    my ($self) = @_;
    $self->{_created_date} ||= eval { Intern::Diary::Util::datetime_from_db(
        $self->{created_date}
    )};
}

1;
