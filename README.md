# Named_Union-jai
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
