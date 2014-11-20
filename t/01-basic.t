use v6;
use NativeCall;
use lib 'lib';
use Git2;
use Git2::Repository;

#`(
my $repo = Repository.clone('https://github.com/sillymoose/Perl6-One-Liners.git', 'one-liners.git');
say $repo;
say "is the cloned repo bare? {$repo.is-bare}";
say "is the cloned repo empty? {$repo.is-empty}";

my $repo = Repository.open('foobar');
say $repo;
say "is the opened repo empty? {$repo.is-empty}";
say "is the opened repo bare? {$repo.is-bare}";

say Repository.discover("foobar/blorg/baz");
);

my $repo = Repository.init("blorg-init.git");
say "thing thing thing? ", Git2.last-error();
say "is the created repo empty? {$repo.is-empty}";
say "is the created repo bare? {$repo.is-bare}";
