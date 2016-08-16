use strict;
use warnings;
use Model::Diary;

use Test::More;

use_ok 'Model::Diary';

my $diary = Model::Diary->new(
  diary_name => 'Johnの日記'
);
is $diary->diary_name, 'Johnの日記';

my $entry = $diary->add_entry(
  date  => '2016-07-01',
  title => 'entry1',
  body  => 'これが日記の本文だよ',
);
is $diary->entries->[0]->{date}, '2016-07-01';
is $diary->entries->[0]->{title}, 'entry1';
is $diary->entries->[0]->{body}, 'これが日記の本文だよ';

$entry = $diary->add_entry(
  date  => '2016-08-01',
  title => 'entry2',
  body  => '日記2つめ',
);
is $diary->entries->[1]->{date}, '2016-08-01';
is $diary->entries->[1]->{title}, 'entry2';
is $diary->entries->[1]->{body}, '日記2つめ';

$entry = $diary->add_entry(
  date  => '2016-08-15',
  title => 'entry3',
  body  => '日記3つめ',
);
is $diary->entries->[2]->{date}, '2016-08-15';
is $diary->entries->[2]->{title}, 'entry3';
is $diary->entries->[2]->{body}, '日記3つめ';

my $recent_entries = $diary->get_recent_entries;
is_deeply $recent_entries->[0], {
  date  => '2016-08-15',
  title => 'entry3',
  body  => '日記3つめ',
};
is_deeply $recent_entries->[1], {
  date  => '2016-08-01',
  title => 'entry2',
  body  => '日記2つめ',
};
is_deeply $recent_entries->[2], {
  date  => '2016-07-01',
  title => 'entry1',
  body  => 'これが日記の本文だよ',
};


done_testing();
