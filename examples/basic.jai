MyStruct :: struct {
    a: s32;
    b: bool;
}
main :: () {
    // Defining MyFruit type as a Sum_Type
    MyFruit :: Sum_Type (
        .{"Pineapple", u8},  // Pineapple :: u8
        .{"Mango", string},  // Mango :: string
        .{"Kiwi", MyStruct}, // Kiwi :: MyStruct
    );
    fruitsicle := sum_type(MyFruit, .Pineapple, cast(u8)5);

    // Manual switch statement
    if #complete fruitsicle._tag == {
    case .Pineapple;
        fruit := unwrap(fruitsicle, MyFruit.Pineapple);
        print("Case Pineapple: %\n", <<fruit);
    case .Mango;
        fruit := unwrap(fruitsicle, MyFruit.Mango);
        print("Case Mango: %\n", <<fruit);
    case .Kiwi;
        fruit := unwrap(fruitsicle, MyFruit.Kiwi);
        print("Case Kiwi: %\n", <<fruit);
    }

    // Basic match statement
    set(*fruitsicle, .Kiwi, MyStruct.{34, true});
    match(fruitsicle,
        (p: MyFruit.Pineapple) { print("Basic match Pineapple: %\n", p); },
        (m: MyFruit.Mango)     { print("Basic match Mango: %\n",     m); },
        (k: MyFruit.Kiwi)      { print("Basic match Kiwi: %\n",      k); },
    );

    // Basic match with default
    match(fruitsicle,
        (p: MyFruit.Pineapple) { print("Basic with default Pineapple: %\n",       p     ); },
        (f: MyFruit)           { print("Basic with default Not a Pineapple: %\n", f._tag); },
    );

    // Match with return value
    set(*fruitsicle, .Kiwi, MyStruct.{4, false});
    s := match(fruitsicle,
        (p: MyFruit.Pineapple) -> string { return tprint("Match with return Pineapple: %", p); },
        (m: MyFruit.Mango)     -> string { return tprint("Match with return Mango: %",     m); },
        (k: MyFruit.Kiwi)      -> string { return tprint("Match with return Kiwi: %",      k); },
        Returns=string
    );
    print("%\n", s);

    // Match with capture
    set(*fruitsicle, .Mango, "Hello");
    match(fruitsicle,
        (p: MyFruit.Pineapple, env:string) { print("WAS: `%`. NOW: `Match with capture Pineapple: %`\n", env, p); },
        (m: MyFruit.Mango,     env:string) { print("WAS: `%`. NOW: `Match with capture Mango: %`\n",     env, m); },
        (k: MyFruit.Kiwi,      env:string) { print("WAS: `%`. NOW: `Match with capture Kiwi: %`\n",      env, k); },
        capture=s
    );

    // Match with return value and capture
    set(*fruitsicle, .Mango, "Sailor");
    t := match(fruitsicle,
        (p: MyFruit.Pineapple, env:string) -> string { return tprint("WAS: `%`. NOW: `Match with return & capture Pineapple: %`", env, p); },
        (m: MyFruit.Mango,     env:string) -> string { return tprint("WAS: `%`. NOW: `Match with return & capture Mango: %`",     env, m); },
        (k: MyFruit.Kiwi,      env:string) -> string { return tprint("WAS: `%`. NOW: `Match with return & capture Kiwi: %`",      env, k); },
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
    out := level_1(false);
    match(out,
        (o: Result(s8, string).Ok)    { print("Ok: %\n",    o); },
        (e: Result(s8, string).Other) { print("Other: %\n", e); },
    );
}

level_1 :: (yes: bool) -> Result(s8, string) {
    val := q(level_2(yes)); // q() returns from this procedure or unwraps the result
    return ok(val + 9, string);
}

level_2 :: (yes: bool) -> Result(s8, string) {
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
