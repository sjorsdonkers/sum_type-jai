// Meant as function return type to indicate Ok success or Other (error, end of something etc.)
// NOTE: This is probably not the best way to handle failure and buble up errors in this language.
// Especially as adding contextual information is noisy in the code even with helper functions.
// Likely a defaulted true success return value, a q() alternative that works with that
// and contextually information in the context (contstucted on failure) is better.
Result :: struct ($Ok: Type, $Other: Type) {
    using #as base: Sum_Type(
        .{"Other", Other},
        .{"Ok", Ok},
    );
}
ok :: (value: $Ok, $Other: Type) -> Result(Ok, Other) {
    return sum_type(Result(Ok, Other), .Ok, value);
}
other :: ($Ok: Type, value: $Other) -> Result(Ok, Other) {
    return sum_type(Result(Ok, Other), .Other, value);
}
is_ok :: (result: Result) -> bool {
    return result._tag == .Ok;
}
is_other :: (result: Result) -> bool {
    return result._tag == .Other;
}
unwrap :: (result: Result($Ok, $Other)) -> Ok {
    assert(result._tag == .Ok, "Attempt to get Ok value of a Other Result");
    return xx result._bytes.ok;
}
unwrap :: (result: Result, $Ok: Type) -> Ok {
    assert(result._tag == .Ok, "Attempt to get Ok value of a Other Result");
    return xx result._bytes.ok;
}
unwrap_other :: (result: Result($Ok, $Other)) -> Other {
    assert(result._tag == .Other, "Attempt to get Other value of a Ok Result");
    return xx result._bytes.other;
}
unwrap_other :: (result: Result, $Other: Type) -> Other {
    assert(result._tag == .Other, "Attempt to get Other value of a Ok Result");
    return xx result._bytes.other;
}

// proc :: () -> Result(s8, string) {
//     result := other(s8, "Oh nose!");  // Creates a Result with an Other
//     unwrapped := q(result);           // q() returns from this procedure or unwraps the result
//     return ok(unwrapped + 9, string); // This will not be reached since result is an Other
// }
q :: (result: Result($Ok, $Other)) -> Ok #expand {
    if is_other(result) { `return result; }
    return <<unwrap(result);
}
// Outer_Ok is needed if the current Ok type is different from the procedures Ok type
// Other types are expected to match, if not a `map_other` procedure is needed
// proc :: () -> Result(s32, string) {
//     val :s8= q(level_2(yes), s32);    // q() returns an s8, but the proc returns an s32
//     return ok(cast(s32)(val + 9), string);
// }
q :: (result: Result($Ok, $Other), $Outer_Ok :Type) -> Ok #expand { // Can we deduce Outer_Ok somehow?
    if is_other(result) {
        #if Outer_Ok == Ok { `return result; }
        `return other(Outer_Ok, unwrap_other(result));
    }
    return unwrap(result);
}
