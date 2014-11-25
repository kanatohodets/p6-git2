use v6;
use NativeCall;
use Git2;
use Git2 :util;
use Git2::Repository::Defs;

module Git2::Repository;

class Repository is export {
    my class GitRepo is repr('CPointer') { };
    has CArray $.repo-ptr;

    submethod BUILD(:$!repo-ptr) { }

    sub init-repo-ext(CArray[GitRepo], Str, InitOptions)
        returns int
        is native("libgit2")
        is symbol('git_repository_init_ext') { ... };

    method init (Str $path, @flags = [<mkpath>]) {
        my $repo = &-in-c GitRepo;
        my $flag-mask = create-flag-mask %init-flags, @flags;
        my $init-options = InitOptions.new(version => 1, flags => $flag-mask);

        call-with-error(&init-repo-ext, [$repo, $path, $init-options]);

        Repository.new(repo-ptr => $repo);
    }

    method gist() { *-in-c $!repo-ptr }

    sub clone-repo(CArray[GitRepo], Str, Str, OpaquePointer)
        returns int
        is native("libgit2")
        is symbol('git_clone') { ... };

    method clone (Str $url, Str $path) {
        my $repo := &-in-c GitRepo;

        call-with-error(&clone-repo, [$repo, $url, $path, OpaquePointer.new()]);

        return Repository.new(repo-ptr => $repo);
    }

    sub open-repo-ext(CArray[GitRepo], Str, int, Str)
        returns int
        is native("libgit2")
        is symbol('git_repository_open_ext') { ... };

    method open(Str $path, @flags = [<no-search>], $ceiling-dirs = '') {
        my $repo = &-in-c GitRepo;
        my $flag-mask = create-flag-mask %open-flags, @flags;

        call-with-error(&open-repo-ext, [$repo, $path, $flag-mask, $ceiling-dirs]);

        return Repository.new(repo-ptr => $repo);
    }

    method is-path-repo(Str $path, @flags = [<no-search>], $ceiling-dirs = '') {
        # NULL is represented by a type object
        my $null = GitRepo;
        my $flag-mask = create-flag-mask %open-flags, @flags;
        my $ret = open-repo-ext($null, $path, $flag-mask, $ceiling-dirs);
        return True if $ret == 0;
        return False;
    }

    sub is-empty(GitRepo)
        returns int
        is native("libgit2")
        is symbol('git_repository_is_empty') { ... };

    method is-empty() { is-empty(*-in-c $!repo-ptr).Bool };

    sub is-bare(GitRepo)
        returns int
        is native("libgit2")
        is symbol('git_repository_is_bare') { ... };

    method is-bare() { is-bare(*-in-c $!repo-ptr).Bool };

    sub is-shallow(GitRepo)
        returns int
        is native("libgit2")
        is symbol('git_repository_is_shallow') { ... };

    method is-shallow() { is-shallow(*-in-c $!repo-ptr).Bool };

    sub discover-repo(GitBuffer, Str, int, Str)
        returns int
        is native("libgit2")
        is symbol('git_repository_discover') { ... };

    method discover(Str $path, Bool $across-fs = False, Str $ceiling-dirs = '') {
        my $git-buf = GitBuffer.new();

        call-with-error(&discover-repo, [$git-buf, $path, $across-fs.Int, $ceiling-dirs]);

        return $git-buf.ptr;
    }
}
