use v6;
use NativeCall;
use lib 'lib';
use Git2;
use Git2::Signature;
use Test;

my $foo = Sig.new('Bob Jones', 'bjones@jones.bob');
say $foo.name;
say $foo.email;
say $foo.time;
