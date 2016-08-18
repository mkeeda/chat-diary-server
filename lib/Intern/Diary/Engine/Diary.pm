package Intern::Diary::Engine::Diary;

use strict;
use warnings;
use utf8;

use Intern::Diary::Service::Entry;

sub diary {
    
    my ($class, $c) = @_;

    my $diary_id = $c->req->path_parameters->{diary_id};
    my $page = $c->req->query_parameters->{page};

    my $entries = Intern::Diary::Service::Entry->find_entries_by_diary_id(
            $c->dbh, {
                diary_id => $diary_id,
                limit => 1,
                page => $page,
                
        });
    $c->html('diary.html',{
            entries => $entries,
            diary_id => $diary_id,
        });
}

1;
__END__
