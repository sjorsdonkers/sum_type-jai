// This is meant for optional data, generally in structs only, not to indicate state or errors.
// Do not use this as a procedure return type to indicate None left or so, use Result.
Option :: struct ($T: Type) {
    using #as base: Sum_Type(
        .{"None", void},
        .{"Some", T},
    );
}
some :: (value: $V) -> Option(V) {
    return sum_type(Option(V), .Some, value);
}
none :: ($V: Type) -> Option(V) {
    nope: void;
    return sum_type(Option(V), .None, nope);
}
is_some :: (option: Option($T)) -> bool {
    return option._tag == .Some;
}
is_none :: (option: Option($T)) -> bool {
    return option._tag == .None;
}
unwrap :: (option: Option($T)) -> T {
    assert(option._tag == .Some, "Attempt to get value of a None Option");
    return option._bytes.some.value;
}
unwrap_or :: (option: Option($T), default: T) -> T {
    if(option._tag == .Some) return option._bytes.some.value;
    return default;
}
