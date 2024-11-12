MyStruct :: struct {
    a: s32;
    b: bool;
}
// :: #type,distinct MyStruct;
MyFruit :: #type NU.Named_Union (
    .{"Pineapple", u8},
    .{"Mango", string},
    .{"Kiwi", MyStruct},
);
main :: () {
    a : MyFruit;
    NU.set(*a, MyFruit.Pineapple.{5});
    pinapple := NU.isa(a, MyFruit.Pineapple);
    pinapple_type := NU.union_type(a);
    if pinapple {
        print("a: % as % is %\n", a, pinapple_type, << pinapple);
    }

    NU.set(*a, MyFruit.Mango.{"Hello"});
    mango := NU.isa(a, MyFruit.Mango);
    mango_type := NU.union_type(a);
    if mango {
        print("a: % as % is %\n", a, mango_type, << mango);
    }

    NU.set(*a, MyFruit.Kiwi.{34, true});
    kiwi := NU.isa(a, MyFruit.Kiwi);
    kiwi_type := NU.union_type(a);
    if kiwi {
        print("a: % as % is %\n", a, kiwi_type, << kiwi);
    }

    match(a,
        .{MyFruit.Pineapple, (asd: Any) { print("My pina, %\n", asd); }},
        .{MyFruit.Mango, (asd: Any) { print("My ango, %\n", asd); }},
        .{MyFruit.Kiwi, (asd: Any) { print("My iwi, %\n", asd); }},
    );
}

Casu :: struct {
    tag: Type;
    body: (Any) -> ();
}

match :: (u: $U/NU.Named_Union, cases: ..Casu) {
    type := NU.union_type(u);
    body : (Any) -> ();
    for cases if type == it.tag body = it.body;
    #insert -> string {
        builder: String_Builder;

        info := type_info(U);
        // if type == {
        // case MyFruit.Pineapple; val := NU.isa(u, MyFruit.Pineapple); it.body(<<val);
        // case MyFruit.Mango; val := NU.isa(u, MyFruit.Mango); it.body(<<val);
        // case MyFruit.Kiwi; val := NU.isa(u, MyFruit.Kiwi); it.body(<<val);
        // }
        print_to_builder(*builder, "    if type == {\n");
        for info.members {
            if !(it.flags & .CONSTANT) || it.name ==  "Bytes" || it.name ==  "Tag" || it.name ==  "value_types" continue;
            print_to_builder(*builder, "    case u.%1; val := NU.isa(u, u.%1); body(<<val);\n", it.name);
        }
        print_to_builder(*builder, "    }\n");

        return builder_to_string(*builder);
    }
}

NU :: #import, file "../Named_Union.jai";
#poke_name NU MyStruct;
#import "Basic";
