use v6;
use NativeCall;
use Git2 :util;

module Git2::Repository::Defs;

my @init-flags = <
    bare
    no-reinit
    no-dotgit-dir
    mkdir
    mkpath
    external-template
    relative-gitlink
>;

my @open-flags = <
    no-search
    open-cross-fs
    open-bare
>;

our %init-flags is export = create-flag-defs @init-flags;
our %open-flags is export = create-flag-defs @open-flags;

class InitOptions is repr("CStruct") is export {
    has uint32 $!version;
    has uint32 $!flags;
    has uint32 $!mode;
    has Str $!workdir-path;
    has Str $!description;
    has Str $!template-path;
    has Str $!initial-head;
    has Str $!origin-url;

    # can't use ':$!version' syntax because of:
    #"CStruct can't perform boxed get on flattened attributes yet" 
    submethod BUILD(:$version, :$flags) {
        $!version = $version;
        $!flags = $flags;
    }
}
