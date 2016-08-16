use strict;
use warnings;
use utf8;

use Model::User;
use Data::Dumper;
use Encode;

my $user1 = Model::User->new(user_name => 'John');
print Dumper $user1;

# Diary クラスのインスタンスが返る
my $diary = $user1->add_diary(
  name => 'John の日記1'
);
print Dumper $diary;

my $diary = $user1->add_diary(
  name => 'John の日記2'
);
print Dumper $user1;

print encode_utf8 $diary->diary_name, "\n"; # John の日記です

# Entry クラスのインスタンスが返る
my $entry1 = $diary->add_entry(
  date  => '2016-08-15',
  title => '日記だよ',
  body  => 'これが日記の本文だよ',
);
print Dumper $entry1;

my $entry2 = $diary->add_entry(
  date  => '2016-08-16',
  title => 'これも日記だよ',
  body  => 'やっぱり日記の本文だよ',
);
print Dumper $entry2;
print Dumper $diary;

my $recent_entries = $diary->get_recent_entries;
print Dumper $recent_entries;
print $recent_entries->[0]->body; # やっぱり日記の本文だよ

