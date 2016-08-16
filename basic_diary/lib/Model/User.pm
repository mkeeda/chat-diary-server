package Model::User;

use strict;
use warnings;
use utf8;

use Model::Diary;

use Class::Accessor::Lite (
  ro => [qw(
    user_name 
    )],
  new => 1,
);

sub add_diary {
  my ($self, %args) = @_;
  my $diary = Model::Diary->new(
    diary_name => $args{name}
  );
  return $diary;
}

1;
