package Intern::Diary::Engine::Diary;

use strict;
use warnings;
use utf8;

use Intern::Diary::Service::Entry;

sub diary {
    
    my ($class, $c) = @_;

    my $entries = Intern::Diary::Service::Entry->find_entries_by_diary_id(
            $c->dbh, {
                diary_id => $c->req->path_parameters->{diary_id},
                limit => 10,
        });

    $c->html('diary.html',{
            entries => $entries,
        });
}

1;
__END__
