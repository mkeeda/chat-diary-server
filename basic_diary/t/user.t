use strict;
use warnings;
use Model::User;
use Data::Dumper;

use Test::More;

use_ok 'Model::User';

my $user = Model::User->new(
  user_name => 'John'
);
is $user->user_name, 'John';

# add_diaryのテスト
my $diary = $user->add_diary(
  name => 'John の日記です'
);
is $diary->diary_name, 'John の日記です';
print Dumper $user;


done_testing();
