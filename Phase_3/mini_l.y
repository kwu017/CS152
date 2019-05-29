/* bison file based off of calc.y */
%{
%}

%skeleton "lalr1.cc"
%require "3.0.2"
%defines
%define api.token.constructor
%define api.value.type variant
%define parse.error verbose
%locations

%code requires

{
	/* you may need these deader files 
	 * add more header file if you need more
	 */
    #include <list>
    #include <string>
    #include <functional>
	/* define the sturctures using as types for non-terminals */

	/* end the structures for non-terminal types */
}

%code

{
    #include "parser.tab.h"

	/* you may need these deader files 
	 * add more header file if you need more
	 */
    #include <sstream>
    #include <map>
    #include <regex>
    #include <set>
    
    using namespace std;
    
    yy::parser::symbol_type yylex();
    
    ofstream file;
	vector<string> variables;
	vector<string> expressions;
	int temps = 0, labels = 0, ret = 0;
	bool param = false;
	bool local = false;

	/* define your symbol table, global variables,
	 * list of keywords or any function you may need here */
	
	/* end of your code */
}

%token END 0 "end of file";

%start prog_start //functions //input

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

%% 

//grammar goes here

prog_start:
                  functions
                  {printf("prog_start -> functions\n");}
                  ;

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

statements:      
                  statement SEMICOLON statements
            {printf("statements -> statement SEMICOLON statements\n");}
                 | statement SEMICOLON
            {printf("statements -> statement SEMICOLON\n");}
            ;

statement:      
                  var ASSIGN expression
            {printf("statement -> var ASSIGN expression\n");}
                 | IF bool_expr THEN statements else_statement ENDIF
            {printf("statement -> IF bool_expr THEN statements else_statement ENDIF\n");}          
                 | WHILE bool_expr BEGINLOOP statements ENDLOOP
            {printf("statement -> WHILE bool_expr BEGINLOOP statements ENDLOOP\n");}
                 | DO BEGINLOOP statements ENDLOOP WHILE bool_expr
            {printf("statement -> DO BEGINLOOP statements ENDLOOP WHILE bool_expr\n");}
                 | FOREACH ident IN ident BEGINLOOP statements ENDLOOP
            {printf("statement -> FOREACH ident IN ident BEGINLOOP statements ENDLOOP\n");}
                 | READ vars
            {printf("statement -> READ vars\n");}
                 | WRITE vars
            {printf("statement -> WRITE vars\n");}
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
                  GT
            {printf("comp -> GT\n");}
                 | GTE
            {printf("comp -> GTE\n");}
                 | LT
            {printf("comp -> LT\n");}
                 | LTE
            {printf("comp -> LTE\n");}
                 | EQ
            {printf("comp -> EQ\n");}
                 | NEQ
            {printf("comp -> NEQ\n");}
            ;

expression:      
                  multiplicative_expr
            {printf("expression -> multiplicaptive_expr\n");}
                 | multiplicative_expr ADD expression
            {printf("expression -> multiplicative_expr ADD expression\n");}
                 | multiplicative_expr SUB expression
            {printf("expression -> multiplicative_expr SUB expression\n");}
            ;

expressions:     
            {printf("expressions -> ε\n");}
                 | expression COMMA expressions
            {printf("expressions -> expression COMMA expressions\n");}
                 | expression
            {printf("expressions -> expression\n");}
            ;

multiplicative_expr:         
                  term
            {printf("multiplicative_expr -> term\n");}
                 | term MULT multiplicative_expr
            {printf("multiplicative_expr -> term MULT multiplicative_expr\n");}
                 | term DIV multiplicative_expr
            {printf("multiplicative_expr -> term DIV multiplicative_expr\n");}
                 | term MOD multiplicative_expr
            {printf("multiplicative_expr -> term MOD multiplicative_expr\n");}
            ;

var:            
                  ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET
            {printf("var -> ident  L_SQUARE_BRACKET expression R_SQUARE_BRACKET\n");}
                 | ident
            {printf("var -> ident \n");}
            ;

vars:            
                  var
            {printf("vars -> var\n");}
                 | var COMMA vars
            {printf("vars -> var COMMA vars\n");}
            ;

term:            
                  var
            {printf("term -> var\n");}
                 | SUB var
            {printf("term -> SUB var\n");}
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

identifiers:     
                  ident
            {printf("identifiers -> Ident \n");}
                 | ident COMMA identifiers
            {printf("identifiers -> ident COMMA identifiers\n");}
            ;

ident:      
                  IDENT
            {printf("ident -> IDENT %s \n", $1);}
            ;
%%

int main(int argc, char *argv[]) {
	yy::parser p;
	return p.parse();
}

void yy::parser::error(const yy::location& l, const std::string& m) {
	std::cerr << l << ": " << m << std::endl;
}
