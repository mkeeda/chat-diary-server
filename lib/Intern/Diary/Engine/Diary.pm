package Intern::Diary::Engine::Diary;

use strict;
use warnings;
use utf8;

use Intern::Diary::Service::Entry;

sub diary {
    
    my ($class, $c) = @_;

    my $diary_id = $c->req->path_parameters->{diary_id};
    my $page = $c->req->query_parameters->{page};
    my $per_page = 1;

    my $entries = Intern::Diary::Service::Entry->find_entries_by_diary_id_for_pager(
            $c->dbh, {
                diary_id => $diary_id,
                per_page => $per_page,
                page => $page,
                
        });

    my $has_next = scalar(@$entries) > $per_page ? 1 : 0;
    if($has_next){
        pop @$entries;
    }
    
    $c->html('diary.html',{
            entries => $entries,
            diary_id => $diary_id,
            page => $page,
            has_next => $has_next,
        });
}

1;
__END__
