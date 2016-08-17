use strict;
use warnings;
use utf8;

use DBIx::Sunny;
use Encode qw(encode_utf8 decode_utf8);
use Data::Dumper;

use Intern::Diary::Service::User;
use Intern::Diary::Service::Diary;
use Intern::Diary::Service::Entry;

my %HANDLERS = (
    add_d  => \&add_diary,
    add_e  => \&add_entry,
    list_d => \&list_diaries,
    list_e => \&list_entries,
    delete_e => \&delete_entry,
    update_e => \&update_entry,
);

my $name     = shift @ARGV;
my $command  = shift @ARGV;
my $dsn      = 'dbi:mysql:dbname=intern_diary;host=localhost';
my $username = 'test';
my $password = 'test';

my $db = DBIx::Sunny->connect($dsn, $username, $password);


my $user = Intern::Diary::Service::User->find_user_by_name($db, +{ name => $name });
unless ($user) {
    $user = Intern::Diary::Service::User->create($db, +{ name => $name });
}

print Dumper $user;

my $handler = $HANDLERS{ $command };
$handler->($user, @ARGV);

exit 0;


sub add_diary {
    my ($user, $diary_title) = @_;

    die 'diary_title required' unless defined $diary_title;

    my $diary = Intern::Diary::Service::Diary->add_diary($db, +{
            user        => $user,
            diary_title => decode_utf8 $diary_title,
        });

}


sub add_entry {
    my ($user, $diary_id, $entry_title, $body) = @_;

    die 'diary_id required' unless defined $diary_id;
    die 'entry_title required' unless defined $entry_title;
    die 'body required' unless defined $body;

    my $diary = Intern::Diary::Service::Diary->find_diary_by_id($db, +{
            user     => $user,
            diary_id => $diary_id
        });

    my $entry = Intern::Diary::Service::Entry->add_entry($db, +{
            diary        => $diary,
            entry_title  => $entry_title,
            body         => $body
        });
}

sub list_diaries {
    my ($user, $limit) = @_;

    unless(defined $limit) {
        $limit = 10;
    }
    printf "--- %s's Diaries ---\n", $user->name;

    my $diaries = Intern::Diary::Service::Diary->find_diarys_by_user($db, +{
        user => $user,
        limit => $limit
    });

    print 'diary_id user_id title' . "\n";
    foreach my $diary (@$diaries) {
        print $diary->diary_id . ' ' . $diary->user_id . ' ' . encode_utf8($diary->title) . "\n";
    }
}

sub list_entries {
    my ($user, $diary_id, $limit) = @_;

    unless(defined $limit) {
        $limit = 10;
    }

    die 'diary_id required' unless defined $diary_id;

    printf "--- %s's Entries ---\n", $user->name;

    my $entries = Intern::Diary::Service::Entry->find_entries_by_diary_id($db, +{
        diary_id => $diary_id,
        limit => $limit
    });
    print 'entry_id title diary_id title body created_date' . "\n";
    foreach my $entry (@$entries) {
        print $entry->entry_id . ' ' . 
        $entry->diary_id . ' ' . 
        encode_utf8($entry->title) . ' ' . 
        encode_utf8($entry->body) . ' ' . 
        $entry->created_date->ymd ."\n";
    }

}

sub delete_entry {
    my ($user, $diary_id, $entry_id) = @_;

    die 'diary_id required' unless defined $diary_id;
    die 'entry_id required' unless defined $entry_id;

    Intern::Diary::Service::Entry->delete_entry_by_entry_id($db, +{
            diary_id => $diary_id,
            entry_id => $entry_id,
    });

    print "Deleted \n";
}

sub update_entry {
    my ($user, $entry_id, $title, $body) = @_;

    die 'entry_id required' unless defined $entry_id;
    die 'title required' unless defined $title;
    die 'body required' unless defined $body;

    Intern::Diary::Service::Entry->update($db, +{
            entry_id => $entry_id,
            title => $title,
            body => $body,
    });

    print "Updated \n";
}
