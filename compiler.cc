#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include "parser.tab.h"
#include "ast.h"

extern int reg_id;

static int label_id;

char asm_code[500000];

void gen_code(const char *format, ...)
{
    va_list arg;
    char str[100];
    va_start (arg, format);
    vsprintf (str, format, arg);
    va_end (arg);
    strcat(asm_code, str);
    strcat(asm_code, "\n");

    printf("%s\n", str);
}

Node * create_temp_reg(const char * type)
{
    Node * p;
    p = (Node *)malloc(sizeof(Node));
    p->type = NodeTypeVar;
    p->var.name = strdup("return_value");
    p->var.type = strdup(type);
    char reg[10];
    sprintf(reg, "r%d", reg_id++);
    p->var.is_reg = true;
    p->var.reg = strdup(reg);
    p->var.dimensions = 0;
    return p;
}

Node * copy_reg(Node * dest, Node * src)
{
    if (strcmp(src->var.type, "int") == 0 && strcmp(dest->var.type, "int") == 0)
        gen_code("        i2i %s => %s", src->var.reg, dest->var.reg);
    else if (strcmp(src->var.type, "int") == 0 && strcmp(dest->var.type, "char") == 0)
        gen_code("        i2c %s => %s", src->var.reg, dest->var.reg);
    else if (strcmp(src->var.type, "char") == 0 && strcmp(dest->var.type, "char") == 0)
        gen_code("        c2c %s => %s", src->var.reg, dest->var.reg);
    else if (strcmp(src->var.type, "char") == 0 && strcmp(dest->var.type, "int") == 0)
        gen_code("        c2i %s => %s", src->var.reg, dest->var.reg);
    return dest;
}

Node * load_constant(Node * dest, Node * constant)
{
    if (strcmp(dest->var.type, "int") == 0)
    {
        gen_code("        loadI %d => %s", constant->constant.value, dest->var.reg);
    }
    else
    {
        Node * temp = create_temp_reg("int");
        gen_code("        loadI %d => %s", constant->constant.value, temp->var.reg);
        copy_reg(dest, temp);
    }
    return dest;
}

Node * load_constant(Node * p)
{
    Node * dest = create_temp_reg((p->constant.charconst)? "char": "int");
    load_constant(dest, p);
    return dest;
}

Node * execute(Node * p, Node * ret);

Node * execute(Node * p)
{
    return execute(p, nullptr);
}

Node * get_addr(Node * p)
{
    Node * var = execute(p->op.ops[0]);
    Node * index[10];
    for (int i = 0; i < p->op.ops[1]->op.num_ops; i++)
        index[i] = execute(p->op.ops[1]->op.ops[i]);
    Node * accum = load_constant(create_constant(0, false));
    for (int i = 0; i < p->op.ops[1]->op.num_ops; i++)
    {
        if (i > 0) accum = execute(create_op(OP_TIMES, 2, accum, create_constant(var->var.d[i][1] - var->var.d[i][0] + 1, false)), accum);
        accum = execute(create_op(OP_PLUS, 2, accum, create_op(OP_MINUS, 2, index[i], create_constant(var->var.d[i][0], false))), accum);
    }
    if (strcmp(var->var.type, "char") != 0)
        accum = execute(create_op(OP_TIMES, 2, accum, create_constant(4, false)), accum);
    accum = execute(create_op(OP_PLUS, 2, accum, create_constant(var->var.addr, false)), accum);
    return accum;
}

