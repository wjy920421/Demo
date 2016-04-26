%{
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <unordered_map>
#include <vector>
#include <string>
#include <string.h>
#include "ast.h"

using namespace std;

extern int yylex();
extern int yyparse();
extern FILE * yyin;
extern char asm_code[500000];




bool debug = false;

int reg_id = 0;
unordered_map<string, Node *> env;

char * filename_base;

void save();
int parser(const char * filename);
void yyerror(const char *s);
int line_count = 1;
int error_count = 0;

// Memory
int offset = 0;
char * current_var_type;

struct BoundStruct {
    int dimensions;
    int d[10][2];
};

struct PairStruct {
    int first;
    int second;
};

%}



%error-verbose

%union
{
    char * str_val;
    char char_val;
    int int_val;

    struct NodeStruct * node;

    struct BoundStruct * bounds;
    struct PairStruct * bound;
}

%token <str_val> NAME "name"
%token <int_val> NUMBER "number"
%token <char_val> CHARCONST "char const"

/* Reserved words */
%token AND "and(keyword)"
%token BY "by(keyword)"
%token CHAR "char(keyword)"
%token ELSE "else(keyword)"
%token FOR "for(keyword)"
%token IF "if(keyword)"
%token INT "int(keyword)"
%token NOT "not(keyword)"
%token OR "or(keyword)"
%token <str_val> PROCEDURE "procedure(keyword)"
%token READ "read(keyword)"
%token THEN "then(keyword)"
%token TO "to(keyword)"
%token WHILE "while(keyword)"
%token WRITE "write(keyword)"

/* Operators */
%token OP_PLUS "+"
%token OP_MINUS "-"
%token OP_TIMES "*"
%token OP_DIVIDE "/"
%token OP_LESSTHAN "<"
%token OP_LESSTHANEQUALS "<="
%token OP_EQUALS "=="
%token OP_NOTEQUALS "!="
%token OP_GREATERTHAN ">"
%token OP_GREATERTHANEQUALS ">="

/* Punctuation */
%token COLON ":"
%token SEMICOLON ";"
%token COMMA ","
%token BIND "="
%token LEFTBRACE "{"
%token RIGHTBRACE "}"
%token LEFTBRACKET "["
%token RIGHTBRACKET "]"
%token LEFTPARENTHESIS "("
%token RIGHTPARENTHESIS ")"

%token OTHER "invalid expression"

%token END 0 "end of file"

%nonassoc IFX
%nonassoc ELSE

%type <str_val> Type
%type <node> Procedure Stmt Stmts Expr Exprs Bool OrTerm AndTerm RelExpr Term Factor Reference
%type <bounds> Bounds
%type <bound> Bound

%%

// Procedures:
//     Procedures Procedure
//     | Procedure

Procedure:
    PROCEDURE NAME
    {
        int d[10][2];
        create_var($2, "procedure", false, 0, d);
    }
    LEFTBRACE Decls Stmts RIGHTBRACE
    {
        execute($6);


        if (error_count == 0)
        {
            save();
            printf("Program compiled to: %s.i\n", filename_base);
            printf("Storage layout saved to: %s.sl\n", filename_base);
        }
        else
        {
            printf("%d error%s generated\n", error_count, (error_count==1)? "": "s");
        }
    }
    ;

Decls:
    Decls Decl
    | Decl
    ;

Decl:
    Type { current_var_type = $1; } SpecList SEMICOLON
    | Type error SEMICOLON
    | NAME error SEMICOLON
    ;

Type:
    INT { $$ = strdup("int"); }
    | CHAR { $$ = strdup("char"); }
    ;

SpecList:
    SpecList COMMA Spec
    | Spec
    ;

Spec:
    NAME LEFTBRACKET Bounds RIGHTBRACKET
    {
        if (env.count($1) > 0) yyerror(("error: " + string($1) + " is declared more than once").c_str());
        else
        {
            Node * p = create_var($1, current_var_type, false, $3->dimensions, $3->d);
            free($3);
        }
    }
    | NAME
    {
        if (env.count($1) > 0) yyerror(("error: " + string($1) + " is declared more than once").c_str());
        else
        {
            int d[10][2];
            Node * p = create_var($1, current_var_type, true, 0, d);
        }
    }
    ;

Bounds:
    Bounds COMMA Bound
    {
        $$ = $1;
        $$->d[$$->dimensions][0] = $3->first;
        $$->d[$$->dimensions][1] = $3->second;
        $$->dimensions = $$->dimensions + 1;
        free($3);
    }
    | Bound
    {
        $$ = (struct BoundStruct *)malloc(sizeof(struct BoundStruct));
        $$->dimensions = 1;
        $$->d[0][0] = $1->first;
        $$->d[0][1] = $1->second;
        free($1);
    }
    ;

