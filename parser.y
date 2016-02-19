%{
#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern int yyparse();
extern FILE * yyin;
extern int line_count;
 
int parser(char * filename);
void yyerror(const char *s);
%}



%error-verbose

%union
{
    char * name;
    int number;
    char * charconst;
}

%token <name> NAME
%token <number> NUMBER
%token <charconst> CHARCONST

/* Reserved words */
%token AND
%token BY
%token CHAR
%token ELSE
%token FOR
%token IF
%token INT
%token NOT
%token OR
%token PROCEDURE
%token READ
%token THEN
%token TO
%token WHILE
%token WRITE

/* Operators */
%token OP_PLUS
%token OP_MINUS
%token OP_TIMES
%token OP_DIVIDE
%token OP_LESSTHAN
%token OP_LESSTHANEQUALS
%token OP_EQUALS
%token OP_NOTEQUALS
%token OP_GREATERTHAN
%token OP_GREATERTHANEQUALS

/* Punctuation */
%token COLON
%token SEMICOLON
%token COMMA
%token BIND
%token LEFTBRACE
%token RIGHTBRACE
%token LEFTBRACKET
%token RIGHTBRACKET
%token LEFTPARENTHESIS
%token RIGHTPARENTHESIS

%token OTHER

%nonassoc IFX
%nonassoc ELSE



%%

Procedure:
    PROCEDURE NAME LEFTBRACE Decls Stmts RIGHTBRACE
    ;

Decls:
    Decls Decl SEMICOLON
    | Decl SEMICOLON
    ;

Decl:
    Type SpecList
    ;

Type:
    INT
    | CHAR
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

    printf("Success\n");

    return 0;
}


void yyerror(const char * s) 
{
    fprintf(stderr, "Syntax error at line %d: %s\n", line_count, s);
    exit(-1);
}


