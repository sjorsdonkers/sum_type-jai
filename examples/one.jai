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

    opt : Option(u8);
    set(*opt, Option(u8).Some.{5});
    match(opt,
        (s: Option(u8).Some) { print("Some: %\n", s); },
        (n: Option(u8).None) { print("None\n"); },
    );

    out := oh_nose(false);
    match(out,
        (o: Result(s8, string).Ok)   { print("Ok: %\n", o); },
        (e: Result(s8, string).Else) { print("Else: %\n", e); },
    );
}
//NoseReturn :: Result(Option(s32), string); // Nested requires #insert,stallable. Or Option(s32) to have previously been generated
oh_nose :: (yes: bool) -> Result(s8, string) {
    Res :: Result(s8, string);
    output: Res;
    if yes { set(*output, Res.Ok.{8}); }
    else { set(*output, Res.Else.{"Oh nose!"}); }
    return output;
}


NU :: #import, file "../Named_Union.jai";
#poke_name NU MyStruct; // To avoid this I think we need $call := #caller_code and #insert,scope(call) to work on structs (Named_Union)
#import, file "../Named_Union.jai";
#import "Basic";
