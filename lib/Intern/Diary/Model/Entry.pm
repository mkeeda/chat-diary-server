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

sub json_hash {
    my ($self) = @_;

    return {
        entry_id => JSON::Types::number $self->entry_id,
        diary_id => JSON::Types::number $self->diary_id,
        title    => JSON::Types::string $self->title,
        body     => JSON::Types::string $self->body,
        created_date => JSON::Types::number $self->created_date->epoch(),
        
    };
}

1;
