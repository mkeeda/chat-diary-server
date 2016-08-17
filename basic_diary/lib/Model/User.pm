package Model::User;

use strict;
use warnings;
use utf8;

use Model::Diary;
use Encode;


use Class::Accessor::Lite (
  ro => [qw(
    user_name 
    )],
  rw => [qw(
    diary
    )],
  new => 0,
);

sub new {
    my ($class, %args) = @_;
    return bless {
      diary => undef,
      %args
    }, $class;
}

sub add_diary {
  my ($self, %args) = @_;

  #2回以降の追加はエラーで止める
  if(defined$self->diary) {
    die "diary only one\n";
  }

  my $diary = Model::Diary->new(
    diary_name => $args{name}
  );
  $self->diary($diary);
  return $diary;
}

1;
