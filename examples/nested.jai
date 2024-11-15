MyStruct :: struct {
    spaghetti: s32;
    macaroni: bool;
}
#poke_name ST MyStruct; // To avoid this I think(?) we need $call := #caller_code and #insert,scope(call) to work on structs (Sum_Type)
MyBread :: struct {
    using #as base: Sum_Type( // using #as since `#type,isa` does not expose .Baguette on the variant type MyBread. (using #as also enables the struct to be polymorphic)
        .{"Baguette", u8},
        .{"Croissant", string},
        .{"Pan_De_Sal", #run Option(MyStruct)}, // #run is needed to make sure the specifc Sum_Type is generated before this one
    );
}
#poke_name ST MyBread;
MyFruit :: struct {
    using #as base: Sum_Type (
        .{"Pineapple", u8},
        .{"Mango", #run Option(string)},
        .{"Kiwi", MyStruct},
    );
}
#poke_name ST MyFruit;

main :: () {
    MyFood :: Sum_Type (
        .{"Bread", #run MyBread},
        .{"Fruit", #run MyFruit},
    );

    bread := sum_type(MyBread, .Pan_De_Sal, some(MyStruct.{42, true}));
    food  := sum_type(MyFood, .Bread, bread);

    // Nested match
    t := match(food,
        (b: MyFood.Bread) -> u8 { return match(b.value,
            (b: MyBread.Baguette)   -> u8 {return b.value;},
            (c: MyBread.Croissant)  -> u8 {return cast(u8)c.value.count;},
            (p: MyBread.Pan_De_Sal) -> u8 {return cast(u8)ifx is_some(p.value) unwrap(p.value).spaghetti else 0;},
            Returns=u8
            ); },
        (f: MyFood.Fruit) -> u8 { return 9; },
        Returns=u8
    );
    print("%\n", t);

    // Manual switch statement equivalent
    t2 :u8= ---;
    if #complete food._tag == {
    case .Bread;
        b := unwrap(food, MyFood.Bread);
        if #complete b._tag == {
        case .Baguette;  t2 = <<unwrap(b, MyBread.Baguette);
        case .Croissant; t2 = cast(u8)unwrap(b, MyBread.Croissant).count;
        case .Pan_De_Sal;
            p := unwrap(b, MyBread.Pan_De_Sal);
            t2 = cast(u8)ifx is_some(p) unwrap(p).spaghetti else 0;
        }
    case .Fruit; t2 = 9;
    }
    print("%\n", t2);

    // Ideal match syntax with quick procedures
    // t := match(food,
    //     (b: .Bread) => match(b,
    //         (b: .Baguette)   => b,
    //         (c: .Croissant)  => cast(u8)c.count,
    //         (p: .Pan_De_Sal) => cast(u8)ifx is_some(p) unwrap(p).spaghetti else 0,
    //     ),
    //     (f: .Fruit) => cast(u8)9,
    // );
    // print("%\n", t);
}

ST :: #import, file "../Sum_Type/module.jai";
#import, file "../Sum_Type/module.jai";
#import "Basic";
