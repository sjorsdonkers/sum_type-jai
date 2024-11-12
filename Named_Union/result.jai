// Meant as function return type to indicate Ok success or Other (error, end of something etc.)
Result :: struct (Ok: Type, Other: Type) {
    using #as result: Named_Union(
        .{"Other", Other},
        .{"Ok", Ok},
    );
}
ok :: (value: $Ok, $Other: Type) -> Result(Ok, Other) {
    res : Result(Ok, Other);
    set(*res, Result(Ok, Other).Ok.{value});
    return res;
}
other :: ($Ok: Type, value: $Other) -> Result(Ok, Other) {
    res : Result(Ok, Other);
    set(*res, Result(Ok, Other).Other.{value});
    return res;
}
is_ok :: (result: Result($Ok, $Other)) -> bool {
    return result.tag == .OK;
}
is_other :: (result: Result($Ok, $Other)) -> bool {
    return result.tag == .OTHER;
}
unwrap :: (result: Result($Ok, $Other)) -> *Ok {
    assert(result.tag == result.Tag.OK, "Attempt to get Ok value of a Other Result");
    return cast(*T) *result.bytes._ok;
}
unwrap_other :: (result: Result($Ok, $Other)) -> *Other {
    assert(result.tag == result.Tag.OTHER, "Attempt to get Other value of a Ok Result");
    return cast(*T) *result.bytes._other;
}