Node * execute(Node * p, Node * ret)
{
    if (!p) return nullptr;

    switch(p->type)
    {
        case NodeTypeConstant:
        {
            return p;
        }
        case NodeTypeVar:
        {
            return p;
        }
        case NodeTypeOp:
        {
            switch(p->op.op_type)
            {
                case WHILE:
                {
                    int label_1 = label_id++;
                    int label_2 = label_id++;
                    Node * test = execute(p->op.ops[0]);
                    gen_code("        cbr %s -> L%03d, L%03d", test->var.reg, label_1, label_2);
                    gen_code("L%03d:   nop", label_1);
                    execute(p->op.ops[1]);
                    test = execute(p->op.ops[0]);
                    gen_code("        cbr %s -> L%03d, L%03d", test->var.reg, label_1, label_2);
                    gen_code("L%03d:   nop", label_2);
                    break;
                }
                case FOR:
                {
                    int label_1 = label_id++;
                    int label_2 = label_id++;
                    Node * iter = p->op.ops[0];
                    execute(create_op(BIND, 2, iter, p->op.ops[1]));
                    Node * ub = execute(p->op.ops[2]);
                    Node * test = execute(create_op(OP_LESSTHANEQUALS, 2, iter, ub));
                    Node * step = execute(p->op.ops[3]);
                    gen_code("        cbr %s -> L%03d, L%03d", test->var.reg, label_1, label_2);
                    gen_code("L%03d:   nop", label_1);
                    execute(p->op.ops[4]);
                    execute(create_op(OP_PLUS, 2, iter, step), iter);
                    test = execute(create_op(OP_LESSTHANEQUALS, 2, iter, ub));
                    gen_code("        cbr %s -> L%03d, L%03d", test->var.reg, label_1, label_2);
                    gen_code("L%03d:   nop", label_2);
                    break;
                }
                case IF:
                {
                    Node * test = execute(p->op.ops[0]);
                    if (p->op.num_ops == 2)
                    {
                        int label_1 = label_id++;
                        int label_2 = label_id++;
                        gen_code("        cbr %s -> L%03d, L%03d", test->var.reg, label_1, label_2);
                        gen_code("L%03d:   nop", label_1);
                        execute(p->op.ops[1]);
                        gen_code("L%03d:   nop", label_2);
                    }
                    else
                    {
                        int label_1 = label_id++;
                        int label_2 = label_id++;
                        int label_3 = label_id++;
                        gen_code("        cbr %s -> L%03d, L%03d", test->var.reg, label_1, label_2);
                        gen_code("L%03d:   nop", label_1);
                        execute(p->op.ops[1]);
                        gen_code("        br -> L%03d", label_3);
                        gen_code("L%03d:   nop", label_2);
                        execute(p->op.ops[2]);
                        gen_code("        br -> L%03d", label_3);
                        gen_code("L%03d:   nop", label_3);
                    }
                    break;
                }
                case WRITE:
                {
                    Node * result = execute(p->op.ops[0]);
                    
                    if (result->type == NodeTypeConstant)
                        result = load_constant(result);

                    if (strcmp(result->var.type, "int") == 0)
                        gen_code("        write %s", result->var.reg);
                    else if (strcmp(result->var.type, "char") == 0)
                        gen_code("        cwrite %s", result->var.reg);

                    return result;
                }
                case BIND:
                {
                    Node * ref = p->op.ops[0];
                    Node * expr = execute(p->op.ops[1]);

                    if (ref->op.op_type == LEFTBRACKET)
                    {
                        Node * addr = get_addr(ref);
                        if (expr->type == NodeTypeConstant) expr = load_constant(expr);
                        if (strcmp(ref->op.ops[0]->var.type, "int") == 0)
                        {
                            gen_code("        store %s => %s", expr->var.reg, addr->var.reg);
                        }
                        else
                        {
                            gen_code("        cload %s => %s", expr->var.reg, addr->var.reg);
                        }
                    }
                    else
                    {
                        if (expr->type == NodeTypeConstant)
                        {
                            load_constant(ref, expr);
                        }
                        else
                        {
                            copy_reg(ref, expr);
                        }
                    }
                    return ref;
                }
                case LEFTBRACKET:
                {
                    Node * var = p->op.ops[0];
                    Node * addr = get_addr(p);
                    Node * temp;
                    if (strcmp(var->var.type, "int") == 0)
                    {
                        temp = create_temp_reg("int");
                        gen_code("        load %s => %s", addr->var.reg, temp->var.reg);
                    }
                    else
                    {
                        temp = create_temp_reg("char");
                        gen_code("        cload %s => %s", addr->var.reg, temp->var.reg);
                    }
                    return temp;
                }
                default:
                {
                    Node * left = execute(p->op.ops[0]);
                    Node * right;
                    if (p->op.num_ops == 2)
                        right = execute(p->op.ops[1]);

                    switch(p->op.op_type)
                    {
                        case OP_PLUS:
                        {
                            if (left->type == NodeTypeConstant && right->type == NodeTypeConstant)
                            {
                                return create_constant(left->constant.value + right->constant.value, false);
                            }
                            else if (left->type != NodeTypeConstant && right->type == NodeTypeConstant)
                            {
                                if ( (!ret) || ret->type == NodeTypeConstant) ret = create_temp_reg("int");
                                gen_code("        addI %s, %d => %s",left->var.reg , right->constant.value, ret->var.reg);
                            }
                            else if (left->type == NodeTypeConstant && right->type != NodeTypeConstant)
                            {
                                if ( (!ret) || ret->type == NodeTypeConstant) ret = create_temp_reg("int");
                                gen_code("        addI %s, %d => %s",right->var.reg , left->constant.value, ret->var.reg);
                            }
                            else if (left->type != NodeTypeConstant && right->type != NodeTypeConstant)
                            {
                                if ( (!ret) || ret->type == NodeTypeConstant) ret = create_temp_reg("int");
                                gen_code("        add %s, %s => %s",left->var.reg , right->var.reg, ret->var.reg);
                            }
                            break;
                        }
                        case OP_MINUS:
                        {
                            if (left->type == NodeTypeConstant && right->type == NodeTypeConstant)
                            {
                                return create_constant(left->constant.value - right->constant.value, false);
                            }
                            else if (left->type != NodeTypeConstant && right->type == NodeTypeConstant)
                            {
                                if ( (!ret) || ret->type == NodeTypeConstant) ret = create_temp_reg("int");
                                gen_code("        subI %s, %d => %s",left->var.reg , right->constant.value, ret->var.reg);
                            }
                            else if (left->type == NodeTypeConstant && right->type != NodeTypeConstant)
                            {
                                if ( (!ret) || ret->type == NodeTypeConstant) ret = create_temp_reg("int");
                                Node * left_temp = load_constant(left);
                                gen_code("        sub %s, %s => %s",left_temp->var.reg , right->var.reg, ret->var.reg);
                            }
                            else if (left->type != NodeTypeConstant && right->type != NodeTypeConstant)
                            {
                                if ( (!ret) || ret->type == NodeTypeConstant) ret = create_temp_reg("int");
                                gen_code("        sub %s, %s => %s",left->var.reg , right->var.reg, ret->var.reg);
                            }
                            break;
                        }
                        case OP_TIMES:
                        {
                            if (left->type == NodeTypeConstant && right->type == NodeTypeConstant)
                            {
                                return create_constant(left->constant.value * right->constant.value, false);
                            }
                            else if (left->type != NodeTypeConstant && right->type == NodeTypeConstant)
                            {
                                if ( (!ret) || ret->type == NodeTypeConstant) ret = create_temp_reg("int");
                                gen_code("        multI %s, %d => %s",left->var.reg , right->constant.value, ret->var.reg);
                            }
                            else if (left->type == NodeTypeConstant && right->type != NodeTypeConstant)
                            {
                                if ( (!ret) || ret->type == NodeTypeConstant) ret = create_temp_reg("int");
                                gen_code("        multI %s, %d => %s",right->var.reg , left->constant.value, ret->var.reg);
                            }
                            else if (left->type != NodeTypeConstant && right->type != NodeTypeConstant)
                            {
                                if ( (!ret) || ret->type == NodeTypeConstant) ret = create_temp_reg("int");
                                gen_code("        mult %s, %s => %s",left->var.reg , right->var.reg, ret->var.reg);
                            }
                            break;
                        }
                        case OP_DIVIDE:
                        {
                            if (left->type == NodeTypeConstant && right->type == NodeTypeConstant)
                            {
                                return create_constant(left->constant.value / right->constant.value, false);
                            }
                            else if (left->type != NodeTypeConstant && right->type == NodeTypeConstant)
                            {
                                if ( (!ret) || ret->type == NodeTypeConstant) ret = create_temp_reg("int");
                                gen_code("        divI %s, %d => %s",left->var.reg , right->constant.value, ret->var.reg);
                            }
                            else if (left->type == NodeTypeConstant && right->type != NodeTypeConstant)
                            {
                                if ( (!ret) || ret->type == NodeTypeConstant) ret = create_temp_reg("int");
                                Node * left_temp = load_constant(left);
                                gen_code("        div %s, %s => %s",left_temp->var.reg , right->var.reg, ret->var.reg);
                            }
                            else if (left->type != NodeTypeConstant && right->type != NodeTypeConstant)
                            {
                                if ( (!ret) || ret->type == NodeTypeConstant) ret = create_temp_reg("int");
                                gen_code("        div %s, %s => %s",left->var.reg , right->var.reg, ret->var.reg);
                            }
                            break;
                        }
                        case OP_LESSTHAN:
                        {
                            if ( (!ret) || ret->type == NodeTypeConstant) ret = create_temp_reg("int");
                            Node * left_reg = left, * right_reg = right;
                            if (left->type == NodeTypeConstant) left_reg = load_constant(left);
                            if (right->type == NodeTypeConstant) right_reg = load_constant(right);
                            gen_code("        cmp_LT %s, %s => %s",left_reg->var.reg , right_reg->var.reg, ret->var.reg);
                            break;
                        }
                        case OP_LESSTHANEQUALS:
                        {
                            if ( (!ret) || ret->type == NodeTypeConstant) ret = create_temp_reg("int");
                            Node * left_reg = left, * right_reg = right;
                            if (left->type == NodeTypeConstant) left_reg = load_constant(left);
                            if (right->type == NodeTypeConstant) right_reg = load_constant(right);
                            gen_code("        cmp_LE %s, %s => %s",left_reg->var.reg , right_reg->var.reg, ret->var.reg);
                            break;
                        }
                        case OP_EQUALS:
                        {
                            if ( (!ret) || ret->type == NodeTypeConstant) ret = create_temp_reg("int");
                            Node * left_reg = left, * right_reg = right;
                            if (left->type == NodeTypeConstant) left_reg = load_constant(left);
                            if (right->type == NodeTypeConstant) right_reg = load_constant(right);
                            gen_code("        cmp_EQ %s, %s => %s",left_reg->var.reg , right_reg->var.reg, ret->var.reg);
                            break;
                        }
                        case OP_NOTEQUALS:
                        {
                            if ( (!ret) || ret->type == NodeTypeConstant) ret = create_temp_reg("int");
                            Node * left_reg = left, * right_reg = right;
                            if (left->type == NodeTypeConstant) left_reg = load_constant(left);
                            if (right->type == NodeTypeConstant) right_reg = load_constant(right);
                            gen_code("        cmp_NE %s, %s => %s",left_reg->var.reg , right_reg->var.reg, ret->var.reg);
                            break;
                        }
                        case OP_GREATERTHAN:
                        {
                            if ( (!ret) || ret->type == NodeTypeConstant) ret = create_temp_reg("int");
                            Node * left_reg = left, * right_reg = right;
                            if (left->type == NodeTypeConstant) left_reg = load_constant(left);
                            if (right->type == NodeTypeConstant) right_reg = load_constant(right);
                            gen_code("        cmp_GT %s, %s => %s",left_reg->var.reg , right_reg->var.reg, ret->var.reg);
                            break;
                        }
                        case OP_GREATERTHANEQUALS:
                        {
                            if ( (!ret) || ret->type == NodeTypeConstant) ret = create_temp_reg("int");
                            Node * left_reg = left, * right_reg = right;
                            if (left->type == NodeTypeConstant) left_reg = load_constant(left);
                            if (right->type == NodeTypeConstant) right_reg = load_constant(right);
                            gen_code("        cmp_GE %s, %s => %s",left_reg->var.reg , right_reg->var.reg, ret->var.reg);
                            break;
                        }
                        case AND:
                        {
                            if ( (!ret) || ret->type == NodeTypeConstant) ret = create_temp_reg("int");
                            Node * left_reg = left, * right_reg = right;
                            if (left->type == NodeTypeConstant) left_reg = load_constant(left);
                            if (right->type == NodeTypeConstant) right_reg = load_constant(right);
                            gen_code("        and %s, %s => %s",left_reg->var.reg , right_reg->var.reg, ret->var.reg);
                            break;
                        }
                        case OR:
                        {
                            if ( (!ret) || ret->type == NodeTypeConstant) ret = create_temp_reg("int");
                            Node * left_reg = left, * right_reg = right;
                            if (left->type == NodeTypeConstant) left_reg = load_constant(left);
                            if (right->type == NodeTypeConstant) right_reg = load_constant(right);
                            gen_code("        or %s, %s => %s",left_reg->var.reg , right_reg->var.reg, ret->var.reg);
                            break;
                        }
                        case NOT:
                        {
                            if ( (!ret) || ret->type == NodeTypeConstant) ret = create_temp_reg("int");
                            Node * left_reg = left;
                            if (left->type == NodeTypeConstant) left_reg = load_constant(left);
                            gen_code("        not %s => %s",left_reg->var.reg , ret->var.reg);
                            break;
                        }
                        default: break;
                    }

                    return ret;
                }
            }
        }
        default:
        {

        }
    }
    return p;
}









