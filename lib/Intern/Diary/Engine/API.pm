package Intern::Diary::Engine::API;

use strict;
use warnings;
use utf8;

use JSON::Types;

use Intern::Diary::Service::Diary;
use Intern::Diary::Service::Entry;

sub diaries {
    my ($class, $c) = @_;

    my $diaries = Intern::Diary::Service::Diary->find_diaries_by_user(
        $c->dbh, {
            user => $c->user,
            limit => 10,
        });

    $c->json({
        diaries => [ map { $_->json_hash } @$diaries ],
    });
}

sub diary {
    my ($class, $c) = @_;

    my $diary_id = $c->req->path_parameters->{diary_id};
    my $page = $c->req->query_parameters->{page};
    my $per_page = 10;

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

    $c->json({
        entries => [ map { $_->json_hash } @$entries ],
        per_page  => JSON::Types::number $per_page,
    });
}


1;
__END__
