use v6;
use NativeCall;
use lib 'lib';
use Git2;
use Git2::Repository;
use Test;
use Shell::Command;

sub examine-repo(
    $repo, $path,
    :$name = '',
    :$should-be-bare = False,
    :$should-be-empty = True,
    :$should-be-defined = True,
    :$should-be-shallow = False) {
        is $repo.isa(Repository), True, "$name repo is a Repository";
        is !!$repo, $should-be-defined, "$name repo is defined";
        is $repo.is-empty, $should-be-empty, "the new $name repo is empty";
        is $repo.is-bare, $should-be-bare, "the new $name repo is { $should-be-bare ?? "" !! "NOT " }bare";
        is $repo.is-shallow, $should-be-shallow, "the new $name repo is { $should-be-shallow ?? "" !! "NOT " }a shallow clone";
        is Repository.is-path-repo($path), True, "is the path to the $name repo a repo?";
}

{
    is Repository.is-path-repo("sdgsdfgsdgsdfasf"), False, "is-path-repo is false for gibberish";
}

my $successful-init = False;
{
    my $repo-location = 'test-non-bare-repo.git';
    my $repo = Repository.init($repo-location);
    examine-repo($repo, $repo-location);
    $successful-init = True;
    rm_rf $repo-location;
}
{
    my $repo-location = 'test-bare-repo.git';
    my $bare-repo = Repository.init($repo-location, <bare mkpath>);
    examine-repo($bare-repo, $repo-location, :should-be-bare<True>, :name<bare>);
    rm_rf $repo-location;
}
{
    my $repo-location = 'one-liners.git';
    my $repo = Repository.clone('https://github.com/sillymoose/Perl6-One-Liners.git', $repo-location);
    examine-repo($repo, $repo-location, :name<cloned>, :should-be-empty<False>);
    rm_rf $repo-location;
}

{
    if $successful-init {
        my $repo-location = 'to-be-opened.git';
        Repository.init($repo-location);
        my $repo = Repository.open($repo-location);
        examine-repo($repo, $repo-location, :name<opened>);
        rm_rf $repo-location;
    }
}

