// Jai language support can improve:
// - The need to #poke_name of user-structs into the Named_Union module.
//   To avoid this I think we need $call := #caller_code and #insert,scope(call) to work on structs (Named_Union)
// - Nested Named_Unions requires stallable on #insert: #insert,stallable
// - Allow polymorphic Named_Unions. Since the Named_Union already is polymorphic a using #as work around is required.
//   With language level support for Named_Unions for example Option would simplify to
//   Option :: nunion (T: Type) {None :: void, Some :: T}
// - Type deduction for arguments similar to enums' dot notation.
//   match(opt,
//       (s: .Some) { print("Some: %\n", s); },
//       (n: .None) { print("None\n"); },
//   );
// - Single line initialization would be nice, especially to return from a function or call a function
//   fruitsicle :MyFruit= .Pineapple.{5};

// LIMITATIONS:
// - Nested Named_unions require the nested type to have been generated it in advance
// - Type-variants of Named_unions and Named_unions containing user-defined type-variants may not work yet
// - Missing case procedures are only detected at compile time
// - Tag is always 1 byte, don't make a Named_Union with more than 255 variants..

// This is meant for optional data, generally in structs only not to indicate state or errors.
// Do not use this as a procedure return type to indicate None left or so, use Result
Option :: struct (T: Type) {
    using #as optional: Named_Union(
        .{"None", void},
        .{"Some", T},
    );
}

// Meant as function return type to indicate success or else (error, end of something etc.)
Result :: struct (Ok: Type, Else: Type) {
    using #as result: Named_Union(
        .{"Else", Else},
        .{"Ok", Ok},
    );
}

Variant :: struct {
    name: string;
    type: Type;
}

// Define a Named_Union by providing the names and types of its variants.
// MyFruit :: Named_Union (
//     .{"Pineapple", u8},
//     .{"Mango", string},
//     .{"Kiwi", MyStruct},
// );
Named_Union :: struct ($variants: ..Variant) {
    #insert -> string {
        builder: String_Builder;

        // Pineapple :: struct { value: u8; }
        // Mango :: struct { value: string; }
        // Kiwi :: #type,distinct MyStruct;
        for variants {
            if (cast(*Type_Info)(it.type)).type == {
            case .STRUCT; print_to_builder(*builder, "% :: #type,distinct %;\n", it.name, it.type);
            case .VARIANT; assert(false, "VARIANT not supported yet in Named_Union");
            case; print_to_builder(*builder, "% :: struct { value: %; }\n", it.name, it.type);
            }
        }

        // value_types :: Type.[Pineapple, Mango, Kiwi];
        print_to_builder(*builder, "value_types :: Type.[%", variants[0].name);
        for 1..variants.count-1 { print_to_builder(*builder, ", %", variants[it].name); }
        print_to_builder(*builder, "];\n");

        // Bytes :: union {
        //     _pineapple: Pineapple;
        //     _mango: Mango;
        //     _kiwi: Kiwi;
        // };
        print_to_builder(*builder, "Bytes :: union {\n"); // TODO prefix _
        for variants { print_to_builder(*builder, "    _%: %;\n", to_lower_copy_new(it.name), it.name); }
        print_to_builder(*builder, "};\n");

        // Tag :: enum u8 {
        //     PINEAPPLE :: 0;
        //     MANGO :: 1;
        //     KIWI :: 2;
        // }
        print_to_builder(*builder, "Tag :: enum u8 {\n");
        for variants { print_to_builder(*builder, "    % :: %;\n", to_upper_copy_new(it.name), it_index); }
        print_to_builder(*builder, "}\n");

        return builder_to_string(*builder);
    }
    bytes: Bytes;
    tag: Tag; // 'tag' tells us the type of the value contained in 'bytes'
              // It must be set to some index in 'value_types'
              // It is an enum to make as it prints nices and #complete can be used on a switch statement
              // TODO dynamically make u8 bigger if needed
}

// set(*u, value): Set the type tag of 'u' to type_of(value), and copy 'value' into u's storage.
set :: (u: *Named_Union, value: $T) {
    target_tag :: #run union_index(u.value_types, T);
    u.tag = target_tag;
    pointer := cast(*T) *u.bytes;
    <<pointer = value;
}

// isa(u, T): Does the tagged union 'u' hold a value of type 'T'?
isa :: (u: Named_Union, $T: Type) -> *T {
    // If the tag is T, return appropriately casted memory.
    // Otherwise, return null.
    // This is equivalent to true or false if used in an 'if' statement.
    expected_tag :: #run union_index(u.value_types, T);
    if u.tag == expected_tag  return cast(*T) *u.bytes;
    return null;
}

union_index :: ($types: []Type, $T: Type) -> u8 {
    found, index := array_find(types, T);
    assert(found, "Type % is not one of the possible types: %", T, types);
    return cast(u8) index;
}

union_type :: (u: Named_Union) -> Type {
    return u.value_types[u.tag];
}

// Example usage:
// match(fruitsicle,
//     (p: MyFruit.Pineapple) { print("My pina, %\n", p); },
//     (m: MyFruit.Mango)     { print("My ango, %\n", m); },
//     (k: MyFruit.Kiwi)      { print("My iwi,  %\n", k); },
// );
match :: (u: $U/Named_Union, case_procs: ..Any) { // TODO find a better type than Any for the proc pointers
    u_type := union_type(u);
    u_info := cast(*Type_Info) u_type;
    case_proc : Any;
    for case_procs {
        assert(it.type.type == .PROCEDURE, "case_proc must be a procedure");
        proc_info := cast(*Type_Info_Procedure)(it.type);
        assert(proc_info.argument_types.count == 1, "case_proc may only have one argument"); // TODO 0 for default case
        assert(proc_info.return_types.count == 0, "case_proc may not have a return value yet"); // TODO
        if u_info == proc_info.argument_types[0] { case_proc = it; break; }
    }
    assert(case_proc.value_pointer != null, "No matching case procedure found for type %", u_type);

    #insert -> string {
        builder: String_Builder;

        info := type_info(U);
        for info.members { // To make a polymorphic Named_Union, a user may define a struct with a member using #as Named_Union(..)
            if it.flags & .AS {
                assert(it.type.type == .STRUCT, "Named_Union must be a struct");
                info = cast(*Type_Info_Struct) it.type; // TODO handle .VARIANT
                assert(info.name == "Named_Union");
                break;
            }
        }

        // if u_type == {
        // case u.Pineapple; val := isa(u, u.Pineapple); proc := <<cast(*#type (u.Pineapple)->()) case_proc.value_pointer; proc(<<val);
        // case u.Mango;     val := isa(u, u.Mango);     proc := <<cast(*#type (u.Mango)->())     case_proc.value_pointer; proc(<<val);
        // case u.Kiwi;      val := isa(u, u.Kiwi);      proc := <<cast(*#type (u.Kiwi)->())      case_proc.value_pointer; proc(<<val);
        // }
        print_to_builder(*builder, "if u_type == {\n");
        for info.members {
            if !(it.flags & .CONSTANT) || it.name ==  "Bytes" || it.name ==  "Tag" || it.name ==  "value_types" continue;

            print_to_builder(*builder, "case u.%1;\n", it.name);
            print_to_builder(*builder, "    val := isa(u, u.%1);\n", it.name);
            print_to_builder(*builder, "    proc := <<cast(*#type (u.%1)->()) case_proc.value_pointer;\n", it.name);
            print_to_builder(*builder, "    proc(<<val);\n");
        }
        print_to_builder(*builder, "}\n");

        return builder_to_string(*builder);
    }
}

#scope_file

#import "Basic";
#import "String";
