package Intern::Bookmark::Model::Entry;

use strict;
use warnings;
use utf8;

use JSON::Types qw();

use Class::Accessor::Lite (
    ro => [qw(
        entry_id
        diary_id
        title
        body
        create_date
    )],
    new => 1,
);
