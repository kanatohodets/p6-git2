use v6;
use NativeCall;
use Git2 :util;

module Git2::Repository;

class Repository is export {
    my class git-repo is repr('CPointer') { };

    has CArray $!repo;

    submethod BUILD(:$repo) { $!repo = $repo; }

    sub init-repo(CArray[git-repo], Str, int) returns int is native("libgit2") is symbol('git_repository_init') { ... };
    method init (Str $path) {
        my $repo = &-in-c git-repo;
        my $ret = init-repo($repo, $path, 0);
        die "failed to init" unless $ret == 0;
        Repository.new(:$repo);
    }

    method gist() { *-in-c $!repo }

    sub clone-repo(CArray[git-repo], Str, Str, OpaquePointer) returns int is native("libgit2") is symbol('git_clone') { ... };
    method clone (Str $url, Str $path) {
        my $repo := &-in-c git-repo;
        my $ret = clone-repo($repo, $url, $path, OpaquePointer.new());
        die "failed to clone!" unless $ret == 0;
        return Repository.new(:$repo);
    }

    sub open-repo(CArray[git-repo], Str) returns int is native("libgit2") is symbol('git_repository_open') { ... };
    method open (Str $path) {
        my $repo = &-in-c git-repo;
        my $ret = open-repo($repo, $path);
        die "failed to open!" unless $ret == 0;
        return Repository.new(:$repo);
    }

    sub is-empty(git-repo) returns int is native("libgit2") is symbol('git_repository_is_empty') { ... };
    method is-empty() { is-empty(*-in-c $!repo).Bool };

    sub is-bare(git-repo) returns int is native("libgit2") is symbol('git_repository_is_bare') { ... };
    method is-bare() { is-bare(*-in-c $!repo).Bool };

    sub discover-repo(CArray, Str, int, Str) is native("libgit2") is symbol('git_repository_discover') { ... };
    method discover(Str $path) {

    }
}
