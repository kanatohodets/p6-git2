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

    sub init(CArray, Str, int) returns int is native("libgit2") is symbol('git_repository_init') { ... };

    method init (Str $path) {
        my $r := address-of git-repo.new();
        my $ret = init($r, $path, 0);
        Failure unless $ret == 0;
        $r;
    }

    sub clone(CArray, Str, Str, OpaquePointer) returns int is native("libgit2") is symbol('git_clone') { ... };

    method clone (Str $url, Str $path) {
        my $r := address-of git-repo.new();
        my $ret = clone($r, $url, $path, OpaquePointer.new());
        Failure unless $ret == 0;
        $r;
    }
}

