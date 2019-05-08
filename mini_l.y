/* based off of calc.y  */
%{
 #include <stdio.h>
 #include <stdlib.h>
 void yyerror(const char *msg);
 extern int currLine;
 extern int currPos;
 FILE * yyin;
%}

%union{
  double dval;
  int ival;
  char* cval;
}

%error-verbose
%start input
%token SUB ADD MULT DIV MOD END
%token L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET
%token GT GTE LT LTE EQ NEQ
%token SEMICOLON COLON COMMA ASSIGN
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY
%token OF IF THEN ENDIF ELSE WHILE DO FOREACH IN BEGINLOOP ENDLOOP CONTINUE READ WRITE AND OR NOT TRUE FALSE RETURN
%token <dval> NUMBER
%token <cval> CHARACTER
%type <dval> exp
%left SUB ADD
%left  MULT DIV MOD
%left GT GTE LT LTE EQ NEQ
%left AND OR
%right NOT
%nonassoc UMINUS


%% 
input:	
			| input line
			;

line:		exp ASSIGN END         { printf("\t%f\n", $1);}
			;

exp:		NUMBER                { $$ = $1; }
			| exp ADD exp         { $$ = $1 + $3; }
			| exp SUB exp         { $$ = $1 - $3; }
			| exp MULT exp        { $$ = $1 * $3; }
			| exp DIV exp         { if ($3==0) yyerror("divide by zero"); else $$ = $1 / $3; }
			| SUB exp %prec UMINUS { $$ = -$2; }
			| L_PAREN exp R_PAREN { $$ = $2; }
			;
//grammar goes here

%%

int main(int argc, char **argv) {
   if (argc > 1) {
      yyin = fopen(argv[1], "r");
      if (yyin == NULL){
         printf("syntax: %s filename\n", argv[0]);
      }//end if
   }//end if
   yyparse(); // Calls yylex() for tokens.
   return 0;
}

void yyerror(const char *msg) {
   printf("** Line %d, position %d: %s\n", currLine, currPos, msg);
}

