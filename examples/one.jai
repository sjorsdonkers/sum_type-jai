MyStruct :: struct {
    a: s32;
    b: bool;
}
// :: #type,distinct MyStruct;
MyFruit :: #type NU.Named_Union (
    .{"Pineapple", u8},
    .{"Mango", string},
    .{"Kiwi", MyStruct},
);
main :: () {
    a : MyFruit;
    NU.set(*a, MyFruit.Pineapple.{5});
    pinapple := NU.isa(a, MyFruit.Pineapple);
    pinapple_type := NU.union_type(a);
    if pinapple {
        print("a: % as % is %\n", a, pinapple_type, << pinapple);
    }

    NU.set(*a, MyFruit.Mango.{"Hello"});
    mango := NU.isa(a, MyFruit.Mango);
    mango_type := NU.union_type(a);
    if mango {
        print("a: % as % is %\n", a, mango_type, << mango);
    }

    NU.set(*a, MyFruit.Kiwi.{34, true});
    kiwi := NU.isa(a, MyFruit.Kiwi);
    kiwi_type := NU.union_type(a);
    if kiwi {
        print("a: % as % is %\n", a, kiwi_type, << kiwi);
    }

    match(a,
        (p: MyFruit.Pineapple) { print("My pina, %\n", p); },
        (m: MyFruit.Mango)     { print("My ango, %\n", m); },
        (k: MyFruit.Kiwi)      { print("My iwi,  %\n", k); },
    );
}

match :: (u: $U/NU.Named_Union, case_procs: ..Any) {
    u_type := NU.union_type(u);
    u_info := cast(*Type_Info) u_type;
    case_proc : Any;
    for case_procs {
        assert(it.type.type == .PROCEDURE, "case_proc must be a procedure");
        proc_info := cast(*Type_Info_Procedure)(it.type);
        assert(proc_info.argument_types.count == 1, "case_proc may only have one argument"); // TODO 0 for default case
        assert(proc_info.return_types.count == 0, "case_proc may not have a return value yet"); // TODO
        if u_info == proc_info.argument_types[0] { case_proc = it; break; }
    }

    #insert -> string {
        builder: String_Builder;

        info := type_info(U);
        // if u_type == {
        // case u.Pineapple; val := NU.isa(u, u.Pineapple); proc := <<cast(*#type (u.Pineapple)->()) case_proc.value_pointer; proc(<<val);
        // case u.Mango;     val := NU.isa(u, u.Mango);     proc := <<cast(*#type (u.Mango)->())     case_proc.value_pointer; proc(<<val);
        // case u.Kiwi;      val := NU.isa(u, u.Kiwi);      proc := <<cast(*#type (u.Kiwi)->())      case_proc.value_pointer; proc(<<val);
        // }
        print_to_builder(*builder, "    if u_type == {\n");
        for info.members {
            if !(it.flags & .CONSTANT) || it.name ==  "Bytes" || it.name ==  "Tag" || it.name ==  "value_types" continue;

            print_to_builder(*builder, "    case u.%1;\n", it.name);
            print_to_builder(*builder, "        val := NU.isa(u, u.%1);\n", it.name);
            print_to_builder(*builder, "        proc := <<cast(*#type (u.%1)->()) case_proc.value_pointer;\n", it.name);
            print_to_builder(*builder, "        proc(<<val);\n");
        }
        print_to_builder(*builder, "    }\n");

        return builder_to_string(*builder);
    }
}

NU :: #import, file "../Named_Union.jai";
#poke_name NU MyStruct;
#import "Basic";
