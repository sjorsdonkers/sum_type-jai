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
    #insert #run,stallable -> string { // Does stallable help here? Variant.type still is (null) sometimes
        builder: String_Builder;

        for _variants {
            type_txt := tprint("%", it.type);
            assert(!ends_with(type_txt, "=)"), "Sum_Type variant `%` has a variadic parameter, this is not supported.\nDefine a new name with `using #as` and poke the name into Sum_Type.", it.name);
            assert(type_txt != "(null)", "Polymorph not resolved the type for `%` before Sum_Type generation,\nuse #run on the type. Like: `.{\"Mango\", #run Option(string)},`", it.name);
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

// Construct a Sum_Type with a specific variant and value.
// fruitsicle := sum_type(MyFruit, .Pineapple, cast(u8)5);
sum_type :: ($ST: Type, $tag: ST._Tag, value: $V) -> ST {
    sum: ST; // Not setting ---, as user-struct may have more fields
    set(*sum, tag, value);
    return sum;
}

// Set the type tag of 'u' to type_of(value), and copy 'value' into u's storage.
// set(*fruitsicle, .Mango, "Hello");
set :: (u: *$ST/Sum_Type, $tag: ST._Tag, value: $V) {
    Variant_Type :: ST._value_types[tag];
    u._tag = tag;
    #if type_of(Variant_Type.value) != void {
        pointer := cast(*Variant_Type) *u._bytes;
        <<pointer = .{value};
    }
}

// unwrap(u, T): Returns a pointer to the value stored in the variant of 'u'.
// Crashes if 'u' is not of type 'T'. (TODO)
// mango := unwrap(fruitsicle, MyFruit.Mango);
unwrap :: (u: Sum_Type, $T: Type) -> type_of(T.value) {
    expected_tag :: #run index_of_type(u._value_types, T);
    assert(u._tag == expected_tag, "Attempt to get value of a % Sum_Type with a % tag", T, u._tag);
    return (cast(*T) *u._bytes).value;
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
// if #complete fruitsicle._tag == {
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
match :: (u: $U/Sum_Type, case_procs: ..Any, $Returns:Type=void, capture: $Env) -> Returns { // TODO consider #add_context instead of capture
    sum_info :: type_info(U);
    expected_args    :: 1 + cast(u8)(Env != void);
    expected_returns :: cast(u8)(Returns != void);

    default_proc : Any;
    variant_info := cast(*Type_Info) current_type(u);
    for case_proc: case_procs {
        // Checks
        assert(case_proc.type.type == .PROCEDURE, "Case procedure must be a procedure");
        proc_info := cast(*Type_Info_Procedure)(case_proc.type);
        assert(proc_info.argument_types.count == expected_args, "Case procedure with captures must have % arguments", expected_args); // TODO 0 for default case
        #if expected_args == 2 assert(proc_info.argument_types[1] == type_info(Env), "Case procedure capture argument type mismatch, expected %", Env);
        assert(proc_info.return_types.count == expected_returns, "Case procedure is expected to have % return values, got %", expected_returns, proc_info.return_types.count); // TODO print variant name
        #if expected_returns == 1 assert(proc_info.return_types[0] == type_info(Returns), "Case procedure return type mismatch, expected %", Returns);

        // Call, store default, or continue
        if proc_info.argument_types[0] == variant_info {
            return call(u._bytes, case_proc, Returns, capture);
        }else if proc_info.argument_types[0] == sum_info { // This is the default case, store it in case we can't find a better match
            assert(default_proc.value_pointer == null, "Multiple default case procedures found");
            default_proc = case_proc;
        }
    }
    if default_proc.value_pointer { return call(u._bytes, default_proc, Returns, capture); }
    assert(false, "No case matched for Sum_Type variant %", u._tag); // Do we care?
    ret: Returns;
    return ret;
}

#scope_file

call :: (bytes: $Bytes, case_proc: Any, $Returns:Type, capture: $Env) -> Returns {
    #if Env != void {
        proc := <<cast(*#type (Bytes, Env)->Returns) case_proc.value_pointer;
        return proc(bytes, capture);
    } else {
        proc := <<cast(*#type (Bytes)->Returns) case_proc.value_pointer;
        return proc(bytes);
    }
}

index_of_type :: ($types: []Type, $T: Type) -> u8 {
    found, index := array_find(types, T);
    assert(found, "Type % is not one of the possible types: %", T, types);
    return cast(u8) index;
}

current_type :: (u: Sum_Type) -> Type {
    return u._value_types[u._tag];
}

#import "Basic";
#import "String";
