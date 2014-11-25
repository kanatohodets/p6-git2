use v6;
use NativeCall;
use Git2 :util;
use Git2::Repository;

module Git2::Signature;

class Sig is export {
    my class GitSignature is repr('CStruct') {
        has Str $.name;
        has Str $.email;
        has int64 $.time;
    }

    has $!sig handles <name email time>;

    submethod BUILD(:$!sig) { }

    sub default-sig(CArray[GitSignature], OpaquePointer)
        returns int
        is native('libgit2')
        is symbol('git_signature_default') { ... };

    method default(Repository $repo) {
        my $sig = &-in-c GitSignature.new();

        call-with-error(&default-sig, [$sig, *-in-c $repo.repo-ptr]);

        self.bless(sig => *-in-c $sig);
    }

    sub sig-now(CArray[GitSignature], Str, Str)
        returns int
        is native('libgit2')
        is symbol('git_signature_now') { ... };

    method now($name, $email) {
        my $sig = &-in-c GitSignature.new();

        call-with-error(&sig-now, [$sig, $name, $email]);

        self.bless(sig => *-in-c $sig);
    }

    sub free-sig(CArray[GitSignature])
        is native('libgit2')
        is symbol('git_signature_free') { ... };

    sub duplicate-sig(CArray[GitSignature], GitSignature)
        returns int
        is native('libgit2')
        is symbol('git_signature_dup') { ... };

    sub new-sig(CArray[GitSignature], Str, Str, Int, int)
        returns int
        is native('libgit2')
        is symbol('git_signature_new') { ... };

    method new($name, $email, $time = now.to-posix[0].Int, $offset = 0) {
        my $sig = &-in-c GitSignature.new();

        call-with-error(&new-sig, [$sig, $name, $email, $time, $offset]);

        self.bless(sig => *-in-c $sig);
    }
}
