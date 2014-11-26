use v6;
use NativeCall;
use Git2 :util;

module Git2::Signature::Defs;

class GitSignature is repr('CStruct') is export {
    has Str $.name;
    has Str $.email;
    has int64 $.time;
}


