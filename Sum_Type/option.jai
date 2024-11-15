// This is meant for optional data, generally in structs only not to indicate state or errors.
// Do not use this as a procedure return type to indicate None left or so, use Result
Option :: struct ($T: Type) {
    using #as base: Sum_Type(
        .{"None", void},
        .{"Some", T},
    );
}
some :: (value: $V) -> Option(V) {
    opt : Option(V);
    set(*opt, Option(V).Some.{value});
    return opt;
}
none :: ($V: Type) -> Option(V) {
    opt : Option(V);
    set(*opt, Option(V).None.{});
    return opt;
}
is_some :: (option: Option($T)) -> bool {
    return option._tag == .Some;
}
is_none :: (option: Option($T)) -> bool {
    return option._tag == .None;
}
unwrap :: (option: Option($T)) -> *T {
    assert(option._tag == .Some, "Attempt to get value of a None Option");
    return cast(*T) *option._bytes.some;
}
unwrap_copy_or :: (option: Option($T), default: T) -> T { // TODO naming
    if(option._tag == .Some) return <<cast(*T) *option._bytes.some;
    return default;
}
