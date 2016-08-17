package Intern::Bookmark::Model::Entry;

use strict;
use warnings;
use utf8;

use Class::Accessor::Lite (
    ro => [qw(
        entry_id
        diary_id
        title
        body
        created_date
    )],
    new => 1,
);

1;
