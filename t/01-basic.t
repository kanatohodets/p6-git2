use v6;
use NativeCall;
use lib 'lib';
use Git2;

my $repo = Repository.clone('https://github.com/sillymoose/Perl6-One-Liners.git', 'one-liners.git');
say $repo;

