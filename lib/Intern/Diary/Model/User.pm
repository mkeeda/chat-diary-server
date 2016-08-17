package Intern::Diary::Model::User;

use strict;
use warnings;
use utf8;


use Class::Accessor::Lite (
    ro => [qw(
        user_id
        name
    )],
    new => 1,
);

1;
