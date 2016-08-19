package Intern::Diary::Model::Diary;

use strict;
use warnings;
use utf8;

use JSON::Types qw();

use Class::Accessor::Lite (
    ro => [qw(
        diary_id
        user_id

        title
        )],
    new => 1
);

sub json_hash {
    my ($self) = @_;

    return {
        diary_id => JSON::Types::number $self->diary_id,
        user_id  => JSON::Types::number $self->user_id,
        title    => JSON::Types::string $self->title,
    };
}

1;
