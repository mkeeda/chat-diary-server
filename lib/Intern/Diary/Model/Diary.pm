package Intern::Diary::Model::Diary;

use strict;
use warnings;
use utf8;


use Class::Accessor::Lite (
    ro => [qw(
        diary_id
        user_id

        title
        )],
    rw => [qw(
        entries
        )],
    new => 1
);

1;
