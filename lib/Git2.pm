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

class Git2 is export {
    my class git-err is repr('CStruct') {
        has Str $.message;
        has int $.klass;
    }

    my sub git-last-err() returns git-err is native("libgit2") is symbol("giterr_last") { ... };
    method last-error() { git-last-err().message; }
}
