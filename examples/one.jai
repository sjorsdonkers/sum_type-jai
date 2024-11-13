MyStruct :: struct {
    a: s32;
    b: bool;
}
main :: () {
    // Defining MyFruit as a Sum_Type
    MyFruit :: Sum_Type (
        .{"Pineapple", u8},  // Pineapple :: u8
        .{"Mango", string},  // Mango :: string
        .{"Kiwi", MyStruct}, // Kiwi :: MyStruct
    );
    fruitsicle : MyFruit;
    set(*fruitsicle, MyFruit.Pineapple.{5});
    pinapple := isa(fruitsicle, MyFruit.Pineapple);
    pinapple_type := union_type(fruitsicle);
    if pinapple { print("fruitsicle: % as %.%\n", fruitsicle, pinapple_type, << pinapple); }

    // Basic match statement
    set(*fruitsicle, MyFruit.Kiwi.{34, true});
    match(fruitsicle,
        (p: MyFruit.Pineapple) { print("My pina, %\n", p); },
        (m: MyFruit.Mango) { print("My ango, %\n", m); },
        (k: MyFruit.Kiwi) { print("My iwi,  %\n", k); },
    );

    // Match with return value
    set(*fruitsicle, MyFruit.Kiwi.{4, false});
    s := match(fruitsicle,
        (p: MyFruit.Pineapple) -> string { return tprint("My pina, %", p); },
        (m: MyFruit.Mango) -> string { return tprint("My ango, %", m); },
        (k: MyFruit.Kiwi) -> string { return tprint("My iwi,  %", k); },
        Returns=string
    );
    print("%\n", s);

    // Match with capture
    set(*fruitsicle, MyFruit.Mango.{"Hello"});
    match(fruitsicle,
        (p: MyFruit.Pineapple, env:string) { print("WAS: `%`. NOW: `My pina, %`\n", env, p); },
        (m: MyFruit.Mango,     env:string) { print("WAS: `%`. NOW: `My ango, %`\n", env, m); },
        (k: MyFruit.Kiwi,      env:string) { print("WAS: `%`. NOW: `My iwi,  %`\n", env, k); },
        capture=s
    );

    // Match with return value and capture
    set(*fruitsicle, MyFruit.Mango.{"Sailor"});
    t := match(fruitsicle,
        (p: MyFruit.Pineapple, env:string) -> string { return tprint("WAS: `%`. NOW: `My pina, %`", env, p); },
        (m: MyFruit.Mango,     env:string) -> string { return tprint("WAS: `%`. NOW: `My ango, %`", env, m); },
        (k: MyFruit.Kiwi,      env:string) -> string { return tprint("WAS: `%`. NOW: `My iwi,  %`", env, k); },
        capture=s, Returns=string
    );
    print("%\n", t);

    // Option
    opt :Option(s64)= some(5);
    if is_some(opt) {
        print("Some: %\n", <<unwrap(opt));
    } else {
        print("None\n");
    }

    // Result
    out := oh_nose(false);
    match(out,
        (o: Result(s8, string).Ok)   { print("Ok: %\n", o); },
        (e: Result(s8, string).Other) { print("Other: %\n", e); },
    );
}

oh_nose :: (yes: bool) -> Result(s8, string) {
    if yes {
        return ok(cast(s8) 8, string);
    }
    return other(s8, "Oh nose!");
}

//NestedUnion :: Result(Option(s32), string); // Nested requires #insert,stallable. Or Option(s32) to have previously been generated

NU :: #import, file "../Sum_Type/module.jai";
#poke_name NU MyStruct; // To avoid this I think we need $call := #caller_code and #insert,scope(call) to work on structs (Sum_Type)
#import, file "../Sum_Type/module.jai";
#import "Basic";
