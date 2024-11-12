MyStruct :: struct {
    a: s32;
    b: bool;
}
main :: () {
    MyFruit :: Named_Union (
        .{"Pineapple", u8},  // Pineapple :: u8
        .{"Mango", string},  // Mango :: string
        .{"Kiwi", MyStruct}, // Kiwi :: MyStruct
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

    opt :Option(s64)= some(5);
    if is_some(opt) { print("Some: %\n", <<unwrap(opt)); }
    else { print("None\n"); }

    out := oh_nose(false);
    match(out,
        (o: Result(s8, string).Ok)   { print("Ok: %\n", o); },
        (e: Result(s8, string).Other) { print("Other: %\n", e); },
    );
}
//NoseReturn :: Result(Option(s32), string); // Nested requires #insert,stallable. Or Option(s32) to have previously been generated
oh_nose :: (yes: bool) -> Result(s8, string) {
    if yes return ok(cast(s8) 8, string);
    return other(s8, "Oh nose!");
}


NU :: #import, file "../Named_Union/module.jai";
#poke_name NU MyStruct; // To avoid this I think we need $call := #caller_code and #insert,scope(call) to work on structs (Named_Union)
#import, file "../Named_Union/module.jai";
#import "Basic";
