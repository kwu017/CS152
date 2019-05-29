/* cs152-spring2019 */
   /* A flex scanner speicification for the mini-lex language */
   /* Based on code given in lab by Dennis Jeffrey */
   /* Written by Kim Wu, Alic Lien*/

/* Item Counters */
%{
    #include <iostream>
    #define YY_DECL yy::parser::symbol_type yylex()
    #include "parser.tab.h"
    
    using namespace std;

	static yy::location loc;
  
    int currLine = 1, currPos = 1;
    int numChar = 0;
    int numNumbers = 0;
%}

%option noyywrap

%{
	#define YY_USER_ACTION loc.columns(yyleng);
%}

/* Input digits and characters */
DIGIT [0-9]
DIGIT_UNDERSCORE [0-9_]
LETTER [a-zA-Z]
LETTER_UNDERSCORE [a-zA-Z_]
CHAR [0-9a-zA-Z_]
ALPHANUMBER [0-9a-zA-Z]

%%

%{
    loc.step(); 
%}

"-"             {currPos += yyleng; return yy::parser::make_SUB(loc);} //return SUB; currPos++;
"+"             {currPos += yyleng; return yy::parser::make_ADD(loc);} //return ADD; currPos++;
"*"             {currPos += yyleng; return yy::parser::make_MULT(loc);} //return MULT; currPos++;
"/"             {currPos += yyleng; return yy::parser::make_DIV(loc);} //return DIV; currPos++;
"%"             {currPos += yyleng; return yy::parser::make_MOD(loc);} //return MOD; currPos++;

"("             {currPos += yyleng; return yy::parser::make_L_PAREN(loc);}
")"             {currPos += yyleng; return yy::parser::make_R_PAREN(loc);}
"["             {currPos += yyleng; return yy::parser::make_L_SQUARE_BRACKET(loc);}
"]"             {currPos += yyleng; return yy::parser::make_R_SQUARE_BRACKET(loc);}

">"             {currPos += yyleng; return yy::parser::make_GT(loc);}
">="            {currPos += yyleng; return yy::parser::make_GTE(loc);}
"<"             {currPos += yyleng; return yy::parser::make_LT(loc);}
"<="            {currPos += yyleng; return yy::parser::make_LTE(loc);}
"=="            {currPos += yyleng; return yy::parser::make_EQ(loc);}
"<>"            {currPos += yyleng; return yy::parser::make_NEQ(loc);}

";"             {currPos += yyleng; return yy::parser::make_SEMICOLON(loc);}
":"             {currPos += yyleng; return yy::parser::make_COLON(loc);}
","             {currPos += yyleng; return yy::parser::make_COMMA(loc);}
":="            {currPos += yyleng; return yy::parser::make_ASSIGN(loc);}

"function"      {currPos += yyleng; return yy::parser::make_FUNCTION(loc);}
"beginparams"   {currPos += yyleng; return yy::parser::make_BEGIN_PARAMS(loc);}
"endparams"     {currPos += yyleng; return yy::parser::make_END_PARAMS(loc);}
"beginlocals"   {currPos += yyleng; return yy::parser::make_BEGIN_LOCALS(loc);}
"endlocals"     {currPos += yyleng; return yy::parser::make_END_LOCALS(loc);}
"beginbody"     {currPos += yyleng; return yy::parser::make_BEGIN_BODY(loc);}
"endbody"       {currPos += yyleng; return yy::parser::make_END_BODY(loc);}
"integer"       {currPos += yyleng; return yy::parser::make_INTEGER(loc);}
"array"         {currPos += yyleng; return yy::parser::make_ARRAY(loc);}
"of"            {currPos += yyleng; return yy::parser::make_OF(loc);}
"if"            {currPos += yyleng; return yy::parser::make_IF(loc);}
"then"          {currPos += yyleng; return yy::parser::make_THEN(loc);}
"endif"         {currPos += yyleng; return yy::parser::make_ENDIF(loc);}
"else"          {currPos += yyleng; return yy::parser::make_ELSE(loc);}
"while"         {currPos += yyleng; return yy::parser::make_WHILE(loc);}
"do"            {currPos += yyleng; return yy::parser::make_DO(loc);}
"foreach"       {currPos += yyleng; return yy::parser::make_FOREACH(loc);}
"in"            {currPos += yyleng; return yy::parser::make_IN(loc);}
"beginloop"     {currPos += yyleng; return yy::parser::make_BEGINLOOP(loc);}
"endloop"       {currPos += yyleng; return yy::parser::make_ENDLOOP(loc);}
"continue"      {currPos += yyleng; return yy::parser::make_CONTINUE(loc);}
"read"          {currPos += yyleng; return yy::parser::make_READ(loc);}
"write"         {currPos += yyleng; return yy::parser::make_WRITE(loc);}
"and"           {currPos += yyleng; return yy::parser::make_AND(loc);}
"or"            {currPos += yyleng; return yy::parser::make_OR(loc);}
"not"           {currPos += yyleng; return yy::parser::make_NOT(loc);}
"true"          {currPos += yyleng; return yy::parser::make_TRUE(loc);}
"false"         {currPos += yyleng; return yy::parser::make_FALSE(loc);}
"return"        {currPos += yyleng; return yy::parser::make_RETURN(loc);}

({DIGIT}+) {
    currPos += yyleng;
    return yy::parser::make_NUMBER(yytext, loc);
}

{LETTER}({CHAR}*{ALPHANUMBER}+)? {
    currPos += yyleng;
    return yy::parser::make_IDENT(yytext, loc);
}

({DIGIT}+{LETTER_UNDERSCORE}{CHAR}*)|("_"{CHAR}+) {
    printf("Error line %d, position %d: identifier \"%s\" must begin with a letter.\n", currLine, currPos, yytext);
    exit(1);
}

{LETTER}({CHAR}*{ALPHANUMBER}+)?"_"  {
    printf("Error line %d, position %d: identifier \"%s\" cannot end with an underscore.\n", currLine, currPos, yytext);
    exit(1);
}

[ \t]+           {/* ignore spaces */ currPos += yyleng;}

"##".*           {currLine++; currPos = 1;}

"\n"             {currLine++; currPos = 1;}

.                {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", currLine, currPos, yytext); exit(0);}

<<EOF>>	{return yy::parser::make_END(loc);}

%%
