#include <stdio.h>
#include "parser.tab.h"
#include "ast.h"


static int lbl;

int ex(nodeType *p) {
    int lbl1, lbl2;

    if (!p) return 0;

    switch(p->type) {
    case typeCon:
        printf("\tpush\t%d\n", p->con.value);
        break;
    case typeId:
        printf("\tpush\t%s\n", p->id.i);
        break;
    case typeOpr:
        switch(p->opr.oper) {
        case WHILE:
            printf("L%03d:\n", lbl1 = lbl++);
            ex(p->opr.op[0]);
            printf("\tjz\tL%03d\n", lbl2 = lbl++);
            ex(p->opr.op[1]);
            printf("\tjmp\tL%03d\n", lbl1);
            printf("L%03d:\n", lbl2);
            break;
        case IF:
            ex(p->opr.op[0]);
            if (p->opr.nops > 2) {
                /* if else */
                printf("\tjz\tL%03d\n", lbl1 = lbl++);
                ex(p->opr.op[1]);
                printf("\tjmp\tL%03d\n", lbl2 = lbl++);
                printf("L%03d:\n", lbl1);
                ex(p->opr.op[2]);
                printf("L%03d:\n", lbl2);
            }
            else {
                /* if */
                printf("\tjz\tL%03d\n", lbl1 = lbl++);
                ex(p->opr.op[1]);
                printf("L%03d:\n", lbl1);
            }
            break;
        case WRITE:
            ex(p->opr.op[0]);
            printf("\tprint\n");
            break;
        case '=':
            ex(p->opr.op[1]);
            printf("\tpop\t%s\n", p->opr.op[0]->id.i); break;
        // case UMINUS:
        //     ex(p->opr.op[0]);
        //     printf("\tneg\n");
        //     break;
        default:
            ex(p->opr.op[0]);
            ex(p->opr.op[1]);
            switch(p->opr.oper) {
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
    return 0;
}









