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
    add_d    => \&add_diary,
    add_e    => \&add_entry,
    list   => \&list_entries,
    delete => \&delete_entry,
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
