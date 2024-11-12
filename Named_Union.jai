Variant :: struct {
    name: string;
    type: Type;
}

Named_Union :: struct ($variants: ..Variant) {
    #insert -> string {
        builder: String_Builder;

        // Pineapple :: struct { value: u8; }
        // Mango :: struct { value: string; }
        // Kiwi :: #type,distinct MyStruct;
        for variants {
            if (cast(*Type_Info)(it.type)).type == {
            case .STRUCT; print_to_builder(*builder, "    % :: #type,distinct %;\n", it.name, it.type);
            case .VARIANT; assert(false, "VARIANT not supported yet in Named_Union");
            case; print_to_builder(*builder, "    % :: struct { value: %; }\n", it.name, it.type);
            }
        }

        // value_types :: Type.[Pineapple, Mango, Kiwi];
        print_to_builder(*builder, "    value_types :: Type.[%", variants[0].name);
        for 1..variants.count-1 { print_to_builder(*builder, ", %", variants[it].name); }
        print_to_builder(*builder, "];\n");

        // Bytes :: union {
        //     _pineapple: Pineapple;
        //     _mango: Mango;
        //     _kiwi: Kiwi;
        // };
        print_to_builder(*builder, "    Bytes :: union {\n"); // TODO prefix _
        for variants { print_to_builder(*builder, "        _%: %;\n", to_lower_copy_new(it.name), it.name); }
        print_to_builder(*builder, "    };\n");

        // Tag :: enum u8 {
        //     PINEAPPLE :: 0;
        //     MANGO :: 1;
        //     KIWI :: 2;
        // }
        print_to_builder(*builder, "    Tag :: enum u8 {\n");
        for variants { print_to_builder(*builder, "        % :: %;\n", to_upper_copy_new(it.name), it_index); }
        print_to_builder(*builder, "    }\n");

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

#scope_file

#import "Basic";
#import "String";
