#include <stdio.h>
#include "parser.tab.h"
#include "ast.h"


static int label_id;

int execute(Node *p)
{

    if (!p) return 0;

    switch(p->type)
    {
        case NodeTypeConstant:
        {
            printf("\tpush\t%d\n", p->constant.value);
            break;
        }
        case NodeTypeVar:
        {
            printf("\tpush\t%s\n", p->var.name);
            break;
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

                case IF:
                {
                    execute(p->op.ops[0]);
                    if (p->op.num_ops > 2) {
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
                    else {
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
                case '=':
                {
                    execute(p->op.ops[1]);
                    printf("\tpop\t%s\n", p->op.ops[0]->var.name); break;
                }
                // case UMINUS:
                //     execute(p->opr.op[0]);
                //     printf("\tneg\n");
                //     break;
                default:
                {
                    execute(p->op.ops[0]);
                    execute(p->op.ops[1]);
                    switch(p->op.op_type) {
                        case OP_PLUS: printf("\tadd\n"); break;
                        case OP_MINUS: printf("\tsub\n"); break;
                        case OP_TIMES: printf("\tmul\n"); break;
                        case OP_DIVIDE: printf("\tdiv\n"); break;
                        case OP_LESSTHAN: printf("\tcompLT\n"); break;
                        case OP_LESSTHANEQUALS: printf("\tcompLE\n"); break;
                        case OP_EQUALS: printf("\tcompEQ\n"); break;
                        case OP_NOTEQUALS: printf("\tcompNE\n"); break;
                        case OP_GREATERTHAN: printf("\tcompGT\n"); break;
                        case OP_GREATERTHANEQUALS: printf("\tcompGE\n"); break;
                    }
                }
            }
        }
    }
    return 0;
}









