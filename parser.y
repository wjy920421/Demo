%{
#include <iostream>
#include <stdio.h>
#include <stdlib.h>

using namespace std;

extern int yylex();
extern int yyparse();
extern FILE * yyin;
extern int line_count;
 
int parser(char * filename);
void yyerror(const char *s);
int error_count = 0;
%}



%error-verbose

%union
{
    char * name;
    int number;
    char charconst;

    char * type;
}

%token <name> NAME "name"
%token <number> NUMBER "number"
%token <charconst> CHARCONST "char const"

/* Reserved words */
%token AND "and(keyword)"
%token BY "by(keyword)"
%token <type> CHAR "char(keyword)"
%token ELSE "else(keyword)"
%token FOR "for(keyword)"
%token IF "if(keyword)"
%token <type> INT "int(keyword)"
%token NOT "not(keyword)"
%token OR "or(keyword)"
%token PROCEDURE "procedure(keyword)"
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

%type <type> Type

%%

// Procedures:
//     Procedures Procedure
//     | Procedure

Procedure:
    PROCEDURE NAME LEFTBRACE Decls Stmts RIGHTBRACE
    ;

Decls:
    Decls Decl
    | Decl
    ;

Decl:
    Type SpecList SEMICOLON
    {
        cout << "Type: " << $1 << endl; 
        //cout << "SpecList: " << $2 << endl;
        //cout << "SEMICOLON: " << $3 << endl << endl;
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
    | NAME
    ;

Bounds:
    Bounds COMMA Bound
    | Bound
    ;

Bound:
    NUMBER COLON NUMBER
    ;

Stmts:
    Stmts Stmt
    | Stmt
    ;

Stmt:
    Reference BIND Expr SEMICOLON
    | LEFTBRACE Stmts RIGHTBRACE
    | WHILE LEFTPARENTHESIS Bool RIGHTPARENTHESIS LEFTBRACE Stmts RIGHTBRACE
    | FOR NAME BIND Expr TO Expr BY Expr LEFTBRACE Stmts RIGHTBRACE
    | IF LEFTPARENTHESIS Bool RIGHTPARENTHESIS THEN Stmt %prec IFX
    | IF LEFTPARENTHESIS Bool RIGHTPARENTHESIS THEN Stmt ELSE Stmt
    | READ Reference SEMICOLON
    | WRITE Expr SEMICOLON
    | SEMICOLON { yyerror("syntax error, unexpected ;, empty statement"); }
    | LEFTBRACE RIGHTBRACE { yyerror("syntax error, unexpected ;, empty statement list"); }
    | error SEMICOLON
    | error RIGHTBRACE
    ;

Bool:
    NOT OrTerm
    | OrTerm
    ;

OrTerm:
    OrTerm OR AndTerm
    | AndTerm
    ;

AndTerm:
    AndTerm AND RelExpr
    | RelExpr
    ;

RelExpr:
    RelExpr OP_LESSTHAN Expr
    | RelExpr OP_LESSTHANEQUALS Expr
    | RelExpr OP_EQUALS Expr
    | RelExpr OP_NOTEQUALS Expr
    | RelExpr OP_GREATERTHAN Expr
    | RelExpr OP_GREATERTHANEQUALS Expr
    | Expr
    ;

Expr:
    Expr OP_PLUS Term
    | Expr OP_MINUS Term
    | Term
    ;

Term:
    Term OP_TIMES Factor
    | Term OP_DIVIDE Factor
    | Factor //{ printf("Term"); }
    ;

Factor:
    LEFTPARENTHESIS Expr RIGHTPARENTHESIS
    | Reference
    | NUMBER //{ printf("Number: %d\n", $1); }
    | CHARCONST
    ;

Reference:
    NAME LEFTBRACKET Exprs RIGHTBRACKET
    | NAME
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

    return 0;
}


void yyerror(const char * s) 
{
    fprintf(stderr, "Syntax error at line %d: %s\n", line_count, s);
    error_count++;
}


