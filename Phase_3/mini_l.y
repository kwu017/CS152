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
    #include <fstream>
    #include <map>
    #include <regex>
    #include <set>
    
    using namespace std;
    
    yy::parser::symbol_type yylex();
    
    ofstream file;
	vector<string> variables;
	int temps = 0, labels = 0, returns = 0;
	bool isparam = false;

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
%token <std::string> NUMBER IDENT
%type <std::string> function begin_param end_param declarations declaration statements statement else_statement bool_expr relation_and_expr relation_expr relation_exp comp expression expression1 expressions multiplicative_expr var vars term identifiers identifiers1
%left SUB ADD 
%left MULT DIV MOD
%left EQ NEQ LT GT LTE GTE ASSIGN
%left AND OR
%right NOT

%% 

//grammar goes here

prog_start:		
				functions
			{file.close();}
			;

functions:		
				| functions function
			{file << $2 << endl;}
			;

function:		
				FUNCTION IDENT SEMICOLON begin_param declarations end_param BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statement SEMICOLON statements END_BODY
			{$$ = "func " + $2 + '\n' + $5 + $8 + $11 + $13 + "\nendfunc\n";}
			;
			
begin_param:		
				BEGIN_PARAMS
			{isparam = true;}
			;
			
end_param:	
				END_PARAMS
			{isparam = false;}
			;
			
declaration:		
				IDENT identifiers COLON identifiers1 INTEGER
			{
				variables.push_back($1);
				while(!variables.empty()) {
					$$ += ".";
					if(!$4.empty()) {
						$$ += "[]";
					}
					
					$$ += ' ' + variables.front();
					if(!$4.empty()) {
						$$ += ", " + $4;
					}
					
					$$ += '\n'; 
					if($4.empty() && isparam) {
						$$ += "= " + variables.front() + ", $0\n";
					}
					variables.erase(variables.begin());
				}
			}
			;
			
declarations:		
			{$$ = "";}
				| declaration SEMICOLON declarations
			{$$ = $1 + $3;
			}
			;

statements:		
			{$$ = "";} //ololo
				| statement SEMICOLON statements
			{$$ = $1 + $3;}
			;
			
statement:		
				var ASSIGN expression
			{
				if(!$1.empty()) {
					$$ = $1;
				}
				
				$$ += '=';
				$$ += ' ';
				$$ += ", ";
				
				if(!variables.empty()) {
					$$ += variables.front();
					variables.erase(variables.begin());
				}
				$$ = $3;
				//$$ += '\n';
			}
				| IF bool_expr THEN statement SEMICOLON else_statement ENDIF
			{$$ = $2 + "?:= __label__" + to_string(labels) + ", __temp__" + to_string(temps - 1) + "\n:= __label__" + to_string(labels + 1) + "\n: __label__" + to_string(labels) + $4 + $6;
			temps++; 
			labels++;}
				| WHILE bool_expr BEGINLOOP statement SEMICOLON statements ENDLOOP
			{$$ = "__temp__" + to_string(temps) + ' ' + $2 + $4 + "\n?:=__label__" + to_string(labels) + $6;
			labels++; 
			temps++;}
				| DO BEGINLOOP statement SEMICOLON statements ENDLOOP WHILE bool_expr
			{$$ = $3 + $5 + $8;}
				| READ vars
			{$$ = ".< " + $2;}
				| WRITE vars
			{$$ = "= " + $2 + ", __temp__" + to_string(temps - 1) + "\n.> " + $2; //there was a newline right before the = sign //added a -1 after temps fixed adding issue
			//$$.erase(remove($$.begin(), $$.end(), '\n'), $$.end());
			temps++;}
				| CONTINUE
			{$$ = "";}
				| RETURN expression
			{
				if (returns == 0) {
					$$ = "\n. __temp__" + to_string(temps + 1) + "\n= __temp__" + to_string(temps + 1) + ", " + $2 + "ret __temp__" + to_string(temps + 1) + "\n: __label__" + to_string(labels + 1);
					returns++;
					temps++;
				}
				
				else {
					$$ = $2 + "ret __temp__" + to_string(temps - 1); //used to be a \n in front of ret
					temps++;
				}
				//temps++;
			}
			;
			
else_statement:   
            {$$ = "";}
            	| statement SEMICOLON else_statement
            {$$ = $1 + $3;}
                | ELSE statement SEMICOLON statements
            {$$ = $2;}
            ;
            
bool_expr:		
				relation_and_expr
			{$$ = $1;}
				| relation_and_expr OR bool_expr
			{$$ = $1 + $3;}
			;

relation_and_expr:	
				relation_expr
			{$$ = $1;}
				| relation_expr AND relation_and_expr
			{$$ = $1 + $3;}
			;

relation_expr:		
				NOT relation_exp
			{$$ = "!" + $2;}
				| relation_exp
			{$$ = $1;}
			;

