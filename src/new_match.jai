Fruit :: struct {
    _Tag :: enum u8 {
        MANGO;
        PANGO;
    }
    _Bytes :: union {
        mango: u8;
        pango: string = ---;
    }
    _tag: _Tag;
    using _bytes: _Bytes; @UnionTag:_tag
}

main :: () {
    fruit := Fruit.{_tag=.PANGO, pango="yo"};

    in:= 5;
    out: string;

    match(#code if fruit == {
    case .MANGO;
        assert(type_of(my_var) == u8);
        out = tprint("Mango %, %\n", my_var, in);
    case .PANGO;
        assert(type_of(my_var) == string);
        out = tprint("Pango %, %\n", my_var, in);
    }, "my_var");

    print(out);
}

// var_name sets the name for the generated variable. Just like it/it_index
// ideally you could change it with official syntax like: `if my_var: fruit == {`
match :: (code:Code, var_name:="var", call:=#caller_code) #expand {
    `condition:= #insert,scope(call) -> Code {
        root := compiler_get_nodes(code);  assert(root.kind == .IF);
        return compiler_get_code(cast(*Code_If, root).condition);
    };
    enum_info  :: type_info(type_of(condition)._Tag  );
    union_info :: type_info(type_of(condition)._Bytes);

    #insert,scope(call) -> Code {
        root:= compiler_get_nodes(code);  assert(root.kind == .IF);
        if_root :*Code_If= xx root;
        assert((if_root.if_flags & .IS_SWITCH_STATEMENT) > 0);

        if_root.condition = compiler_get_nodes(#code condition._tag); // TODO get from @uniontag:name note

        for if_root.then_block.statements {
            assert(it.kind == .CASE);
            code_case :*Code_Case= xx it;
            if code_case.condition == null continue; // Default case

            // Recursively get till we are at the last dot @speed we we don't need to collect or recurse into all, we just need the last one
            nodes: [..] *Code_Node;
            get_recursive_nodes_breadth_first(code_case.condition, *nodes);
            assert(nodes.count > 0 && peek(nodes).kind == .IDENT);
            enum_variant :*Code_Ident= xx peek(nodes);

            // Use idx to get name of union variant and replace var with unionvariantname
            found, index := array_find(enum_info.names, enum_variant.name);
            assert(found, ".% is not a variant of enum %", enum_variant.name, enum_info.name);
            assert(union_info.members.count > index);
            unions_variant_name := union_info.members[index].name;

            // var:= condition.variant_name; TODO if condition is a pointer var should be a pointer
            make_var_declaration :: (variant_name: string, variable_name: string) -> *Code_Declaration {
                left_ident:= New(Code_Ident);
                left_ident.name = "condition";

                right_ident:= New(Code_Ident);
                right_ident.name = variant_name;

                new_binop:= New(Code_Binary_Operator);
                new_binop.kind = .BINARY_OPERATOR;
                new_binop.operator_type = #char ".";
                new_binop.left = left_ident;
                new_binop.right = right_ident;

                decl := New(Code_Declaration);
                decl.name = variable_name;
                decl.expression = new_binop;

                return decl;
            }




            // Prepend the new statement to the existing statements of the current case block
            new_statements : [..] *Code_Node;
            array_add(*new_statements, make_var_declaration(unions_variant_name, var_name));
            // array_add(*new_statements, compiler_get_nodes(#code #insert tprint("var:= condition.%;", unions_variant_name) ));
            array_add(*new_statements, ..code_case.then_block.statements);
            code_case.then_block.statements = new_statements;
        }
        return compiler_get_code(root);
    }
}


#import "Basic";
#import "Compiler";
#import "Print_Vars";
#import "Code_Visit";
