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

#import, file "../Named_Union.jai";
