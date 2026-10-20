%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_SYMBOLS 500
#define MAX_NAME_LEN 256

typedef struct {
    char name[MAX_NAME_LEN];
    char type[16];
    char value[16];
} Symbol;

static Symbol symbol_table[MAX_SYMBOLS];
static int symbol_count = 0;

static void add_symbol(const char *name) {
    int i;
    for (i = 0; i < symbol_count; ++i) {
        if (strcmp(symbol_table[i].name, name) == 0) {
            return; /* Keep identifiers unique in the symbol table. */
        }
    }

    if (symbol_count >= MAX_SYMBOLS) {
        fprintf(stderr, "Warning: symbol table is full; cannot add '%s'\n", name);
        return;
    }

    snprintf(symbol_table[symbol_count].name,
             sizeof(symbol_table[symbol_count].name), "%s", name);
    snprintf(symbol_table[symbol_count].type,
             sizeof(symbol_table[symbol_count].type), "%s", "Identifier");
    snprintf(symbol_table[symbol_count].value,
             sizeof(symbol_table[symbol_count].value), "%s", "-");
    ++symbol_count;
}

static void print_token(const char *lexeme, const char *category) {
    printf("%-28s %s\n", lexeme, category);
}
%}

%option noyywrap
%x COMMENT

LETTER      [A-Za-z_]
ID_START    [A-Za-z_]
ID_CONT     [A-Za-z0-9_]
IDENTIFIER  {ID_START}{ID_CONT}*
INTEGER     [0-9]+
FLOATNUM    (([0-9]+"."[0-9]*|"."[0-9]+)([eE][+-]?[0-9]+)?|[0-9]+[eE][+-]?[0-9]+)
STRING      \"([^\\\n]|\\.)*\"
CHARLIT     \'([^\\\n]|\\.)\'

%%
^[ \t]*"#include"[ \t]*[<"][^>\"]+[>\"][ \t]*   { print_token(yytext, "Preprocessor directive"); }

"//".*                                           { /* Ignore single-line comments. */ }
"/*"                                             { BEGIN(COMMENT); }
<COMMENT>"*/"                                    { BEGIN(INITIAL); }
<COMMENT>\n                                      { /* Track newline through Flex input. */ }
<COMMENT>.                                       { /* Ignore comment content. */ }
<COMMENT><<EOF>>                                 { fprintf(stderr, "Lexical error: unterminated block comment\n"); return 0; }

"auto"|"bool"|"break"|"case"|"catch"|"char"|"class"|"const"|"continue"|"default"|"do"|"double"|"else"|"enum"|"extern"|"false"|"float"|"for"|"if"|"int"|"long"|"namespace"|"new"|"private"|"protected"|"public"|"return"|"short"|"signed"|"sizeof"|"static"|"struct"|"switch"|"template"|"this"|"throw"|"true"|"try"|"typedef"|"typename"|"union"|"unsigned"|"using"|"virtual"|"void"|"volatile"|"while"|"std" {
    print_token(yytext, "Keyword");
}

{IDENTIFIER} {
    if (yyleng > 8) {
        print_token(yytext, "Lexical error: identifier > 8 chars");
    } else {
        print_token(yytext, "Identifier");
        add_symbol(yytext);
    }
}

{FLOATNUM}                                       { print_token(yytext, "Floating constant"); }
{INTEGER}                                        { print_token(yytext, "Integer constant"); }
{STRING}                                         { print_token(yytext, "String literal"); }
{CHARLIT}                                        { print_token(yytext, "Character constant"); }

"++"|"--"|"=="|"!="|"<="|">="|"&&"|"||"|"+="|"-="|"*="|"/="|"->"|"<<"|">>" {
    print_token(yytext, "Operator");
}
[-+\*/%=<>!&|^~?:.]                              { print_token(yytext, "Operator"); }

[(){}\[\],;]                                     { print_token(yytext, "Delimiter"); }

[ \t\r\n]+                                       { /* Ignore whitespace. */ }
.                                                { print_token(yytext, "Unknown character"); }
%%

int main(int argc, char **argv) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <source.cpp>\n", argv[0]);
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (yyin == NULL) {
        perror(argv[1]);
        return 1;
    }

    printf("%-28s %s\n", "Lexeme", "Token category");
    printf("----------------------------------------------------------\n");
    yylex();

    printf("\nIdentifier Symbol Table (unique valid identifiers)\n");
    printf("%-20s %-16s %-10s\n", "Name", "Type", "Value");
    printf("------------------------------------------------\n");
    for (int i = 0; i < symbol_count; ++i) {
        printf("%-20s %-16s %-10s\n",
               symbol_table[i].name,
               symbol_table[i].type,
               symbol_table[i].value);
    }

    fclose(yyin);
    return 0;
}
