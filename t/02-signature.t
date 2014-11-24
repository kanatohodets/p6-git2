use v6;
use NativeCall;
use lib 'lib';
use Git2;
use Git2::Signature;
use Git2::Repository;
use Shell::Command;
use Test;

my $foo = Sig.new('Bob Jones', 'bjones@jones.bob');
say $foo.name;
say $foo.email;
say $foo.time;

my $repo = Repository.init('foobar.git');
my $default = Sig.default($repo);
say $default.name;
say $default.email;
say $default.time;
rm_rf 'foobar.git';
