%{
#include <stdio.h>
#define YY_DECL extern int yylex()

#include "parser.tab.h"
%}


%%
[ \t\n]                 ;
(\/\/.*\n)              ;

"and"                   { return AND; }
"by"                    { return BY; }
"char"                  { return CHAR; }
"else"                  { return ELSE; }
"for"                   { return FOR; }
"if"                    { return IF; }
"int"                   { return INT; }
"not"                   { return NOT; }
"or"                    { return OR; }
"procedure"             { return PROCEDURE; }
"read"                  { return READ; }
"then"                  { return THEN; }
"to"                    { return TO; }
"while"                 { return WHILE; }
"write"                 { return WRITE; }

"+"                     { /*printf("OP_PLUS\n");*/ return OP_PLUS; }
"-"                     { return OP_MINUS; }
"*"                     { return OP_TIMES; }
"/"                     { return OP_DIVIDE; }
"<"                     { return OP_LESSTHAN; }
"<="                    { return OP_LESSTHANEQUALS; }
"=="                    { return OP_EQUALS; }
"!="                    { return OP_NOTEQUALS; }
">"                     { return OP_GREATERTHAN; }
">="                    { return OP_GREATERTHANEQUALS; }

":"                     { return COLON; }
";"                     { return SEMICOLON; }
","                     { return COMMA; }
"="                     { return BIND; }
"{"                     { return LEFTBRACE; }
"}"                     { return RIGHTBRACE; }
"["                     { return LEFTBRACKET; }
"]"                     { return RIGHTBRACKET; }
"("                     { return LEFTPARENTHESIS; }
")"                     { return RIGHTPARENTHESIS; }

[A-Za-z][A-Za-z0-9]*    { yylval.name = strdup(yytext); return NAME; }
[0-9]+                  { yylval.number = atoi(yytext); /*printf("number:%d\n", yylval.number);*/ return NUMBER; }
'.'                     { yylval.charconst = strdup(yytext); return CHARCONST; }

.                       { return OTHER; }

%%


