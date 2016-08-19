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

1;
