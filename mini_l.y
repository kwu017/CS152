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
%start program //change from input

%token <ival> ID

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


%% /*
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
    */
//grammar goes here
program:
            {printf("program -> ε\n");}
            | function program
            {printf("program -> function program\n");}
;

function: FUNCTION id SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_LOCALS BEGIN_BODY statements END_BODY
            {printf("program -> FUNCTION id SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_LOCALS BEGIN_BODY statements END_BODY\n");}
;

declaration: ID COLON INTEGER
            {printf("declaration -> ID COLON INTEGER\n");}
            | id COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER
            {printf("declaration -> ID COLON ARRAY L_SQUARE_BRACKET NUMBER %d R_SQUARE_BRACKET OF INTEGER\n ", $5);}
;

declarations:
            {printf("declarations -> ε\n");}
            | declaration SEMICOLON declarations
            {printf("declarations -> declaration SEMICOLON declarations\n");}
;

identifiers: id
            {printf("identifiers -> id\n");}
            | id COMMA identifiers
            {printf("identifiers -> id COMMA identifiers\n");}
;

statements: statement SEMICOLON statements
            {printf("statements -> statement SEMICOLON statements\n");}
            | statement SEMICOLON
            {printf("statements -> statement SEMICOLON\n");}
;

statement: var ASSIGN expression
            {printf("statement -> var ASSIGN expression\n");}
            | IF boolExp THEN statements elseStatement ENDIF
            {printf("statement -> IF boolExp THEN statements elseStatement ENDIF\n");}
            | WHILE boolExp BEGINLOOP statements ENDLOOP
            {printf("statement -> WHILE boolEXP BEGINLOOP statements ENDLOOP\n");}
            | DO BEGINLOOP statements ENDLOOP WHILE boolExp
            {printf("statement -> DO BEGINLOOP statementsENDLOOP WHILE boolExp\n");}
            | FOREACH id IN id BEGINLOOP statements ENDLOOP
            {printf("statement -> FOREACH id IN id BEGINLOOP statements ENDLOOP\n");}
            | READ vars
            {printf("statement -> READ vars\n");}
            | WRITE vars
            {printf("statement -> WRITE vars\n");}
            | CONTINUE
            {printf("statement -> CONTINUE\n");}
            | RETURN expression
            {printf("statement -> RETURN expression\n");}
;

elseStatement:
            {printf("elseStatement -> ε\n");}
            | ELSE statements
            {printf("elseStatement -> ELSE statements\n");}
;

var: id L_SQUARE_BRACKET expression R_SQUARE_BRACKET
            {printf("var -> id L_SQUARE_BRACKET expression R_SQUARE_BRACKET\n");}
            | id
            {printf("var -> id\n");}
;

vars: var
            {printf("vars -> var\n");}
            | var COMMA vars
            {printf("vars -> var COMMA vars\n");}
;

expression: multExp
            {printf("expression -> multExp\n");}
            | multExp ADD expression
            {printf("expression -> multExp ADD expression\n");}
            | multExp SUB expression
            {printf("expression -> multExp SUB expression\n");}
;

expressions:
            {printf("expressions -> ε\n");}
            | expression COMMA expressions
            {printf("expressions -> expression COMMA expressions\n");}
            | expression
            {printf("expressions -> expression\n");}
;

multExp: term
            {printf("multExp -> term\n");}
            | term MULT multExp
            {printf("multExp -> term MULT multExp\n");}
            | term DIV multExp
            {printf("multExp -> term DIV multExp\n");}
            | term MOD multExp
            {printf("multExp -> term MOD multExp\n");}
;

term: var
            {printf("term -> Var\n");}
            | SUB var
            {printf("term -> SUB var\n");}
            | NUMBER
            {printf("term -> NUMBER %d\n", $1);}
            | SUB NUMBER
            {printf("term -> SUB NUMBER %d\n", $2);}
            | L_PAREN Expression R_PAREN
            {printf("term -> L_PAREN expression R_PAREN\n");}
            | SUB L_PAREN expression R_PAREN
            {printf("term -> SUB L_PAREN expression R_PAREN\n");}
            | id L_PAREN expressions R_PAREN
            {printf("term -> id L_PAREN expressions R_PAREN\n");}
;

boolExp: relaExp
            {printf("bool_exp -> relation-expr\n");}
            | relaExp OR boolExp
            {printf("bool_exp -> relation-and-expr OR bool_exp\n");}
;

relaExp: rExp
            {printf("relation-and-expr -> relation-exp\n");}
            | rExp AND relaExp
            {printf("relation-and-expr -> relation-exp AND relation-and-exp\n");}
;

rExp: NOT rExp1
            {printf("relation-exp -> NOT relation-exp1\n");}
            | rExp1
            {printf("relation-exp -> relation-exp1\n");}

;

rExp1: expression comp expression
            {printf("relation-exp -> expression comp expression\n");}
            | TRUE
            {printf("relation-exp -> TRUE\n");}
            | FALSE
            {printf("relation-exp -> FALSE\n");}
            | L_PAREN boolExp R_PAREN
            {printf("relation-exp -> L_PAREN boolExp R_PAREN\n");}
;

comp: EQ
            {printf("comp -> EQ\n");}
            | NEQ
            {printf("comp -> NEQ\n");}
            | LT
            {printf("comp -> LT\n");}
            | GT
            {printf("comp -> GT\n");}
            | LTE
            {printf("comp -> LTE\n");}
            | GTE
            {printf("comp -> GTE\n");}
;

id:     ID
            {printf("id -> ID %s \n", $1);}
;
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

