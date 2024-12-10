// Jai language support can improve:
// - The need to #poke_name of user-structs into the Sum_Type module.
//   To avoid this I think(?) we need $call := #caller_code and #insert,scope(call) to work on structs (Sum_Type)
// - Allow polymorphic type-variants. Since the Sum_Type already is polymorphic a using #as work around is required.
//   With language level support for Sum_Types for example Option would simplify to
//   Option :: sumtype (T: Type) {None :: void, Some :: T} // Native sum-type support enables compile-time usage.
//   Or with polymorphic type-variants:
//   Option :: #type,isa ($T: Type) Sum_Type(.{"None", void},.{"Some", T})
// - Type deduction for arguments similar to enums' dot notation.
//   match(opt,
//       (s: .Some) { print("Some: %\n", s); },     // NOW (s: Option(s64).Some)
//       (n: .None) { print("None\n"); },           // NOW (n: Option(s64).None)
//   );
//   This would also enable single line initialization, usefull to return from a function or when calling a function
//   fruitsicle :MyFruit= .Pineapple.{5};
// - Backward flowing automatic type deduction would clean up a lot of the excessive type annotions
// - Typed arguments for `=>` procedures, would greatly enhance the match syntax:
//   Now:
//   s := match(fruitsicle,
//       (k: MyFruit.Kiwi) -> string { return tprint("My iwi,  %", k); },
//       Returns=string
//   );
//   With Typed arguments for `=>` procedures
//   s := match(fruitsicle,
//       (k: MyFruit.Kiwi) => tprint("My iwi,  %", k),
//       Returns=string
//   );
// - Would be nice if #modify can take compile-time bakeable arguments as input to determine the return type
//   unwrap :: (u: $ST/Sum_Type, $tag: ST._Tag) -> *$R #modify{
//       R = type_of(ST._value_types[tag].value); //  Error: #modify procs can only take arguments whose types are known *before* the polymorph occurs
//       return true;
//   }{..}


// LIMITATIONS:
// - Matching on a pointer to wrapped value is not supported yet
// - Nested Sum_Types require the nested type to have been generated it in advance with #run
// - Tag is always 1 byte, don't make a Sum_Type with more than 256 variants..
// - Match procedure currently just supports 1 return value
// - Type checks are debug asserts at the moment, should be compile-time. Also is there a good way to crash in release?
// - Sum_Type variants may not be called the same as any of the types or as primitives (all names have this limitation, enums structs,..)
// - It is not yet possible to make a sub-set or otherwise reusing existing variants.
// - Match does not yet check if the case type is actually a variant of the Sum_Type
// - Unwraps return by values to prevent pointers to temporaries, values tend to be small so maybe thats fine

#load "src/sum_type.jai";
#load "src/option.jai";
#load "src/result.jai";
