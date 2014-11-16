use v6;
use NativeCall;

module Git2;

sub git_libgit2_init is native("libgit2") { ... };

git_libgit2_init();

sub prefix:<*-in-c >(CArray $native-thing) is export(:util){
    return $native-thing[0];
}

sub prefix:<&-in-c >($native-thing) is export(:util) {
    my $arr = CArray[$native-thing.WHAT].new();
    $arr[0] = $native-thing;
    return $arr;
}
