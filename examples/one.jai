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
    fruitsicle : MyFruit;
    set(*fruitsicle, MyFruit.Pineapple.{5});
    pinapple := isa(fruitsicle, MyFruit.Pineapple);
    pinapple_type := union_type(fruitsicle);
    if pinapple { print("fruitsicle: % as %.%\n", fruitsicle, pinapple_type, << pinapple); }

    set(*fruitsicle, MyFruit.Mango.{"Hello"});
    set(*fruitsicle, MyFruit.Kiwi.{34, true});
    match(fruitsicle,
        (p: MyFruit.Pineapple) { print("My pina, %\n", p); },
        (m: MyFruit.Mango)     { print("My ango, %\n", m); },
        (k: MyFruit.Kiwi)      { print("My iwi,  %\n", k); },
    );
}

NU :: #import, file "../Named_Union.jai";
#poke_name NU MyStruct; // To avoid this I think we need $call := #caller_code and #insert,scope(call) to work on structs (Named_Union)
#import, file "../Named_Union.jai";
#import "Basic";
