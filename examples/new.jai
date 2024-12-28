MyStruct :: struct {
    a: s32;
    b: bool;
}
main :: () {
    MyFruit :: struct {
        Sum_Type (
            #code pineapple: u8,
            #code mango: string,
            #code kiwi: MyStruct,
        );
    }
}

using NU :: #import, file "../module.jai";
#poke_name NU MyStruct; // To avoid this I think we need $call := #caller_code and #insert,scope(call) to work on structs (Sum_Type)
#import "Basic";