Bound:
    NUMBER COLON NUMBER
    {
        if ($1 > $3) yyerror("error: lower bound larger than higher bound");
        $$ = (struct PairStruct *)malloc(sizeof(struct PairStruct));
        $$->first = $1;
        $$->second = $3;
    }
    ;

Stmts:
    Stmts Stmt { $$ = create_op(SEMICOLON, 2, $1, $2); }
    | Stmt { $$ = $1; }
    ;

Stmt:
    Reference BIND Expr SEMICOLON { $$ = create_op(BIND, 2, $1, $3); }
    | LEFTBRACE Stmts RIGHTBRACE { $$= $2; }
    | WHILE LEFTPARENTHESIS Bool RIGHTPARENTHESIS LEFTBRACE Stmts RIGHTBRACE { $$ = create_op(WHILE, 2, $3, $6); }
    | FOR NAME BIND Expr TO Expr BY Expr LEFTBRACE Stmts RIGHTBRACE { $$ = create_op(FOR, 5, get_var($2), $4, $6, $8, $10); }
    | IF LEFTPARENTHESIS Bool RIGHTPARENTHESIS THEN Stmt %prec IFX { $$ = create_op(IF, 2, $3, $6); }
    | IF LEFTPARENTHESIS Bool RIGHTPARENTHESIS THEN Stmt ELSE Stmt { $$ = create_op(IF, 3, $3, $6, $8); }
    | READ Reference SEMICOLON { $$ = create_op(READ, 1, $2); }
    | WRITE Expr SEMICOLON { $$ = create_op(WRITE, 1, $2); }
    | SEMICOLON { yyerror("syntax error, unexpected ;, empty statement"); }
    | LEFTBRACE RIGHTBRACE { yyerror("syntax error, unexpected ;, empty statement list"); }
    | error SEMICOLON { $$ = nullptr; }
    | error RIGHTBRACE { $$ = nullptr; }
    ;

Bool:
    NOT OrTerm { $$ = create_op(NOT, 1, $2); }
    | OrTerm { $$ = $1; }
    ;

OrTerm:
    OrTerm OR AndTerm { $$ = create_op(OR, 2, $1, $3); }
    | AndTerm  { $$ = $1; }
    ;

AndTerm:
    AndTerm AND RelExpr { $$ = create_op(AND, 2, $1, $3); }
    | RelExpr  { $$ = $1; }
    ;

RelExpr:
    RelExpr OP_LESSTHAN Expr { $$ = create_op(OP_LESSTHAN, 2, $1, $3); }
    | RelExpr OP_LESSTHANEQUALS Expr { $$ = create_op(OP_LESSTHANEQUALS, 2, $1, $3); }
    | RelExpr OP_EQUALS Expr { $$ = create_op(OP_EQUALS, 2, $1, $3); }
    | RelExpr OP_NOTEQUALS Expr { $$ = create_op(OP_NOTEQUALS, 2, $1, $3); }
    | RelExpr OP_GREATERTHAN Expr { $$ = create_op(OP_GREATERTHAN, 2, $1, $3); }
    | RelExpr OP_GREATERTHANEQUALS Expr { $$ = create_op(OP_GREATERTHANEQUALS, 2, $1, $3); }
    | Expr { $$ = $1; }
    ;

Expr:
    Expr OP_PLUS Term { $$ = create_op(OP_PLUS, 2, $1, $3); }
    | Expr OP_MINUS Term { $$ = create_op(OP_MINUS, 2, $1, $3); }
    | Term { $$ = $1; }
    ;

Term:
    Term OP_TIMES Factor { $$ = create_op(OP_TIMES, 2, $1, $3); }
    | Term OP_DIVIDE Factor { $$ = create_op(OP_DIVIDE, 2, $1, $3); }
    | Factor { $$ = $1; }
    ;

Factor:
    LEFTPARENTHESIS Expr RIGHTPARENTHESIS { $$ = $2; }
    | Reference { $$ = $1; }
    | NUMBER  { $$ = create_constant($1, false); }
    | CHARCONST { $$ = create_constant($1, true); }
    ;

Reference:
    NAME LEFTBRACKET Exprs RIGHTBRACKET
    {
        Node * var = get_var($1);
        if (var->var.dimensions != $3->op.num_ops)
            yyerror(("error: variable '" + string($1) + "' has " + to_string(var->var.dimensions) + " dimension(s), "
                + "but is referenced with " + to_string($3->op.num_ops) + " subscript(s)").c_str());
        $$ = create_op(LEFTBRACKET, 2, var, $3);
    }
    | NAME
    {
        $$ = get_var($1);
        if ($$->var.dimensions != 0)
            yyerror(("error: variable '" + string($1) + "' has " + to_string($$->var.dimensions) + " dimension(s), "
                + "but is referenced with 0 subscript").c_str());
    }
    ;

