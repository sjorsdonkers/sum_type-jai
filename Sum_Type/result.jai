// Meant as function return type to indicate Ok success or Other (error, end of something etc.)
Result :: struct ($Ok: Type, $Other: Type) {
    using #as base: Sum_Type(
        .{"Other", Other},
        .{"Ok", Ok},
    );
}
ok :: (value: $Ok, $Other: Type) -> Result(Ok, Other) {
    res : Result(Ok, Other);
    set(*res, .Ok, value);
    return res;
}
other :: ($Ok: Type, value: $Other) -> Result(Ok, Other) {
    res : Result(Ok, Other);
    set(*res, .Other, value);
    return res;
}
is_ok :: (result: Result($Ok, $Other)) -> bool {
    return result._tag == .Ok;
}
is_other :: (result: Result($Ok, $Other)) -> bool {
    return result._tag == .Other;
}
unwrap :: (result: Result($Ok, $Other)) -> *Ok {
    assert(result._tag == .Ok, "Attempt to get Ok value of a Other Result");
    return cast(*Ok) *result._bytes.ok;
}
unwrap_other :: (result: Result($Ok, $Other)) -> *Other {
    assert(result._tag == .Other, "Attempt to get Other value of a Ok Result");
    return cast(*Other) *result._bytes.other;
}

// proc :: () -> Result(s8, string) {
//     result := other(s8, "Oh nose!");  // Creates a Result with an Other
//     unwrapped := q(result);           // q() returns from this procedure or unwraps the result
//     return ok(unwrapped + 9, string); // This will not be reached if result is an Other
// }
q :: (result: Result($Ok, $Other)) -> Ok #expand { // TODO can we detect wheter result is an L or R value?
    if is_other(result) `return result;
    return <<unwrap(result);
}
