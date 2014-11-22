use v6;
use NativeCall;
use Git2;
use Git2 :util;
use Git2::Repository::Defs;

module Git2::Repository;

class Repository is export {
    my class GitRepo is repr('CPointer') { };
    has CArray $!repo;

    submethod BUILD(:$!repo) { }

    sub init-repo-ext(CArray[GitRepo], Str, InitOptions)
        returns int
        is native("libgit2")
        is symbol('git_repository_init_ext') { ... };

    method init (Str $path, @flags = [<mkpath>]) {
        my $repo = &-in-c GitRepo;
        my $flag-mask = create-flag-mask %init-flags, @flags;
        my $init-options = InitOptions.new(version => 1, flags => $flag-mask);
        my $ret = init-repo-ext($repo, $path, $init-options);
        if $ret != 0 {
            my $message = Git2.last-error();
            die $message if $message;;
            die "failed to initialize repository, but no libgit2 error message was found. libgit2 return code: $ret";
        }
        Repository.new(:$repo);
    }

    method gist() { *-in-c $!repo }

    sub clone-repo(CArray[GitRepo], Str, Str, OpaquePointer)
        returns int
        is native("libgit2")
        is symbol('git_clone') { ... };

    method clone (Str $url, Str $path) {
        my $repo := &-in-c GitRepo;
        my $ret = clone-repo($repo, $url, $path, OpaquePointer.new());
        if $ret != 0 {
            my $message = Git2.last-error();
            die $message if $message;;
            die "failed to clone repository, but no libgit2 error message was found. libgit2 return code: $ret";
        }
        return Repository.new(:$repo);
    }

    sub open-repo-ext(CArray[GitRepo], Str, int, Str)
        returns int
        is native("libgit2")
        is symbol('git_repository_open_ext') { ... };

    method open(Str $path, @flags = [<no-search>], $ceiling-dirs = '') {
        my $repo = &-in-c GitRepo;
        my $flag-mask = create-flag-mask %open-flags, @flags;
        my $ret = open-repo-ext($repo, $path, $flag-mask, $ceiling-dirs);
        if $ret != 0 {
            my $message = Git2.last-error();
            die $message if $message;;
            die "failed to open repository, but no libgit2 error message was found. libgit2 return code: $ret";
        }
        return Repository.new(:$repo);
    }

    sub is-empty(GitRepo)
        returns int
        is native("libgit2")
        is symbol('git_repository_is_empty') { ... };

    method is-empty() { is-empty(*-in-c $!repo).Bool };

    sub is-bare(GitRepo)
        returns int
        is native("libgit2")
        is symbol('git_repository_is_bare') { ... };

    method is-bare() { is-bare(*-in-c $!repo).Bool };

    sub discover-repo(GitBuffer, Str, int, Str)
        returns int
        is native("libgit2")
        is symbol('git_repository_discover') { ... };

    method discover(Str $path, Bool $across-fs = False, Str $ceiling-dirs = '') {
        my $git-buf = GitBuffer.new();
        my $ret = discover-repo($git-buf, $path, $across-fs.Int, $ceiling-dirs);
        if $ret != 0 {
            my $message = Git2.last-error();
            die $message if $message;;
            die "failed to discover repository, but no libgit2 error message was found. libgit2 return code: $ret";
        }
        return $git-buf.ptr;
    }
}
