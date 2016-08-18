package Intern::Diary::Engine::Entry;

use strict;
use warnings;
use utf8;

use Intern::Diary::Service::Diary;
use Intern::Diary::Service::Entry;

sub add_get {
    
    my ($class, $c) = @_;

    my $diary_id = $c->req->parameters->{diary_id};

    my $diary = Intern::Diary::Service::Diary->find_diary_by_id(
        $c->dbh, {
            user => $c->user,
            diary_id => $diary_id,
        });
    unless(defined $diary){
        $c->throw(404);
    }
    $c->html('entry/add.html', {
            diary_id => $diary->diary_id,
        });
}

sub add_post {
    my ($class, $c) = @_;

    my $diary_id = $c->req->parameters->{diary_id};
    my $title = $c->req->string_param('title');
    my $body = $c->req->string_param('body');

    my $diary = Intern::Diary::Service::Diary->find_diary_by_id(
        $c->dbh, {
            user => $c->user,
            diary_id => $diary_id,
        });

    Intern::Diary::Service::Entry->add_entry($c->dbh, {
            diary => $diary,
            entry_title => $title,
            body => $body,
    });

    $c->res->redirect('/');
}

sub delete_get {
    
    my ($class, $c) = @_;

    my $entry_id = $c->req->parameters->{entry_id};

    my $entry = Intern::Diary::Service::Entry->find_entry_by_entry_id(
        $c->dbh, {
            user => $c->user,
            entry_id => $entry_id,
        });
    unless(defined $entry){
        $c->throw(404);
    }

    $c->html('entry/delete.html', {
            entry_id => $entry->entry_id,
            title => $entry->title,
            body=> $entry->body,
        });
}

sub delete_post {
    my ($class, $c) = @_;

    my $entry_id = $c->req->parameters->{entry_id};

    Intern::Diary::Service::Entry->delete_entry_by_entry_id($c->dbh, {
            entry_id => $entry_id,
    });

    $c->res->redirect('/');
}


1;
__END__
