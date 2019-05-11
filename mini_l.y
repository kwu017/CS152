/* based off of calc.y */
%{
      #include <stdio.h>
      #include <stdlib.h>
      void yyerror(const char *msg);
      extern int currLine;
      extern int currPos;
      FILE * yyin;
      void yyerror(const char* s);
%}

%union{
      double dval;
      int ival;
      char* cval;
 }

%error-verbose
%start functions //input

%token SUB ADD MULT DIV MOD //END
%token L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET
%token GT GTE LT LTE EQ NEQ
%token SEMICOLON COLON COMMA ASSIGN
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY
%token OF IF THEN ENDIF ELSE WHILE DO FOREACH IN BEGINLOOP ENDLOOP CONTINUE READ WRITE AND OR NOT TRUE FALSE RETURN
%token <cval> IDENT
%token <ival> NUMBER

%left SUB ADD 
%left MULT DIV MOD
%left EQ NEQ LT GT LTE GTE ASSIGN
%left AND OR
%right NOT

%% /*
input:      
                  | input line
                  ;

line:       exp ASSIGN END         { printf("\t%f\n", $1);}
                  ;

exp:        NUMBER                { $$ = $1; }
                  | exp ADD exp         { $$ = $1 + $3; }
                  | exp SUB exp         { $$ = $1 - $3; }
                  | exp MULT exp        { $$ = $1 * $3; }
                  | exp DIV exp         { if ($3==0) yyerror("divide by zero"); else $$ = $1 / $3; }
                  | SUB exp %prec UMINUS { $$ = -$2; }
                  | L_PAREN exp R_PAREN { $$ = $2; }
                  ;
    */
//grammar goes here

functions:
            {printf("functions -> ε\n");}
                  | function functions
            {printf("functions -> function functions\n");}
            ;

function:   
            FUNCTION ident SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY
            {printf("function -> FUNCTION Ident SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY\n");}
            ;

declaration:
            identifiers COLON INTEGER
            {printf("declaration -> identifiers COLON INTEGER\n");}
                 | identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER
            {printf("declaration -> identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER %d R_SQUARE_BRACKET OF INTEGER;\n", $5);}
            ;

declarations:    
            {printf("declarations -> ε\n");}
                 | declaration SEMICOLON declarations
            {printf("declarations -> declaration SEMICOLON declarations\n");}
            ;

identifiers:     
            ident
            {printf("identifiers -> Ident \n");}
                 | ident COMMA identifiers
            {printf("identifiers -> ident COMMA identifiers\n");}
            ;

statements:      
            statement SEMICOLON statements
            {printf("statements -> statement SEMICOLON statements\n");}
                 | statement SEMICOLON
            {printf("statements -> statement SEMICOLON\n");}
            ;

statement:      
            variable ASSIGN expression
            {printf("statement -> variable ASSIGN expression\n");}
                 | IF bool_expr THEN statements else_statement ENDIF
            {printf("statement -> IF bool_expr THEN statements else_statement ENDIF\n");}          
                 | WHILE bool_expr BEGINLOOP statements ENDLOOP
            {printf("statement -> WHILE bool_expr BEGINLOOP statements ENDLOOP\n");}
                 | DO BEGINLOOP statements ENDLOOP WHILE bool_expr
            {printf("statement -> DO BEGINLOOP statements ENDLOOP WHILE bool_expr\n");}
                 | FOREACH ident IN ident BEGINLOOP statements ENDLOOP
            {printf("statement -> FOREACH ident IN ident BEGINLOOP statements ENDLOOP\n");}
                 | READ variables
            {printf("statement -> READ variables\n");}
                 | WRITE variables
            {printf("statement -> WRITE variables\n");}
                 | CONTINUE
            {printf("statement -> CONTINUE\n");}
                 | RETURN expression
            {printf("statement -> RETURN expression\n");}
            ;

else_statement:   
            {printf("else_statement -> ε\n");}
                 | ELSE statements
            {printf("else_statement -> ELSE statements\n");}
            ;

variable:            
            ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET
            {printf("variable -> ident  L_SQUARE_BRACKET expression R_SQUARE_BRACKET\n");}
                 | ident
            {printf("variable -> ident \n");}
            ;

variables:            
            variable
            {printf("variables -> variable\n");}
                 | variable COMMA variables
            {printf("variables -> variable COMMA variables\n");}
            ;

expression:      
            mult_expr
            {printf("expression -> mult_expr\n");}
                 | mult_expr ADD expression
            {printf("expression -> mult_expr ADD expression\n");}
                 | mult_expr SUB expression
            {printf("expression -> mult_expr SUB expression\n");}
            ;

expressions:     
            {printf("expressions -> ε\n");}
                 | expression COMMA expressions
            {printf("expressions -> expression COMMA expressions\n");}
                 | expression
            {printf("expressions -> expression\n");}
            ;

mult_expr:         
            term
            {printf("mult_expr -> term\n");}
                 | term MULT mult_expr
            {printf("mult_expr -> term MULT mult_expr\n");}
                 | term DIV mult_expr
            {printf("mult_expr -> term DIV mult_expr\n");}
                 | term MOD mult_expr
            {printf("mult_expr -> term MOD mult_expr\n");}
            ;

term:            
            variable
            {printf("term -> variable\n");}
                 | SUB variable
            {printf("term -> SUB variable\n");}
                 | NUMBER
            {printf("term -> NUMBER %d\n", $1);}
                 | SUB NUMBER
            {printf("term -> SUB NUMBER %d\n", $2);}
                 | L_PAREN expression R_PAREN
            {printf("term -> L_PAREN expression R_PAREN\n");}
                 | SUB L_PAREN expression R_PAREN
            {printf("term -> SUB L_PAREN expression R_PAREN\n");}
                 | ident L_PAREN expressions R_PAREN
            {printf("term -> ident L_PAREN expressions R_PAREN\n");}
            ;

bool_expr:         
            relation_and_expr 
            {printf("bool_expr -> relation_exp\n");}
                 | relation_and_expr OR bool_expr
            {printf("bool_expr -> relation_and_exp OR bool_expr\n");}
            ;

relation_and_expr:           
            relation_expr
            {printf("relation_and_exp -> relation_exp\n");}
                 | relation_expr AND relation_and_expr
            {printf("relation_and_exp -> relation_exp AND relation_and_exp\n");}
            ;

relation_expr:            
            NOT relation_exp 
            {printf("relation_exp -> NOT relation_exp1\n");}
                 | relation_exp
            {printf("relation_exp -> relation_exp1\n");}

            ;

relation_exp:           
            expression comp expression
            {printf("relation_exp -> expression comp expression\n");}
                 | TRUE
            {printf("relation_exp -> TRUE\n");}
                 | FALSE
            {printf("relation_exp -> FALSE\n");}
                 | L_PAREN bool_expr R_PAREN
            {printf("relation_exp -> L_PAREN bool_expr R_PAREN\n");}
            ;

comp:            
            EQ
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

ident:      
            IDENT
            {printf("ident -> IDENT %s \n", $1);}
            ;
%%

             
void yyerror(const char* s) {
  extern int currLine;
  extern char* yytext;

  printf("ERROR: %s at symbol \"%s\" on line %d\n", s, yytext, currLine);
  exit(1);
}

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