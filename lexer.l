%{
#include <stdio.h>
#include "parser.tab.h"

extern int line_count;

#define YY_DECL extern int yylex()
%}


%%
[ \t]           ;
[\n]            { line_count++; }
(\/\/.*\n)      { line_count++; }

"and"           { return AND; }
"by"            { return BY; }
"char"          { return CHAR; }
"else"          { return ELSE; }
"for"           { return FOR; }
"if"            { return IF; }
"int"           { return INT; }
"not"           { return NOT; }
"or"            { return OR; }
"procedure"     { yylval.str_val = strdup(yytext); return PROCEDURE; }
"read"          { return READ; }
"then"          { return THEN; }
"to"            { return TO; }
"while"         { return WHILE; }
"write"         { return WRITE; }

"+"             { return OP_PLUS; }
"-"             { return OP_MINUS; }
"*"             { return OP_TIMES; }
"/"             { return OP_DIVIDE; }
"<"             { return OP_LESSTHAN; }
"<="            { return OP_LESSTHANEQUALS; }
"=="            { return OP_EQUALS; }
"!="            { return OP_NOTEQUALS; }
">"             { return OP_GREATERTHAN; }
">="            { return OP_GREATERTHANEQUALS; }

":"             { return COLON; }
";"             { return SEMICOLON; }
","             { return COMMA; }
"="             { return BIND; }
"{"             { return LEFTBRACE; }
"}"             { return RIGHTBRACE; }
"["             { return LEFTBRACKET; }
"]"             { return RIGHTBRACKET; }
"("             { return LEFTPARENTHESIS; }
")"             { return RIGHTPARENTHESIS; }

[A-Za-z][A-Za-z0-9]*            { yylval.str_val = strdup(yytext); return NAME; }
[0-9]+                          { yylval.int_val = atoi(yytext); return NUMBER; }
'((\\[aefnrtv])|[\x00-\x7F])'   { yylval.char_val = yytext[1]; return CHARCONST; }

.                               { return OTHER; }

%%


