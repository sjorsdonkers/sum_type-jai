MyStruct :: struct {
    a: s32;
    b: bool;
}
MyFruit :: NU.Named_Union (
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
        .{MyFruit.Pineapple, my_func},
        .{MyFruit.Mango, my_func},
        .{MyFruit.Kiwi, my_func},
    );
}

my_func :: (asd: Any) {
    print("Hello from my_func, %\n", asd);
}

Casu :: struct {
    tag: Type;
    body: (Any) -> ();
}

match :: (u: MyFruit, cases: ..Casu) {
    type := NU.union_type(u);

    for cases {
        if type == it.tag {
            if type == {
            case MyFruit.Pineapple; val := NU.isa(u, MyFruit.Pineapple); it.body(<<val);
            case MyFruit.Mango; val := NU.isa(u, MyFruit.Mango); it.body(<<val);
            case MyFruit.Kiwi; val := NU.isa(u, MyFruit.Kiwi); it.body(<<val);
            }
            return;
        }
    }
}

NU :: #import, file "../Named_Union.jai";
#poke_name NU MyStruct;
#import "Basic";
