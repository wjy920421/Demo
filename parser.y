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






nodeType *opr(int oper, int nops, ...);
nodeType *id(char * i);
nodeType *con(int value);
void freeNode(nodeType *p);
int ex(nodeType *p);
int sym[26];

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

// Variables
int reg_id = 1;
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

    struct nodeTypeTag *nPtr;
}

%token <str_val> NAME "name"
%token <int_val> NUMBER "number"
%token <char_val> CHARCONST "char const"

/* Reserved words */
%token AND "and(keyword)"
%token BY "by(keyword)"
%token <str_val> CHAR "char(keyword)"
%token ELSE "else(keyword)"
%token FOR "for(keyword)"
%token IF "if(keyword)"
%token <str_val> INT "int(keyword)"
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
%type <nPtr> Stmt Stmts Expr Bool OrTerm AndTerm RelExpr Term Factor Reference

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

        ex($5);
        freeNode($5);
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
    INT { $$ = $1; }
    | CHAR { $$ = $1; }
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
    Reference BIND Expr SEMICOLON { $$ = opr(BIND, 2, $1, $3); }
    | LEFTBRACE Stmts RIGHTBRACE { $$= $2; }
    | WHILE LEFTPARENTHESIS Bool RIGHTPARENTHESIS LEFTBRACE Stmts RIGHTBRACE { $$ = opr(WHILE, 2, $3, $6); }
    | FOR NAME BIND Expr TO Expr BY Expr LEFTBRACE Stmts RIGHTBRACE { $$ = opr(FOR, 5, $2, $4, $6, $8, $10); }
    | IF LEFTPARENTHESIS Bool RIGHTPARENTHESIS THEN Stmt %prec IFX { $$ = opr(IF, 2, $3, $6); }
    | IF LEFTPARENTHESIS Bool RIGHTPARENTHESIS THEN Stmt ELSE Stmt { $$ = opr(IF, 3, $3, $6, $8); }
    | READ Reference SEMICOLON { $$ = opr(READ, 1, $2); }
    | WRITE Expr SEMICOLON { $$ = opr(WRITE, 1, $2); }
    | SEMICOLON { yyerror("syntax error, unexpected ;, empty statement"); }
    | LEFTBRACE RIGHTBRACE { yyerror("syntax error, unexpected ;, empty statement list"); }
    | error SEMICOLON { $$ = nullptr; }
    | error RIGHTBRACE { $$ = nullptr; }
    ;

Bool:
    NOT OrTerm { $$ = opr(NOT, 1, $2); }
    | OrTerm { $$ = $1; }
    ;

OrTerm:
    OrTerm OR AndTerm { $$ = opr(OR, 2, $1, $3); }
    | AndTerm  { $$ = $1; }
    ;

AndTerm:
    AndTerm AND RelExpr { $$ = opr(AND, 2, $1, $3); }
    | RelExpr  { $$ = $1; }
    ;

RelExpr:
    RelExpr OP_LESSTHAN Expr { $$ = opr(OP_LESSTHAN, 2, $1, $3); }
    | RelExpr OP_LESSTHANEQUALS Expr { $$ = opr(OP_LESSTHANEQUALS, 2, $1, $3); }
    | RelExpr OP_EQUALS Expr { $$ = opr(OP_EQUALS, 2, $1, $3); }
    | RelExpr OP_NOTEQUALS Expr { $$ = opr(OP_NOTEQUALS, 2, $1, $3); }
    | RelExpr OP_GREATERTHAN Expr { $$ = opr(OP_GREATERTHAN, 2, $1, $3); }
    | RelExpr OP_GREATERTHANEQUALS Expr { $$ = opr(OP_GREATERTHANEQUALS, 2, $1, $3); }
    | Expr { $$ = $1; }
    ;

Expr:
    Expr OP_PLUS Term { $$ = opr(OP_PLUS, 2, $1, $3); }
    | Expr OP_MINUS Term { $$ = opr(OP_MINUS, 2, $1, $3); }
    | Term { $$ = $1; }
    ;

Term:
    Term OP_TIMES Factor { $$ = opr(OP_TIMES, 2, $1, $3); }
    | Term OP_DIVIDE Factor { $$ = opr(OP_DIVIDE, 2, $1, $3); }
    | Factor { $$ = $1; }
    ;

Factor:
    LEFTPARENTHESIS Expr RIGHTPARENTHESIS { $$ = $2; }
    | Reference { $$ = $1; }
    | NUMBER  { $$ = con($1); }
    | CHARCONST { $$ = con(123); }
    ;

Reference:
    NAME LEFTBRACKET Exprs RIGHTBRACKET { $$ = id($1); }
    | NAME { $$ = id($1); }
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

nodeType *con(int value)
{
    nodeType *p;
    if ((p = (nodeType *)malloc(sizeof(nodeType))) == NULL)
    yyerror("out of memory");
    /* copy information */
    p->type = typeCon;
        p->con.value = value;
    return p;
}

nodeType *id(char * i)
{
    nodeType *p;
    /* allocate node */
    if ((p = (nodeType *)malloc(sizeof(nodeType))) == NULL)
    /* copy information */
    p->type = typeId;
    p->id.i = strdup(i);
    return p;
}

nodeType *opr(int oper, int nops, ...)
{
    va_list ap;
    nodeType *p;
    int i;
    /* allocate node */
    if ((p = (nodeType *)malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");
    if ((p->opr.op = (nodeType **)malloc(nops * sizeof(nodeType *))) == NULL)
        yyerror("out of memory");
    /* copy information */
    p->type = typeOpr;
    p->opr.oper = oper;
    p->opr.nops = nops;
    va_start(ap, nops);
    for (i = 0; i < nops; i++)
        p->opr.op[i] = va_arg(ap, nodeType*);
    va_end(ap);
    return p;
}

void freeNode(nodeType *p)
{
}

