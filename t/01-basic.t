use v6;
use NativeCall;
use lib 'lib';
use Git2;

my $repo = Repository.open('one-liners.git');
say "thing? " ~ $repo;
say $repo.is-empty;

