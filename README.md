# Named_Union-jai

Sum-types and pattern matching for Jai using `Named_Union` and `match`.  
Also includes `Option` and `Result` types.

Differences with `Tagged_Union`:
- Named_Union creates new named type-variants for each item.  
This enables variants of the same types to be distinguished making it possible to model data correctly.
- In a Named_Union the tag is stored as a single byte instead of a pointer.
- Pattern matching is implemented for Named_Unions using the `match` procedure.

Example showing `Option` and `Result` types:
```jai
main :: () {
    opt :Option(s64)= some(5);
    if is_some(opt) { print("Some: %\n", <<unwrap(opt)); }
    else { print("None\n"); }

    out :Result(s8, string)= oh_nose(false);
    match(out,
        (o: Result(s8, string).Ok)   { print("Ok: %\n", o); },
        (e: Result(s8, string).Other) { print("Other: %\n", e); },
    );
}

oh_nose :: (yes: bool) -> Result(s8, string) {
    if yes return ok(cast(s8) 3, string);
    return other(s8, "Oh nose!");
}

#import "Named_Union";
#import "Basic";
```

Example showing a user-defined `Named_Union`:
```jai
main :: () {
    MyFruit :: Named_Union (
        .{"Pineapple", u8},
        .{"Mango", string},
        .{"Kiwi", MyStruct},
    );

    fruitsicle : MyFruit;
    set(*fruitsicle, MyFruit.Pineapple.{5});
    set(*fruitsicle, MyFruit.Mango.{"Hello"});
    set(*fruitsicle, MyFruit.Kiwi.{34, true});

    match(fruitsicle,
        (p: MyFruit.Pineapple) { print("My pina, %\n", p); },
        (m: MyFruit.Mango)     { print("My ango, %\n", m); },
        (k: MyFruit.Kiwi)      { print("My iwi,  %\n", k); },
    );
}
MyStruct :: struct {
    a: s32;
    b: bool;
}
NU :: #import "Named_Union";
#poke_name NU MyStruct;
#import "Named_Union";
#import "Basic";
```
