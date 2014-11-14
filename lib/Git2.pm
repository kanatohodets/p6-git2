use v6;
use NativeCall;

class Repository { ... };

sub git_libgit2_init is native("libgit2") { ... };
git_libgit2_init();

sub address-of($native-thing) {
    my $arr := CArray[OpaquePointer].new();
    $arr[0] = $native-thing;
    $arr;
}

sub deref($array) { $array[0]; }

class Repository {
    my class git-repo is repr('CPointer') { }
    has git-repo $!r;

    sub init-repo(CArray, Str, int) returns int is native("libgit2") is symbol('git_repository_init') { ... };

    submethod BUILD(:$!r) { }

    method init (Str $path) {
        my $r := git-repo.new();
        my $ret = init-repo(address-of $r, $path, 0);
        Failure unless $ret == 0;
        Repository.new($r);
    }

    method gist() { $!r }

    sub clone-repo(CArray, Str, Str, OpaquePointer) returns int is native("libgit2") is symbol('git_clone') { ... };

    method clone (Str $url, Str $path) {
        my $r := git-repo.new();
        my $ret = clone-repo(address-of($r), $url, $path, OpaquePointer.new());
        Failure unless $ret == 0;
        Repository.new(:$r);
    }

    sub open-repo(git-repo, Str, OpaquePointer) returns int is native("libgit2") is symbol('git_repository_open') { ... };

    method open (Str $path) {
        my $r := git-repo.new();
        my $ret = open-repo($r, $path);
        Failure unless $ret == 0;
        Repository.new(:$r);
    }

    sub repo-is-empty(OpaquePointer) returns int is native("libgit2") is symbol('git_repository_is_empty') { ... };

    # WTF: address-of $!r passed to repo-is-empty causes a segfault.
    # OpaquePointer.new($!r.WHERE) passed results in a working call. bluuurgh?
    method is-empty() { repo-is-empty(OpaquePointer.new($!r.WHERE)).Bool };

    sub repo-is-bare(CArray) returns int is native("libgit2") is symbol('git_repository_is_bare') { ... };

    method is-bare() { repo-is-bare(address-of $!r).Bool };

}

