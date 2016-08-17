package t::Intern::Diary::Model::Diary;

use strict;
use warnings;
use utf8;
use lib 't/lib';

use Test::Intern::Diary;

use Test::More;

use parent 'Test::Class';

use Intern::Diary::Util;

sub _use : Test(startup => 1) {
    my ($self) = @_;
    use_ok 'Intern::Diary::Model::Diary';
}

sub _accessor : Tests {
    my $diary = Intern::Diary::Model::Diary->new(
        diary_id => 1,
        user_id => 1,
        title => 'test_title',
    );
    is $diary->diary_id, 1;
    is $diary->user_id, 1;
    is $diary->title, 'test_title';
}

__PACKAGE__->runtests;

1;
