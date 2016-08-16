package Model::Diary;

use strict;
use warnings;
use utf8;

use Model::Entry;

use Class::Accessor::Lite (
  ro => [qw(
    diary_name
    )],
  rw => [qw(
    entries
    )],
  new => 1,
);

sub add_entry {
  my ($self, %args) = @_;
  my $entry = Model::Entry->new(
    date  => $args{date},
    title => $args{title},
    body  => $args{body}
  );
  push @{$self->{entries}}, $entry;
  return $entry;
}

sub get_recent_entries {
  my ($self) = @_;
  my @recent_entries = sort { 
    $b->{date} cmp $a->{date}
  } @{$self->{entries}};
  
  return \@recent_entries;
}

1;
