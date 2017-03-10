package Intern::Diary::Engine::API;

use strict;
use warnings;
use utf8;

use JSON::Types;
use Text::MeCab;
use Encode;

use Data::Printer;
use Image::Magick;
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
            has_next => $has_next,
        });
}

sub add_entry {
    my ($class, $c) = @_;

    my $request_json = $c->req->convert_request_into_json;

    my $diary_id = $request_json->{diary_id};
    my $title = $request_json->{title};
    my $body = $request_json->{body};

    my $diary = Intern::Diary::Service::Diary->find_diary_by_id(
        $c->dbh, {
            user => $c->user,
            diary_id => $diary_id,
        });

    my $dbh = $c->dbh;
    Intern::Diary::Service::Entry->add_entry($dbh, {
            diary => $diary,
            entry_title => $title,
            body => $body,
        }); 
    my $entry_id = $dbh->last_insert_id;
    $c->json({
            status => 'success',
            entry_id => JSON::Types::number $entry_id,
        });

}

sub chat {
    my ($class, $c) = @_;

    my $request_json = $c->req->convert_request_into_json;

    my $text = $request_json->{text};
    my $mecab = Text::MeCab->new();
    my $question = 'none';
    my $noun = '';

    #名詞の単語だけ取ってくる
    my $noun_words = [];
    for (my $node = $mecab->parse($text); $node; $node = $node->next) {
        my $feature = [];
        my $surface = $node->surface;
        @$feature = split( /,/, $node->feature);
        if( encode_utf8("名詞") eq $feature->[0] ){
            push @$noun_words, $surface;
        }
    }
    
    if(scalar(@$noun_words)) {
        $noun = $noun_words->[0];
        $question = $noun . encode_utf8("はどうだった？");
    }

    $c->json({
            question => decode_utf8($question),
            noun => decode_utf8($noun),
        });
}


sub add_entry_image {
    my ($class, $c) = @_;

    my $entry_id = $c->req->parameters->{entry_id};
    my $uploads = $c->req->uploads;

    die 'uploads empty' unless defined $uploads;


    my $entry = Intern::Diary::Service::Entry->find_entry_by_entry_id(
        $c->dbh, {
            entry_id => $entry_id,
        });

    Intern::Diary::Service::Entry->update(
        $c->dbh, {
            entry_id => $entry_id,
            title => $entry->title,
            body => $entry->body,
            image_name => $entry_id . ".png",
        });

    # 静的ファイル置き場に保存
    my $p = new Image::Magick;
    $p->Read($uploads->{image}->path);
    $p->Write("static/images/$entry_id.png");

    $c->json({
            status => 'success',
        });
}
1;
__END__
