# Named_Union-jai

Sum-types and pattern matching for Jai.  
Also includes `Option` and `Result` types.

Differences with `Tagged_Union`:
- Named_Union creates new named type-variants for each item.  
This enables variants of the same types to be distinguished making it possible to model data correctly.
- In a Named_Union the tag is stored as a single byte instead of a pointer.
- Pattern matching is implemented for Named_Unions using the `match` procedure.


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
NU :: #import, file "../Named_Union.jai";
#poke_name NU MyStruct;
#import, file "../Named_Union.jai";
#import "Basic";
```
