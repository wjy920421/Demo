%{
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <unordered_map>
#include <vector>
#include <tuple>
#include <string>
#include "ast.h"

using namespace std;

extern int yylex();
extern int yyparse();
extern FILE * yyin;
extern int line_count;






Node * create_constant(int value, bool charconst);
Node * create_var(char * name, char * type);
Node * create_op(int op_type, int num_ops, ...);
Node * get_var(char * name, int dimensions, int d[]);
int execute(Node *p);
int sym[26];
static int reg_id = 0;
unordered_map<string, Node *> env;

void print_storage();
int parser(char * filename);
void yyerror(const char *s);
int error_count = 0;

class Var
{
public:
    Var(string n, string a, string t, vector<pair<int, int>> d)
    { name = n; addr = a; type = t; dimensions = d; }
    string name;
    string addr;
    string type;
    vector<pair<int, int>> dimensions;
};

struct reference_struct
{
    char * name;
    int dimmensions;
    int d[20];
};

// Memory
int offset = 0;

vector<Var> storage;
unordered_map<string, int> vars;
vector<string> current_type_vars;
vector<pair<int, int>> current_dimensions;
%}



%error-verbose

%union
{
    char * str_val;
    char char_val;
    int int_val;

    struct NodeStruct *node;
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
%type <node> Stmt Stmts Expr Bool OrTerm AndTerm RelExpr Term Factor Reference

%%

// Procedures:
//     Procedures Procedure
//     | Procedure

Procedure:
    PROCEDURE NAME LEFTBRACE Decls Stmts RIGHTBRACE
    {
        storage.push_back(Var($2, to_string(offset), $1, vector<pair<int, int>>()));
        vars[$2] = storage.size() - 1;
        offset += sizeof($2);

        execute($5);
    }
    ;

Decls:
    Decls Decl
    | Decl
    ;

Decl:
    Type SpecList SEMICOLON
    {
        for (auto it = current_type_vars.begin(); it != current_type_vars.end(); ++it)
        {
            storage[vars[*it]].type = $1;
        }
        current_type_vars = vector<string>();
    }
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
        if (vars.count($1) > 0)
        {
            yyerror(("error: " + string($1) + " is declared more than once").c_str());
        }
        else
        {
            string reg = "r" + to_string(reg_id++);
            storage.push_back(Var($1, reg, "type_name", current_dimensions));
            vars[$1] = storage.size() - 1;
            current_type_vars.push_back($1);
        }
        current_dimensions = vector<pair<int, int>>();
    }
    | NAME
    {
        if (vars.count($1) > 0)
        {
            yyerror(("error: " + string($1) + " is declared more than once").c_str());
        }
        else
        {
            string reg = "r" + to_string(reg_id++);
            storage.push_back(Var($1, reg, "type_name", vector<pair<int, int>>()));
            vars[$1] = storage.size() - 1;
            current_type_vars.push_back($1);
        }
    }
    ;

Bounds:
    Bounds COMMA Bound
    | Bound
    ;

Bound:
    NUMBER COLON NUMBER { current_dimensions.push_back(make_pair($1, $3)); }
    ;

Stmts:
    Stmts Stmt
    | Stmt
    ;

Stmt:
    Reference BIND Expr SEMICOLON { $$ = create_op(BIND, 2, $1, $3); }
    | LEFTBRACE Stmts RIGHTBRACE { $$= $2; }
    | WHILE LEFTPARENTHESIS Bool RIGHTPARENTHESIS LEFTBRACE Stmts RIGHTBRACE { $$ = create_op(WHILE, 2, $3, $6); }
    | FOR NAME BIND Expr TO Expr BY Expr LEFTBRACE Stmts RIGHTBRACE { $$ = create_op(FOR, 5, $2, $4, $6, $8, $10); }
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
    NAME LEFTBRACKET Exprs RIGHTBRACKET { int d[10]; $$ = get_var($1, 0, d); }
    | NAME { int d[10]; $$ = get_var($1, 0, d); }
    ;

Exprs:
    Expr COMMA Exprs
    | Expr
    ;

%%



int parser(char * filename)
{
    printf("\n");

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
    }
    else
    {
        printf("No file is specified. The program will read from stdin.\n");
    }

    do
    {
        yyparse();
    }
    while (!feof(yyin));

    if (error_count == 0)
        printf("\nSuccess\n\n");
    else
        printf("\n%d error%s generated\n\n", error_count, (error_count==1)? "": "s");

    print_storage();

    return 0;
}


void yyerror(const char * s) 
{
    fprintf(stderr, "Syntax error at line %d: %s\n", line_count, s);
    error_count++;
}

void print_storage()
{
    cout << "Storage Layout" << endl;
    cout << "Name      Addr      Type      Dimensions" << endl;
    for (auto it = storage.begin(); it != storage.end(); ++it)
    {
        printf("%-10s%-10s%-10s", it->name.c_str(), it->addr.c_str(), it->type.c_str());
        for (auto it2 = it->dimensions.begin(); it2 != it->dimensions.end(); ++it2)
            printf("%d:%d ", it2->first, it2->second);
        printf("\n");
    }
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

Node * create_var(char * name, char * type)
{
    Node * p;
    p = (Node *)malloc(sizeof(Node));
    p->type = NodeTypeVar;
    p->var.name = strdup(name);
    p->var.type = strdup(type);
    sprintf(p->var.reg, "r%d", reg_id++);
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

Node * get_var(char * name, int dimensions, int d[])
{
    return nullptr;
}
