// Jai language support can improve:
// - The need to #poke_name of user-structs into the Sum_Type module.
//   To avoid this I think we need $call := #caller_code and #insert,scope(call) to work on structs (Sum_Type)
// - Nested Sum_Types requires stallable on #insert: #insert,stallable
// - Allow polymorphic Sum_Types. Since the Sum_Type already is polymorphic a using #as work around is required.
//   With language level support for Sum_Types for example Option would simplify to
//   Option :: sumtype (T: Type) {None :: void, Some :: T}
// - Type deduction for arguments similar to enums' dot notation.
//   match(opt,
//       (s: .Some) { print("Some: %\n", s); },
//       (n: .None) { print("None\n"); },
//   );
//   This would also enable single line initialization, usefull to return from a function or when calling a function
//   fruitsicle :MyFruit= .Pineapple.{5};
// - Backward flowing automatic type deduction would clean up a lot of the excessive type annotions
//   Typed arguments for `=>` procedures, would greatly enhance the match syntax:
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
// - Nested Sum_Types require the nested type to have been generated it in advance
// - Type-variants of Sum_Types and Sum_Types containing user-defined type-variants may not work yet
// - Tag is always 1 byte, don't make a Sum_Type with more than 255 variants..
// - Match currently just supports 1 return value

#load "option.jai";
#load "result.jai";

// Define a Sum_Type by providing the names and types of its variants.
// MyFruit :: Sum_Type (
//     .{"Pineapple", u8},
//     .{"Mango", string},
//     .{"Kiwi", MyStruct},
// );
Sum_Type :: struct ($variants: ..Variant) {
    #insert -> string {
        builder: String_Builder;

        // Pineapple :: struct { value: u8; }
        // Mango :: struct { value: string; }
        // Kiwi :: #type,distinct MyStruct;
        for variants {
            if (cast(*Type_Info)(it.type)).type == {
            case .STRUCT; print_to_builder(*builder, "% :: #type,distinct %;\n", it.name, it.type);
            case .VARIANT; assert(false, "VARIANT not supported yet in Sum_Type");
            case; print_to_builder(*builder, "% :: struct { value: %; }\n", it.name, it.type);
            }
        }

        // _value_types :: Type.[Pineapple, Mango, Kiwi];
        print_to_builder(*builder, "_value_types :: Type.[%", variants[0].name);
        for 1..variants.count-1 { print_to_builder(*builder, ", %", variants[it].name); }
        print_to_builder(*builder, "];\n");

        // _Bytes :: union {
        //     pineapple: Pineapple;
        //     mango: Mango;
        //     kiwi: Kiwi;
        // };
        print_to_builder(*builder, "_Bytes :: union {\n");
        for variants { print_to_builder(*builder, "    %: %;\n", to_lower_copy_new(it.name), it.name); }
        print_to_builder(*builder, "};\n");

        // _Tag :: enum u8 {
        //     PINEAPPLE :: 0;
        //     MANGO :: 1;
        //     KIWI :: 2;
        // }
        print_to_builder(*builder, "_Tag :: enum u8 {\n");
        for variants { print_to_builder(*builder, "    % :: %;\n", to_upper_copy_new(it.name), it_index); }
        print_to_builder(*builder, "}\n");

        return builder_to_string(*builder);
    }
    _bytes: _Bytes;
    _tag: _Tag; // '_tag' tells us the type of the value contained in '_bytes'
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
    target_tag :: #run union_index(u._value_types, T);
    u._tag = target_tag;
    pointer := cast(*T) *u._bytes;
    <<pointer = value;
}

// isa(u, T): Does the Sum_Type 'u' hold a value of type 'T'?
isa :: (u: Sum_Type, $T: Type) -> *T {
    // If the tag is T, return appropriately casted memory.
    // Otherwise, return null.
    // This is equivalent to true or false if used in an 'if' statement.
    expected_tag :: #run union_index(u._value_types, T);
    if u._tag == expected_tag  return cast(*T) *u._bytes;
    return null;
}

union_index :: ($types: []Type, $T: Type) -> u8 {
    found, index := array_find(types, T);
    assert(found, "Type % is not one of the possible types: %", T, types);
    return cast(u8) index;
}

union_type :: (u: Sum_Type) -> Type {
    return u._value_types[u._tag];
}

// Example usage:
// match(fruitsicle,
//     (p: MyFruit.Pineapple) { print("My pina, %\n", p); },
//     (m: MyFruit.Mango)     { print("My ango, %\n", m); },
//     (k: MyFruit.Kiwi)      { print("My iwi,  %\n", k); },
// );
match :: (u: $U/Sum_Type, case_procs: ..Any, $Returns:Type=void) -> Returns { // TODO find a better type than Any for the proc pointers
    u_info := cast(*Type_Info) union_type(u);
    expected_returns :: cast(u8)(Returns!=void);
    for case_proc: case_procs {
        assert(case_proc.type.type == .PROCEDURE, "Case procedure must be a procedure");
        proc_info := cast(*Type_Info_Procedure)(case_proc.type);
        assert(proc_info.argument_types.count == 1, "Case procedure without captures must have 1 argument"); // TODO 0 for default case
        assert(proc_info.return_types.count == expected_returns, "Case procedure is expected to have % return values, got %", expected_returns, proc_info.return_types.count); // TODO print variant name

        if u_info == proc_info.argument_types[0] {
            proc := <<cast(*#type (u._Bytes)->Returns) case_proc.value_pointer;
            return proc(u._bytes);
        }
    }
    ret: Returns;
    return ret;
}
match :: (u: $U/Sum_Type, case_procs: ..Any, $Returns:Type=void, capture: $Env) -> Returns { // TODO find a better type than Any for the proc pointers
    u_info := cast(*Type_Info) union_type(u);
    expected_returns :: cast(u8)(Returns!=void);
    for case_proc: case_procs {
        assert(case_proc.type.type == .PROCEDURE, "case_proc must be a procedure");
        proc_info := cast(*Type_Info_Procedure)(case_proc.type);
        assert(proc_info.argument_types.count == 2, "case_proc with captures must have 2 arguments"); // TODO 0 for default case
        assert(proc_info.return_types.count == expected_returns, "Case procedure is expected to have % return values, got %", expected_returns, proc_info.return_types.count); // TODO print variant name

        if u_info == proc_info.argument_types[0] {
            proc := <<cast(*#type (u._Bytes, Env)->Returns) case_proc.value_pointer;
            return proc(u._bytes, capture);
        }
    }
    ret: Returns;
    return ret;
}

#scope_file

#import "Basic";
#import "String";
