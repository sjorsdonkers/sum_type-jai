MyStruct :: struct {
    a: s32;
    b: bool;
}
main :: () {
    MyFruit :: Named_Union (
        .{"Pineapple", u8},
        .{"Mango", string},
        .{"Kiwi", MyStruct},
    );

    a : MyFruit;
    set(*a, MyFruit.Pineapple.{5});
    pinapple := isa(a, MyFruit.Pineapple);
    pinapple_type := union_type(a);
    if pinapple {
        print("a: % as % is %\n", a, pinapple_type, << pinapple);
    }

    set(*a, MyFruit.Mango.{"Hello"});
    mango := isa(a, MyFruit.Mango);
    mango_type := union_type(a);
    if mango {
        print("a: % as % is %\n", a, mango_type, << mango);
    }

    set(*a, MyFruit.Kiwi.{34, true});
    kiwi := isa(a, MyFruit.Kiwi);
    kiwi_type := union_type(a);
    if kiwi {
        print("a: % as % is %\n", a, kiwi_type, << kiwi);
    }
}

Tag :: struct {
    name: string;
    type: Type;
}

Named_Union :: struct ($tags: ..Tag) {
    #insert -> string {
        builder: String_Builder;

        // Pineapple :: struct { value: u8; }
        // Mango :: struct { value: string; }
        // Kiwi :: #type,distinct MyStruct;
        for tags {
            if (cast(*Type_Info)(it.type)).type == .STRUCT { // TODO handle VARIANT
                print_to_builder(*builder, "    % :: #type,distinct %;\n", it.name, it.type);
            } else {
                print_to_builder(*builder, "    % :: struct { value: %; }\n", it.name, it.type);
            }
        }

        // value_types :: Type.[Pineapple, Mango];
        print_to_builder(*builder, "    value_types :: Type.[%", tags[0].name);
        for 1..tags.count-1 { print_to_builder(*builder, ", %", tags[it].name); }
        print_to_builder(*builder, "];\n");

        // union {
        //     _pineapple: Pineapple;
        //     _mango: Mango;
        // };
        print_to_builder(*builder, "    bytes: union {\n");
        for tags { print_to_builder(*builder, "        _%: %;\n", to_lower_copy_new(it.name), it.name); }
        print_to_builder(*builder, "    };\n");

        return builder_to_string(*builder);
    }

    tag: u8; // 'tag' tells us the type of the value contained in 'bytes'.
             // It must be set to some index in 'value_types'.
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
