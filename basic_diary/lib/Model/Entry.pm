package Model::Entry;

use strict;
use warnings;
use utf8;

use Class::Accessor::Lite (
  ro => [qw(
    date
    title
    body
    )],
  new => 1,
);

1;