relation_exp:		
				expression comp expression
			{$$ = ". __temp__" + to_string(temps - 1) + "\n" + "= __temp__" + to_string(temps - 1) + ", " + $1 /*+ "\n"*/ + ". __temp__" + to_string(temps) + "\n" + "= __temp__" + to_string(temps) + ", " + $3 /*+ "\n"*/ + $2;
			temps++;}
				| TRUE
			{$$ = "__temp__" + to_string(temps);
			temps++;}
				| FALSE
			{$$ = "__temp__" + to_string(temps);
			temps++;}
				| L_PAREN bool_expr R_PAREN
			{$$ = $2;}
			;

comp:			GT
			{$$ = ". __temp__" + to_string(temps + 2) + "\n> __temp__" + to_string(temps + 2) + ", " + "__temp__" + to_string(temps) + ", " + "__temp__" + to_string(temps + 1) + "\n";
			temps++;}
				| GTE
			{$$ = ". __temp__" + to_string(temps + 2) + "\n>= __temp__" + to_string(temps + 2) + ", " + "__temp__" + to_string(temps) + ", " + "__temp__" + to_string(temps + 1) + "\n";
			temps++;}
				| LT
			{$$ = ". __temp__" + to_string(temps + 2) + "\n< __temp__" + to_string(temps + 2) + ", " + "__temp__" + to_string(temps) + ", " + "__temp__" + to_string(temps + 1) + "\n";
			temps++;}
				| EQ
			{$$ = ". __temp__" + to_string(temps + 2) + "\n== __temp__" + to_string(temps + 2) + ", " + "__temp__" + to_string(temps) + ", " + "__temp__" + to_string(temps + 1) + "\n";
			temps++;}
				| NEQ
			{$$ = ". __temp__" + to_string(temps + 2) + "\n!= __temp__" + to_string(temps + 2) + ", " + "__temp__" + to_string(temps) + ", " + "__temp__" + to_string(temps + 1) + "\n";
			temps++;}
				| LTE
			{$$ = ". __temp__" + to_string(temps + 2) + "\n<= __temp__" + to_string(temps + 2) + ", " + "__temp__" + to_string(temps) + ", " + "__temp__" + to_string(temps + 1) + "\n";
			temps++;}
			;

expression:		
				multiplicative_expr expression1
			{$$ = $1 + "\n";
			$$ += $2;
			}
			;
			
expression1:
			{$$ = "";} //leave hi as a marker
				| ADD multiplicative_expr expression1
			{$$ = $2 + ". __temp__" + to_string(temps) + "\n+ __temp__" + to_string(temps) + ", __temp__" + to_string(temps - 5) + ", __temp__" + to_string(temps - 1) + $3 + "\n"; //added a \n at the end
			temps++;}
				| SUB multiplicative_expr expression1
			{$$ = ". __temp__" + to_string(temps + 1) + "\n= __temp__" + to_string(temps + 1) + ", " + $2 + "\n. __temp__" + to_string(temps + 2) + "\n- __temp__" + to_string(temps + 2) + ", __temp__" + to_string(temps) + ", __temp__" + to_string(temps + 1) + $3 + "\n"; //added a \n at the end
			temps++;}
			;

expressions:		
			{$$ = "";}
                 | expression COMMA expressions
            {$$ = $1 + $3;} 
                 | expression
            {$$ = $1;}
            ;

multiplicative_expr:	
				term
			{$$ = $1;} //extra space
				| term MULT multiplicative_expr
			{$$ = $1 + " * " + $3;}
				| term DIV multiplicative_expr
			{$$ = $1 + " / " + $3;}
				| term MOD multiplicative_expr
			{$$ = " % " + $1;}
			;
			
var:			
				IDENT
			{$$ = $1;} //hooha
				| IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET
			{$$ = $3;} //yipyip
			;
			
vars:
				var
            {$$ = $1;}
                 | var COMMA vars
            {$$ = $1 + $3;}
            ;

term:			var
			{$$ = $1;}
				| SUB var
			{$$ = "-" + $2;}
				| NUMBER
			{$$ = $1;}
				| SUB NUMBER
			{$$ = "-" + $2;}
				| L_PAREN expression R_PAREN
			{$$ = $2;}
				| SUB L_PAREN expression R_PAREN
			{$$ = "-" + $3;}
				| IDENT L_PAREN expressions R_PAREN
			{$$ = "\n. __temp__" + to_string(temps - 1) + "\n= __temp__" + to_string(temps - 1) + ", " + $3 + "param __temp__" + to_string(temps + 1) + "\n. __temp__" + to_string(temps + 2) + "\ncall " + $1 + ", __temp__" + to_string(temps + 2) + "\n";
			temps = temps + 3;
			labels++;}
			;
			
identifiers:	
			{$$ = "";}
				| COMMA IDENT
			{variables.push_back($2);}
			;

identifiers1:		
			{$$ = "";}
				| ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF
			{$$ = $3;}
			;

%%

int main(int argc, char *argv[]) {
    file.open("mil_code.mil");
	yy::parser p;
	return p.parse();
}

void yy::parser::error(const yy::location& l, const std::string& m) {
	std::cerr << l << ": " << m << std::endl;
}
