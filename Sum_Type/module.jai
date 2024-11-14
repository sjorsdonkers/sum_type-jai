// Jai language support can improve:
// - The need to #poke_name of user-structs into the Sum_Type module.
//   To avoid this I think we need $call := #caller_code and #insert,scope(call) to work on structs (Sum_Type)
// - Nested Sum_Types requires stallable on #insert: #insert,stallable
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


// LIMITATIONS:
// - Matching on a pointer to wrapped value is not supported yet
// - Nested Sum_Types require the nested type to have been generated it in advance
// - Tag is always 1 byte, don't make a Sum_Type with more than 256 variants..
// - Match procedure currently just supports 1 return value
// - Currently it is not possible yet to define a default procedure for match
// - Type checks are debug asserts at the moment, is there a good way to crash in release?
//   TODO unwrap_unchecked(..)
// - Correctness checks of the match statement are limited and mostly runtime
// - Sum_Type variants may not be called the same as any of the types or as primitives (all names have this limitation, enums structs,..)

#load "option.jai";
#load "result.jai";

// Define a Sum_Type by providing the names and types of its variants.
// MyFruit :: Sum_Type (
//     .{"Pineapple", u8},
//     .{"Mango", string},
//     .{"Kiwi", MyStruct},
// );
// NOTE: member names are prefixed with an underscore to avoid name collisions
Sum_Type :: struct ($_variants: ..Variant) {
    #insert #run,stallable -> string { // Does stallable help here?
        builder: String_Builder;

        for _variants {
            type_txt := tprint("%", it.type);
            assert(!ends_with(type_txt, "=)"), "Sum_Type variant `%` has a variadic parameter, this is not supported.\nDefine a new name with ` #type,isa` or `using #as` and poke the name into Sum_Type.", it.name);
            assert(type_txt != "(null)", "Polymorph not resolved the type for `%` before Sum_Type generation, use #run on the type. Like: `.{\"Mango\", #run Option(string)},`", it.name);
            for other: _variants {
                assert(type_txt != it.name, "Sum_Type name `%` may not be a type", type_txt);
            }
        }

        // Pineapple :: struct { value: u8; }
        // Mango :: struct { value: string; }
        // Kiwi :: struct { value: MyStruct; }
        for _variants { print_to_builder(*builder, "%1 :: struct { value: %2; } // Hint: `#poke_name ST %2` if type is undeclared \n", it.name, it.type); }

        // _value_types :: Type.[Pineapple, Mango, Kiwi]; // TODO Remove when possible
        // _value_types is the same as _variants, but using a native type which allows us to process them at compile-time (bug reported)
        print_to_builder(*builder, "_value_types :: Type.[%", _variants[0].name);
        for 1.._variants.count-1 { print_to_builder(*builder, ", %", _variants[it].name); }
        print_to_builder(*builder, "];\n");

        // _Bytes :: union {
        //     pineapple: Pineapple;
        //     mango: Mango;
        //     kiwi: Kiwi;
        // };
        print_to_builder(*builder, "_Bytes :: union {\n");
        for _variants { print_to_builder(*builder, "    %: %;\n", to_lower_copy_new(it.name), it.name); }
        print_to_builder(*builder, "};\n");

        // _Tag :: enum u8 {
        //     Pineapple :: 0;
        //     Mango :: 1;
        //     Kiwi :: 2;
        // }
        print_to_builder(*builder, "_Tag :: enum u8 {\n");
        for _variants { print_to_builder(*builder, "    % :: %;\n", it.name, it_index); }
        print_to_builder(*builder, "}\n");

        return builder_to_string(*builder);
    };
    _bytes: _Bytes;
    _tag:   _Tag; // '_tag' tells us the type of the value contained in '_bytes'
                  // It must be set to some index in '_value_types'
                  // It is an enum to make as it prints nices and #complete can be used on a switch statement
                  // TODO dynamically make u8 bigger if needed
}
// Helper struct to define the variants of a Sum_Type
Variant :: struct {
    name: string;
    type: Type;
}

