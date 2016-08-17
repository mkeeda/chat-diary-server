use strict;
use warnings;
use utf8;

use DBIx::Sunny;
use Encode qw(encode_utf8 decode_utf8);
use Data::Dumper;

use Intern::Diary::Service::User;
# use Intern::Diary::Service::Diary;

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
