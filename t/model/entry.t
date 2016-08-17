package t::Intern::Diary::Model::Entry;

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
    use_ok 'Intern::Diary::Model::Entry';
}

sub _accessor : Tests {
    my $now = Intern::Diary::Util::now;
    my $entry = Intern::Diary::Model::Entry->new(
        entry_id => 1,
        diary_id => 1,
        title => 'test_title',
        body => 'test_body',
        created_date => DateTime::Format::MySQL->format_datetime($now),
    );
    is $entry->entry_id, 1;
    is $entry->diary_id, 1;
    is $entry->title, 'test_title';
    is $entry->body, 'test_body';
    is $entry->created_date->epoch, $now->epoch;
}

__PACKAGE__->runtests;

1;