// set(*u, value): Set the type tag of 'u' to type_of(value), and copy 'value' into u's storage.
set :: (u: *Sum_Type, value: $T) {
    target_tag :: #run index_of_type(u._value_types, T);
    u._tag = target_tag;
    pointer := cast(*T) *u._bytes;
    <<pointer = value;
}

// unwrap(u, T): Returns a pointer to the value stored in 'u' if it is of type 'T'.
// Crashes if 'u' is not of type 'T'. (TODO)
unwrap :: (u: Sum_Type, $T: Type) -> *T {
    expected_tag :: #run index_of_type(u._value_types, T);
    assert(u._tag == expected_tag, "Attempt to get value of a % Sum_Type with a % tag", T, u._tag);
    return cast(*T) *u._bytes;
}

current_type :: (u: Sum_Type) -> Type {
    return u._value_types[u._tag];
}

// Example usage:
// match(fruitsicle,
//     (p: MyFruit.Pineapple) { print("Basic match Pineapple: %\n", p); },
//     (m: MyFruit.Mango)     { print("Basic match Mango: %\n",     m); },
//     (k: MyFruit.Kiwi)      { print("Basic match Kiwi:  %\n",     k); },
// );
//
// The match procedure is just syntax sugar for the same code below
// Additionally match is able to prevent certain bugs
// if #complete fruitsicle._tag == {    // if current_type(fruitsicle) == is possible, but does not allow #complete
// case .Pineapple;
//     fruit := unwrap(fruitsicle, MyFruit.Pineapple);
//     print("Case Pineapple: %\n", <<fruit);
// case .Mango;
//     fruit := unwrap(fruitsicle, MyFruit.Mango);
//     print("Case Mango: %\n", <<fruit);
// case .Kiwi;
//     fruit := unwrap(fruitsicle, MyFruit.Kiwi);
//     print("Case Kiwi: %\n", <<fruit);
// }
match :: (u: $U/Sum_Type, case_procs: ..Any, $Returns:Type=void) -> Returns {
    v :void; // Is there a better inline way to make a void values than (){}()?
    return match(u, ..case_procs, Returns=Returns, capture=v);
}
// TODO find a better type than Any for the proc pointers,
// probably Code so case_procs can be compile-time, but then need to modify the argument types to be from the outer scope
// See https://github.com/sjorsdonkers/sum_type-jai/blob/ec4b0f6ca08a8f65ff0a56517db6a545ecebcd3f/Sum_Type/module.jai#L177
match :: (u: $U/Sum_Type, case_procs: ..Any, $Returns:Type=void, capture: $Env) -> Returns {
    expected_args    :: 1 + cast(u8)(Env != void);
    expected_returns :: cast(u8)(Returns != void);

    u_info := cast(*Type_Info) current_type(u);
    for case_proc: case_procs {
        assert(case_proc.type.type == .PROCEDURE, "Case procedure must be a procedure");
        proc_info := cast(*Type_Info_Procedure)(case_proc.type);
        assert(proc_info.argument_types.count == expected_args, "Case procedure with captures must have % arguments", expected_args); // TODO 0 for default case
        assert(proc_info.return_types.count == expected_returns, "Case procedure is expected to have % return values, got %", expected_returns, proc_info.return_types.count); // TODO print variant name

        if u_info == proc_info.argument_types[0] {
            #if expected_args == 2 {
                proc := <<cast(*#type (u._Bytes, Env)->Returns) case_proc.value_pointer;
                return proc(u._bytes, capture);
            } else {
                proc := <<cast(*#type (u._Bytes)->Returns) case_proc.value_pointer;
                return proc(u._bytes);
            }
        }
    }
    ret: Returns;
    return ret;
}

#scope_file

index_of_type :: ($types: []Type, $T: Type) -> u8 {
    found, index := array_find(types, T);
    assert(found, "Type % is not one of the possible types: %", T, types);
    return cast(u8) index;
}

#import "Basic";
#import "String";
