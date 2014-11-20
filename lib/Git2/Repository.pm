use v6;
use NativeCall;
use Git2 :util;

module Git2::Repository;

class Repository is export {
    my class git-repo is repr('CPointer') { };

    has CArray $!repo;

    submethod BUILD(:$repo) { $!repo = $repo; }

    my %init-flag-defs = (
        bare                => 1 +< 0,
        no-reinit           => 1 +< 1,
        no-dotgit-dir       => 1 +< 2,
        mkdir               => 1 +< 3,
        mkpath              => 1 +< 4,
        external-template   => 1 +< 5,
        relative-gitlink    => 1 +< 6
    );

    # need to create git-init struct and pass pointer to that, it has a flags
    # field for the mask with option flags
    my class repo-init-options is repr("CStruct") {
        has uint $!version;
        has uint32 $!flags;
        has uint32 $!mode;
        has Str $!workdir-path;
        has Str $!description;
        has Str $!template-path;
        has Str $!origin-url;
        submethod BUILD(:$version, :$flags) {
            $!version = $version;
            $!flags = $flags;
        }
        method get-flags() { $!flags }
        method set-flags($mask) { $!flags = $mask }
    }
    sub init-repo-ext(CArray[git-repo], Str, repo-init-options)
        returns int
        is native("libgit2")
        is symbol('git_repository_init_ext') { ... };

    method init (Str $path, @flags = [<mkdir mkpath>]) {
        my $repo = &-in-c git-repo;
        my $flag-mask = create-flag-mask %init-flag-defs, @flags;
        my $init-options = repo-init-options.new(version => 1, flags => $flag-mask);
        # for some insane reason this is dying with a permissions error in
        # git_futils_mkdir. it works when run as sudo. I do not understand.
        my $ret = init-repo-ext($repo, $path, $init-options);
        fail "failed to init: $ret" unless $ret == 0;
        Repository.new(:$repo);
    }

    method gist() { *-in-c $!repo }

    sub clone-repo(CArray[git-repo], Str, Str, OpaquePointer) returns int is native("libgit2") is symbol('git_clone') { ... };
    method clone (Str $url, Str $path) {
        my $repo := &-in-c git-repo;
        my $ret = clone-repo($repo, $url, $path, OpaquePointer.new());
        fail "failed to clone!" unless $ret == 0;
        return Repository.new(:$repo);
    }

    sub open-repo-ext(CArray[git-repo], Str, int, Str)
        returns int
        is native("libgit2")
        is symbol('git_repository_open_ext') { ... };

    my %open-flags = (
        no-search       => 1 +< 0,
        open-cross-fs   => 1 +< 1,
        open-bare       => 1 +< 2
    );

    method open(Str $path, @flags = [<no-search>], $ceiling-dirs = '') {
        my $repo = &-in-c git-repo;
        my $flag-mask = create-flag-mask %open-flags, @flags;
        my $ret = open-repo-ext($repo, $path, $flag-mask, $ceiling-dirs);
        fail "failed to open!" unless $ret == 0;
        return Repository.new(:$repo);
    }

    sub is-empty(git-repo) returns int is native("libgit2") is symbol('git_repository_is_empty') { ... };
    method is-empty() { is-empty(*-in-c $!repo).Bool };

    sub is-bare(git-repo) returns int is native("libgit2") is symbol('git_repository_is_bare') { ... };
    method is-bare() { is-bare(*-in-c $!repo).Bool };

    my class git-buffer is repr('CStruct') {
        has Str $.ptr;
        has uint $.size;
        has uint $.asize;
    }

    sub discover-repo(git-buffer, Str, int, Str) returns int is native("libgit2") is symbol('git_repository_discover') { ... };
    method discover(Str $path, Bool $across-fs = False, Str $ceiling-dirs = '') {
        my $git-buf = git-buffer.new();
        my $ret = discover-repo($git-buf, $path, $across-fs.Int, $ceiling-dirs);
        fail "failure discovering repo: $ret" unless $ret == 0;
        return $git-buf.ptr;
    }
}