Exprs:
    Exprs COMMA Expr { $1->op.ops[$1->op.num_ops++] = $3; $$ = $1; }
    | Expr { $$ = create_op(COMMA, 1, $1); }
    ;

%%



int parser(const char * filename)
{
    if (filename != NULL)
    {
        FILE * file = fopen(filename, "r");
        if (!file)
        {
            fprintf(stderr, "Failed to open %s\n", filename);;
            return -1;
        }
        yyin = file;
        printf("Loaded Demo program from: %s \n", filename);

        filename_base = strdup((string(filename).substr(0, string(filename).find_last_of("."))).c_str()); 
    }
    else
    {
        printf("No file is specified. The program will read from stdin.\n");

        filename_base = strdup("stdin");
    }

    line_count = 1;
    error_count = 0;
    strcpy(asm_code, "");

    do
    {
        yyparse();
    }
    while (!feof(yyin));

    if (debug) print_env(stdout);

    return 0;
}

void save() 
{
    char * filename_i = strdup((string(filename_base) + ".i").c_str());
    FILE * file = fopen(filename_i, "w+");
    if (!file)
    {
        fprintf(stderr, "Failed to open %s\n", filename_i);;
        return;
    }
    fputs(asm_code, file);
    fclose(file);

    char * filename_sl = strdup((string(filename_base) + ".sl").c_str());
    FILE * file2 = fopen(filename_sl, "w+");
    if (!file2)
    {
        fprintf(stderr, "Failed to open %s\n", filename_sl);;
        return;
    }
    print_env(file2);
    fclose(file2);
}

void yyerror(const char * s) 
{
    fprintf(stderr, "Syntax error at line %d: %s\n", line_count, s);
    error_count++;
}

void print_env(FILE * fp)
{
    fprintf(fp, "Storage Layout\n");
    fprintf(fp, "----------------------------------------------\n");
    fprintf(fp, "Name            Addr      Type      Dimensions\n");
    fprintf(fp, "----------------------------------------------\n");
    for (auto it = env.begin(); it != env.end(); ++it)
    {
        if (it->second->var.is_reg)
        {
            fprintf(fp, "%-16s%-10s%-10s", it->second->var.name, it->second->var.reg, it->second->var.type);
        }
        else
        {
            fprintf(fp, "%-16s%-10d%-10s", it->second->var.name, it->second->var.addr, it->second->var.type);
            for (int i = 0; i < it->second->var.dimensions; i++)
                fprintf(fp, "%d:%d ", it->second->var.d[i][0], it->second->var.d[i][1]);
        }
        fprintf(fp, "\n");
    }
    fprintf(fp, "----------------------------------------------\n");
}

#define SIZEOF_NODETYPE ((char *)&p->con - (char *)p)

Node * create_constant(int value, bool charconst)
{
    Node *p;
    p = (Node *)malloc(sizeof(Node));
    p->type = NodeTypeConstant;
    p->constant.value = value;
    p->constant.charconst = charconst;
    return p;
}

Node * create_var(const char * name, const char * type, bool is_reg, int dimensions, int d[10][2])
{
    Node * p;
    p = (Node *)malloc(sizeof(Node));
    p->type = NodeTypeVar;
    p->var.name = strdup(name);
    p->var.type = strdup(type);
    p->var.is_reg = is_reg;
    p->var.dimensions = dimensions;
    if (is_reg)
    {
        char reg[10];
        sprintf(reg, "r%d", reg_id++);
        p->var.reg = strdup(reg);
    }
    else
    {
        p->var.addr = offset;
        int k = (strcmp(type, "char") == 0)? 1: 4;
        for (int i = 0; i < dimensions; i++)
        {
            p->var.d[i][0] = d[i][0];
            p->var.d[i][1] = d[i][1];
            k = k * (d[i][1] - d[i][0] + 1);
        }
        offset = offset + k;
    }
    env[string(name)] = p;
    return p;
}

Node * create_op(int op_type, int num_ops, ...)
{
    va_list ap;
    Node *p;
    p = (Node *)malloc(sizeof(Node));
    p->op.ops = (Node **)malloc(num_ops * sizeof(Node *));
    p->type = NodeTypeOp;
    p->op.op_type = op_type;
    p->op.num_ops = num_ops;
    va_start(ap, num_ops);
    for (int i = 0; i < num_ops; i++)
        p->op.ops[i] = va_arg(ap, Node *);
    va_end(ap);
    return p;
}

Node * get_var(const char * name)
{
    if (env.count(string(name)) == 0)
        yyerror(("error: variable '" + string(name) + "' is not declared").c_str());
    return env[string(name)];
}


