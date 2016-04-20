#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include "parser.tab.h"
#include "ast.h"

extern int reg_id;

static int label_id;

static char asm_code[500000];

Node * create_temp_reg(const char * type)
{
    Node * p;
    p = (Node *)malloc(sizeof(Node));
    p->type = NodeTypeVar;
    p->var.name = strdup("return_value");
    p->var.type = strdup(type);
    char reg[10];
    sprintf(reg, "r%d", reg_id++);
    p->var.reg = strdup(reg);
    p->var.dimensions = 0;
    return p;
}

void gen_code(const char *format, ...)
{
    va_list arg;
    char str[100];
    va_start (arg, format);
    vsprintf (str, format, arg);
    va_end (arg);
    strcat(asm_code, "\n");
    strcat(asm_code, str);

    printf("%s\n", str);
}

Node * execute(Node * p)
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
        case NodeTypeRef:
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
                    printf("L%03d:\n", label_1);
                    execute(p->op.ops[0]);
                    printf("\tjz\tL%03d\n", label_2);
                    execute(p->op.ops[1]);
                    printf("\tjmp\tL%03d\n", label_1);
                    printf("L%03d:\n", label_2);
                    break;
                }
                case FOR:
                {

                    break;
                }
                case IF:
                {
                    execute(p->op.ops[0]);
                    if (p->op.num_ops > 2)
                    {
                        /* if else */
                        int label_1 = label_id++;
                        int label_2 = label_id++;
                        printf("\tjz\tL%03d\n", label_1);
                        execute(p->op.ops[1]);
                        printf("\tjmp\tL%03d\n", label_2);
                        printf("L%03d:\n", label_1);
                        execute(p->op.ops[2]);
                        printf("L%03d:\n", label_2);
                    }
                    else
                    {
                        /* if */
                        int label = label_id++;
                        printf("\tjz\tL%03d\n", label);
                        execute(p->op.ops[1]);
                        printf("L%03d:\n", label);
                    }
                    break;
                }
                case WRITE:
                {
                    execute(p->op.ops[0]);
                    printf("\tprint\n");
                    break;
                }
                case BIND:
                {
                    Node * ref = p->op.ops[0];
                    Node * expr = execute(p->op.ops[1]);
                    if (expr->type == NodeTypeConstant)
                    {
                        gen_code("        loadI %d => %s", expr->constant.value, ref->var.reg);
                    }
                    else
                    {
                        if (strcmp(expr->var.type, "int") == 0 && strcmp(ref->var.type, "int") == 0)
                            gen_code("        i2i %s => %s", expr->var.reg, ref->var.reg);
                        else if (strcmp(expr->var.type, "int") == 0 && strcmp(ref->var.type, "char") == 0)
                            gen_code("        i2c %s => %s", expr->var.reg, ref->var.reg);
                        else if (strcmp(expr->var.type, "char") == 0 && strcmp(ref->var.type, "char") == 0)
                            gen_code("        c2c %s => %s", expr->var.reg, ref->var.reg);
                        else if (strcmp(expr->var.type, "char") == 0 && strcmp(ref->var.type, "int") == 0)
                            gen_code("        c2i %s => %s", expr->var.reg, ref->var.reg);
                    }
                    return ref;
                }
                // case UMINUS:
                //     execute(p->opr.op[0]);
                //     printf("\tneg\n");
                //     break;
                default:
                {
                    Node * left = execute(p->op.ops[0]);
                    Node * right = execute(p->op.ops[1]);
                    Node * ret = create_temp_reg("int");

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
                                gen_code("        addI %s, %d => %s",left->var.reg , right->constant.value, ret->var.reg);
                            }
                            else if (left->type == NodeTypeConstant && right->type != NodeTypeConstant)
                            {
                                gen_code("        addI %s, %d => %s",right->var.reg , left->constant.value, ret->var.reg);
                            }
                            else if (left->type != NodeTypeConstant && right->type != NodeTypeConstant)
                            {
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
                                gen_code("        subI %s, %d => %s",left->var.reg , right->constant.value, ret->var.reg);
                            }
                            else if (left->type == NodeTypeConstant && right->type != NodeTypeConstant)
                            {
                                Node * temp = ret;
                                ret = create_temp_reg("int");
                                gen_code("        loadI %d => %s", left->constant.value, temp->var.reg);
                                gen_code("        sub %s, %s => %s",temp->var.reg , right->var.reg, ret->var.reg);
                            }
                            else if (left->type != NodeTypeConstant && right->type != NodeTypeConstant)
                            {
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
                                gen_code("        multI %s, %d => %s",left->var.reg , right->constant.value, ret->var.reg);
                            }
                            else if (left->type == NodeTypeConstant && right->type != NodeTypeConstant)
                            {
                                gen_code("        multI %s, %d => %s",right->var.reg , left->constant.value, ret->var.reg);
                            }
                            else if (left->type != NodeTypeConstant && right->type != NodeTypeConstant)
                            {
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
                                gen_code("        divI %s, %d => %s",left->var.reg , right->constant.value, ret->var.reg);
                            }
                            else if (left->type == NodeTypeConstant && right->type != NodeTypeConstant)
                            {
                                Node * temp = ret;
                                ret = create_temp_reg("int");
                                gen_code("        loadI %d => %s", left->constant.value, temp->var.reg);
                                gen_code("        div %s, %s => %s",temp->var.reg , right->var.reg, ret->var.reg);
                            }
                            else if (left->type != NodeTypeConstant && right->type != NodeTypeConstant)
                            {
                                gen_code("        div %s, %s => %s",left->var.reg , right->var.reg, ret->var.reg);
                            }
                            break;
                        }
                        case OP_LESSTHAN:
                        {
                            if (left->type == NodeTypeConstant && right->type == NodeTypeConstant)
                            {
                                Node * left_temp = ret;
                                Node * right_temp = create_temp_reg("int");
                                ret = create_temp_reg("int");
                                gen_code("        loadI %d => %s", left->constant.value, left_temp->var.reg);
                                gen_code("        loadI %d => %s", right->constant.value, right_temp->var.reg);
                                gen_code("        cmp_LT %s, %s => %s",left_temp->var.reg , right_temp->var.reg, ret->var.reg);
                            }
                            else if (left->type != NodeTypeConstant && right->type == NodeTypeConstant)
                            {
                                Node * temp = ret;
                                ret = create_temp_reg("int");
                                gen_code("        loadI %d => %s", right->constant.value, temp->var.reg);
                                gen_code("        cmp_LT %s, %s => %s",left->var.reg , temp->var.reg, ret->var.reg);
                            }
                            else if (left->type == NodeTypeConstant && right->type != NodeTypeConstant)
                            {
                                Node * temp = ret;
                                ret = create_temp_reg("int");
                                gen_code("        loadI %d => %s", left->constant.value, temp->var.reg);
                                gen_code("        cmp_LT %s, %s => %s",temp->var.reg , right->var.reg, ret->var.reg);
                            }
                            else if (left->type != NodeTypeConstant && right->type != NodeTypeConstant)
                            {
                                gen_code("        cmp_LT %s, %s => %s",left->var.reg , right->var.reg, ret->var.reg);
                            }
                            break;
                        }
                        case OP_LESSTHANEQUALS:
                        {
                            if (left->type == NodeTypeConstant && right->type == NodeTypeConstant)
                            {
                                Node * left_temp = ret;
                                Node * right_temp = create_temp_reg("int");
                                ret = create_temp_reg("int");
                                gen_code("        loadI %d => %s", left->constant.value, left_temp->var.reg);
                                gen_code("        loadI %d => %s", right->constant.value, right_temp->var.reg);
                                gen_code("        cmp_LE %s, %s => %s",left_temp->var.reg , right_temp->var.reg, ret->var.reg);
                            }
                            else if (left->type != NodeTypeConstant && right->type == NodeTypeConstant)
                            {
                                Node * temp = ret;
                                ret = create_temp_reg("int");
                                gen_code("        loadI %d => %s", right->constant.value, temp->var.reg);
                                gen_code("        cmp_LE %s, %s => %s",left->var.reg , temp->var.reg, ret->var.reg);
                            }
                            else if (left->type == NodeTypeConstant && right->type != NodeTypeConstant)
                            {
                                Node * temp = ret;
                                ret = create_temp_reg("int");
                                gen_code("        loadI %d => %s", left->constant.value, temp->var.reg);
                                gen_code("        cmp_LE %s, %s => %s",temp->var.reg , right->var.reg, ret->var.reg);
                            }
                            else if (left->type != NodeTypeConstant && right->type != NodeTypeConstant)
                            {
                                gen_code("        cmp_LE %s, %s => %s",left->var.reg , right->var.reg, ret->var.reg);
                            }
                            break;
                        }
                        case OP_EQUALS:
                        {
                            if (left->type == NodeTypeConstant && right->type == NodeTypeConstant)
                            {
                                Node * left_temp = ret;
                                Node * right_temp = create_temp_reg("int");
                                ret = create_temp_reg("int");
                                gen_code("        loadI %d => %s", left->constant.value, left_temp->var.reg);
                                gen_code("        loadI %d => %s", right->constant.value, right_temp->var.reg);
                                gen_code("        cmp_EQ %s, %s => %s",left_temp->var.reg , right_temp->var.reg, ret->var.reg);
                            }
                            else if (left->type != NodeTypeConstant && right->type == NodeTypeConstant)
                            {
                                Node * temp = ret;
                                ret = create_temp_reg("int");
                                gen_code("        loadI %d => %s", right->constant.value, temp->var.reg);
                                gen_code("        cmp_EQ %s, %s => %s",left->var.reg , temp->var.reg, ret->var.reg);
                            }
                            else if (left->type == NodeTypeConstant && right->type != NodeTypeConstant)
                            {
                                Node * temp = ret;
                                ret = create_temp_reg("int");
                                gen_code("        loadI %d => %s", left->constant.value, temp->var.reg);
                                gen_code("        cmp_EQ %s, %s => %s",temp->var.reg , right->var.reg, ret->var.reg);
                            }
                            else if (left->type != NodeTypeConstant && right->type != NodeTypeConstant)
                            {
                                gen_code("        cmp_EQ %s, %s => %s",left->var.reg , right->var.reg, ret->var.reg);
                            }
                            break;
                        }
                        case OP_NOTEQUALS:
                        {
                            if (left->type == NodeTypeConstant && right->type == NodeTypeConstant)
                            {
                                Node * left_temp = ret;
                                Node * right_temp = create_temp_reg("int");
                                ret = create_temp_reg("int");
                                gen_code("        loadI %d => %s", left->constant.value, left_temp->var.reg);
                                gen_code("        loadI %d => %s", right->constant.value, right_temp->var.reg);
                                gen_code("        cmp_NE %s, %s => %s",left_temp->var.reg , right_temp->var.reg, ret->var.reg);
                            }
                            else if (left->type != NodeTypeConstant && right->type == NodeTypeConstant)
                            {
                                Node * temp = ret;
                                ret = create_temp_reg("int");
                                gen_code("        loadI %d => %s", right->constant.value, temp->var.reg);
                                gen_code("        cmp_NE %s, %s => %s",left->var.reg , temp->var.reg, ret->var.reg);
                            }
                            else if (left->type == NodeTypeConstant && right->type != NodeTypeConstant)
                            {
                                Node * temp = ret;
                                ret = create_temp_reg("int");
                                gen_code("        loadI %d => %s", left->constant.value, temp->var.reg);
                                gen_code("        cmp_NE %s, %s => %s",temp->var.reg , right->var.reg, ret->var.reg);
                            }
                            else if (left->type != NodeTypeConstant && right->type != NodeTypeConstant)
                            {
                                gen_code("        cmp_NE %s, %s => %s",left->var.reg , right->var.reg, ret->var.reg);
                            }
                            break;
                        }
                        case OP_GREATERTHAN:
                        {
                            if (left->type == NodeTypeConstant && right->type == NodeTypeConstant)
                            {
                                Node * left_temp = ret;
                                Node * right_temp = create_temp_reg("int");
                                ret = create_temp_reg("int");
                                gen_code("        loadI %d => %s", left->constant.value, left_temp->var.reg);
                                gen_code("        loadI %d => %s", right->constant.value, right_temp->var.reg);
                                gen_code("        cmp_GT %s, %s => %s",left_temp->var.reg , right_temp->var.reg, ret->var.reg);
                            }
                            else if (left->type != NodeTypeConstant && right->type == NodeTypeConstant)
                            {
                                Node * temp = ret;
                                ret = create_temp_reg("int");
                                gen_code("        loadI %d => %s", right->constant.value, temp->var.reg);
                                gen_code("        cmp_GT %s, %s => %s",left->var.reg , temp->var.reg, ret->var.reg);
                            }
                            else if (left->type == NodeTypeConstant && right->type != NodeTypeConstant)
                            {
                                Node * temp = ret;
                                ret = create_temp_reg("int");
                                gen_code("        loadI %d => %s", left->constant.value, temp->var.reg);
                                gen_code("        cmp_GT %s, %s => %s",temp->var.reg , right->var.reg, ret->var.reg);
                            }
                            else if (left->type != NodeTypeConstant && right->type != NodeTypeConstant)
                            {
                                gen_code("        cmp_GT %s, %s => %s",left->var.reg , right->var.reg, ret->var.reg);
                            }
                            break;
                        }
                        case OP_GREATERTHANEQUALS:
                        {
                            if (left->type == NodeTypeConstant && right->type == NodeTypeConstant)
                            {
                                Node * left_temp = ret;
                                Node * right_temp = create_temp_reg("int");
                                ret = create_temp_reg("int");
                                gen_code("        loadI %d => %s", left->constant.value, left_temp->var.reg);
                                gen_code("        loadI %d => %s", right->constant.value, right_temp->var.reg);
                                gen_code("        cmp_GE %s, %s => %s",left_temp->var.reg , right_temp->var.reg, ret->var.reg);
                            }
                            else if (left->type != NodeTypeConstant && right->type == NodeTypeConstant)
                            {
                                Node * temp = ret;
                                ret = create_temp_reg("int");
                                gen_code("        loadI %d => %s", right->constant.value, temp->var.reg);
                                gen_code("        cmp_GE %s, %s => %s",left->var.reg , temp->var.reg, ret->var.reg);
                            }
                            else if (left->type == NodeTypeConstant && right->type != NodeTypeConstant)
                            {
                                Node * temp = ret;
                                ret = create_temp_reg("int");
                                gen_code("        loadI %d => %s", left->constant.value, temp->var.reg);
                                gen_code("        cmp_GE %s, %s => %s",temp->var.reg , right->var.reg, ret->var.reg);
                            }
                            else if (left->type != NodeTypeConstant && right->type != NodeTypeConstant)
                            {
                                gen_code("        cmp_GE %s, %s => %s",left->var.reg , right->var.reg, ret->var.reg);
                            }
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









