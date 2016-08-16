use strict;
use warnings;
use Model::Entry;

use Test::More;

use_ok 'Model::Entry';

my $entry = Model::Entry->new(
  date => '2016-08-16',
  title => '今日の日記',
  body => 'たのしかった',
);
is $entry->date, '2016-08-16';
is $entry->title, '今日の日記';
is $entry->body, 'たのしかった';


done_testing();

