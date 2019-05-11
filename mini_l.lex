/* cs152-spring2019 */
   /* A flex scanner speicification for the mini-lex language */
   /* Based on code given in lab by Dennis Jeffrey */
   /* Written by Kim Wu, Alic Lien*/

/* Item Counters */
%{
  #include "y.tab.h"
  
  int currLine = 1, currPos = 1;
  int numChar = 0;
  int numNumbers = 0;
  int numOperators = 0;
  int numParens = 0;
  int numEquals = 0;
%}

/* Input digits and characters */
DIGIT [0-9]
DIGIT_UNDERSCORE [0-9_]
LETTER [a-zA-Z]
LETTER_UNDERSCORE [a-zA-Z_]
CHAR [0-9a-zA-Z_]
ALPHANUMBER [0-9a-zA-Z]

%%

"-"             {currPos += yyleng; return SUB;} //return SUB; currPos++;
"+"             {currPos += yyleng; return ADD;} //return ADD; currPos++;
"*"             {currPos += yyleng; return MULT;} //return MULT; currPos++;
"/"             {currPos += yyleng; return DIV;} //return DIV; currPos++;
"%"             {currPos += yyleng; return MOD;} //return MOD; currPos++;

"("             {currPos += yyleng; return L_PAREN;}
")"             {currPos += yyleng; return R_PAREN;}
"["             {currPos += yyleng; return L_SQUARE_BRACKET;}
"]"             {currPos += yyleng; return R_SQUARE_BRACKET;}

">"             {currPos += yyleng; return GT;}
">="            {currPos += yyleng; return GTE;}
"<"             {currPos += yyleng; return LT;}
"<="            {currPos += yyleng; return LTE;}
"=="            {currPos += yyleng; return EQ;}
"<>"            {currPos += yyleng; return NEQ;}

";"             {currPos += yyleng; return SEMICOLON;}
":"             {currPos += yyleng; return COLON;}
","             {currPos += yyleng; return COMMA;}
":="            {currPos += yyleng; return ASSIGN;}

"function"     {currPos += yyleng; return FUNCTION;}
"beginparams"  {currPos += yyleng; return BEGIN_PARAMS;}
"endparams"    {currPos += yyleng; return END_PARAMS;}
"beginlocals"  {currPos += yyleng; return BEGIN_LOCALS;}
"endlocals"    {currPos += yyleng; return END_LOCALS;}
"beginbody"    {currPos += yyleng; return BEGIN_BODY;}
"endbody"      {currPos += yyleng; return END_BODY;}
"integer"      {currPos += yyleng; return INTEGER;}
"array"        {currPos += yyleng; return ARRAY;}
"of"           {currPos += yyleng; return OF;}
"if"           {currPos += yyleng; return IF;}
"then"         {currPos += yyleng; return THEN;}
"endif"        {currPos += yyleng; return ENDIF;}
"else"         {currPos += yyleng; return ELSE;}
"while"        {currPos += yyleng; return WHILE;}
"do"           {currPos += yyleng; return DO;}
"foreach"      {currPos += yyleng; return FOREACH;}
"in"           {currPos += yyleng; return IN;}
"beginloop"    {currPos += yyleng; return BEGINLOOP;}
"endloop"      {currPos += yyleng; return ENDLOOP;}
"continue"     {currPos += yyleng; return CONTINUE;}
"read"         {currPos += yyleng; return READ;}
"write"        {currPos += yyleng; return WRITE;}
"and"          {currPos += yyleng; return AND;}
"or"           {currPos += yyleng; return OR;}
"not"          {currPos += yyleng; return NOT;}
"true"         {currPos += yyleng; return TRUE;}
"false"        {currPos += yyleng; return FALSE;}
"return"       {currPos += yyleng; return RETURN;}

({DIGIT}+) {
    currPos += yyleng;
    yylval.ival = atoi(yytext);
    numNumbers++;
    return NUMBER;
}

{LETTER}({CHAR}*{ALPHANUMBER}+)? {
    currPos += yyleng;
    yylval.cval = yytext;
    numChar++;
    return IDENT;
}

({DIGIT}+{LETTER_UNDERSCORE}{CHAR}*)|("_"{CHAR}+) {
    printf("Error line %d, position %d: identifier \"%s\" must begin with a letter.\n", currLine, currPos, yytext);
    exit(1);
}

{LETTER}({CHAR}*{ALPHANUMBER}+)?"_"  {
    printf("Error line %d, position %d: identifier \"%s\" cannot end with an underscore.\n", currLine, currPos, yytext);
    exit(1);
}

(\.{DIGIT}+)|({DIGIT}+(\.{DIGIT}*)?([eE][+-]?[0-9]+)?) {
   currPos += yyleng; 
   yylval.dval = atof(yytext); 
   numNumbers++; 
   return NUMBER;
}

[ \t]+           {/* ignore spaces */ currPos += yyleng;}

"##".*           {currLine++; currPos = 1;}

"\n"             {currLine++; currPos = 1;}

.                {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", currLine, currPos, yytext); exit(0);}

%%