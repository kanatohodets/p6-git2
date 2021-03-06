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

sub call-with-error(&native-sub, @params) is export(:util) {
    my $symbol = &native-sub.native_symbol;
    my $ret = &native-sub.(|@params);
    if $ret != 0 {
        my $message = Git2.last-error();
        die $message if $message;;
        die "$symbol failed, but no libgit2 error message was found. libgit2 return code: $ret";
    }
}

sub create-flag-defs(@flags) is export(:util) {
    @flags.kv.map(-> $index, $flag {$flag => 2 ** $index});
}

sub create-flag-mask(%mapping, *@flags) is export(:util) {
    my $flag-mask = 0;
    for @flags -> $flag-name {
        if $flag-name {
            if %mapping{$flag-name}:exists {
                $flag-mask +|= %mapping{$flag-name};
            } else {
                die "unknown flag name \"$flag-name\". \nValid flags: \n\t{%mapping.keys.join("\n\t")}";
            }
        }
    }
    return $flag-mask;
}

class GitBuffer is repr('CStruct') is export(:util) {
    has Str $.ptr;
    has uint $.size;
    has uint $.asize;
}

class Git2 is export {
    my class git-err is repr('CStruct') {
        has Str $.message;
        has int $.klass;
    }

    my sub git-last-err() returns git-err is native("libgit2") is symbol("giterr_last") { ... };
    method last-error() {
        my $err = git-last-err();
        $err.message if $err;
    }
}
