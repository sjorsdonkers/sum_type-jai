MyStruct :: struct {
    a: s32;
    b: bool;
}
MyMeat :: struct {
    using #as meat: Sum_Type(
        .{"Salami", MyStruct},
        .{"MyStruct", s32},
    );
}
MyBread :: #type,isa Sum_Type (
    .{"Baguette", u8},
    .{"Croissant", string},
    .{"Pan_De_Sal", #run Option(MyStruct)},
);
MyFruit :: Sum_Type (
    .{"Pineapple", u8},
    .{"Mango", #run Option(string)},
    .{"Kiwi", MyStruct},
);
main :: () {

    // Meat.Salami.{.{3}};
    MyFood :: #type,isa Sum_Type (
        .{"Bread", #run MyBread},
        .{"Fruit", #run MyFruit},
        .{"Meat", MyMeat},
    );
    foodsicle : MyFood;

    // Match with return value and capture
    // set(*fruitsicle, MyFruit.Mango.{"Sailor"});
    // t := match(fruitsicle,
    //     (p: MyFruit.Pineapple, env:string) -> string { return tprint("WAS: `%`. NOW: `Match with return & capture Pineapple: %`", env, p); },
    //     (m: MyFruit.Mango,     env:string) -> string { return tprint("WAS: `%`. NOW: `Match with return & capture Mango: %`",     env, m); },
    //     (k: MyFruit.Kiwi,      env:string) -> string { return tprint("WAS: `%`. NOW: `Match with return & capture Kiwi:  %`",     env, k); },
    //     capture=s, Returns=string
    // );
    // print("%\n", t);

}

ST :: #import, file "../Sum_Type/module.jai";
#poke_name ST MyStruct; // To avoid this I think we need $call := #caller_code and #insert,scope(call) to work on structs (Sum_Type)
#poke_name ST MyMeat;
#poke_name ST MyBread;
#poke_name ST MyFruit;
#import, file "../Sum_Type/module.jai";
#import "Basic";
