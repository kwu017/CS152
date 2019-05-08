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
DIGIT    [0-9]
DIGIT_UNDERSCORE [0-9_]
LETTER   [a-zA-Z]
LETTER_UNDERSCORE [a-zA-Z_]
CHAR [0-9a-zA-Z_]
ALPHANUMBER [0-9a-zA-Z]

%%

"-"            {currPos += yyleng; numOperators++; return SUB;}
"+"            {currPos += yyleng; numOperators++; return ADD;}
"*"            {currPos += yyleng; numOperators++; return MULT;}
"/"            {currPos += yyleng; numOperators++; return DIV;}
"%"            {currPos += yyleng; numOperators++; return MOD;}

"("            {currPos += yyleng; numParens++; return L_PAREN;}
")"            {currPos += yyleng; numParens++; return R_PAREN;}
"["            {currPos += yyleng; numParens++; return L_SQUARE_BRACKET;}
"]"            {currPos += yyleng; numParens++; return R_SQUARE_BRACKET;}

">"            {currPos += yyleng; numOperators++; return GT;}
">="           {currPos += yyleng; numOperators++; return GTE;}
"<"            {currPos += yyleng; numOperators++; return LT;}
"<="           {currPos += yyleng; numOperators++; return LTE;}
"=="           {currPos += yyleng; numOperators++; return EQ;}
"<>"           {currPos += yyleng; numOperators++; return NEQ;}

";"            {currPos += yyleng; numOperators++; return SEMICOLON;}
":"            {currPos += yyleng; numOperators++; return COLON;}
","            {currPos += yyleng; numOperators++; return COMMA;}
":="           {currPos += yyleng; numOperators++; return ASSIGN;}
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
    yylval.dval = atof(yytext);
    numNumbers++;
    return NUMBER;
}

{LETTER}({CHAR}*{ALPHANUMBER}+)? {
    currPos += yyleng;
    yylval.cval = yytext;
    numChar++;
    return CHARACTER;
}

({DIGIT+{LETTER_UNDERSCORE}{CHAR}*)|("_"{CHAR}+) {
   printf("Error line %d, position %d: identifier \"%s\" must begin with a letter.\n", currLine, currPos, yytext);
   exit(1);
}

{LETTER}({CHAR}*{ALPHANUMBER}+)?"_" {
   printf("Error line %d, position %d: identifier \"%s\" cannot end with an underscore.\n", currLine, currpos, yytext);
   exit(1);
}

(\.{DIGIT}+)|({DIGIT}+(\.{DIGIT}*)?([eE][+-]?[0-9]+)?) {
   currPos += yyleng;
   yylval.dval = atof(yytext);
   numNumbers++;
   return NUMBER;
}

[ \t]+         {/* ignore spaces */ currPos += yyleng;}

"\n"           {currLine++; currPos = 1; return END;}

.              {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", currLine, currPos, yytext); exit(0);}

%%