# Sum_Type

Sum-types and pattern matching for Jai using `Sum_Type` and `match`.  
Also includes `Option` and `Result` types.

Differences with `Tagged_Union`:
- Sum_Type creates new named type-variants for each item.  
This enables variants of the same types to be distinguished making it possible to model data correctly.
- In a Sum_Type the tag is stored as a single byte instead of a pointer.
- Pattern matching is implemented for Sum_Types using the `match` procedure.

Example showing a user-defined `Sum_Type`:
```jai
main :: () {
    MyFruit :: Sum_Type (
        .{"Pineapple", u8},
        .{"Mango", string},
        .{"Kiwi", MyStruct},
    );

    fruitsicle := sum_type(MyFruit, .Pineapple, cast(u8)5);
    set(*fruitsicle, .Mango, "Hello");
    set(*fruitsicle, .Kiwi, MyStruct.{34, true});

    match(fruitsicle,
        (p: MyFruit.Pineapple) { print("Basic match Pineapple: %\n", p); },
        (m: MyFruit.Mango)     { print("Basic match Mango: %\n",     m); },
        (k: MyFruit.Kiwi)      { print("Basic match Kiwi: %\n",      k); },
    );
}
MyStruct :: struct {
    a: s32;
    b: bool;
}
using NU :: #import "Sum_Type";
#poke_name NU MyStruct;
#import "Basic";
```

Example showing `Option`:
```jai
opt := some(5);
if is_some(opt) {
    print("Some: %\n", unwrap(opt));
} else {
    print("None\n");
}
```

Example showing `Result`:
```jai
level_2 :: (yes: bool) -> Result(s8, string) {
    if yes {
        return ok(cast(s8) 8, string); // Creates an Ok Result
    }
    return other(s8, "Oh nose!");      // Creates an Other Result
}
level_1 :: (yes: bool) -> Result(s8, string) {
    val := q(level_2(yes)); // q() returns from this procedure or unwraps the result
    return ok(val + 9, string);
}

out := level_1(false);
match(out,
    (o: Result(s8, string).Ok)    { print("Ok: %\n",    o); },
    (e: Result(s8, string).Other) { print("Other: %\n", e); },
);
```
