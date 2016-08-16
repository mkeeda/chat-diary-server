use strict;
use warnings;
use Model::User;

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


done_testing();
