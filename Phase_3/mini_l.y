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
%token <std::string> NUMBER IDENT
%type <std::string> function declarations statements declaration declaration1 declaration2 statement statement1 statement2 statement3 var expression expressions multiplicative_expr bool_expr relation_expr relation_exp relation_and_expr comp term /*term1 term2 term3*/ begin_param end_param begin_local end_local

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
				FUNCTION IDENT SEMICOLON begin_param declarations end_param begin_local declarations end_local BEGIN_BODY statement SEMICOLON statements END_BODY
			{$$ = "func " + $2 + '\n' + $5 + $8 + $11 + $13 + "\nendfunc\n";}
			;
			
begin_param:		
				BEGIN_PARAMS
			{param = true;}
			;
			
end_param:	
				END_PARAMS
			{param = false;}
			;
			
begin_local:	
				BEGIN_LOCALS
			{local = true;}
			;
			
end_local:		
				END_LOCALS
			{local = false;}
			;
			
declarations:		
			{$$ = "";}
				| declaration SEMICOLON declarations
			{$$ = $1 + $3;}
			;

statements:		
			{$$ = "";}
				| statement SEMICOLON statements
			{$$ = $1 + $3;}
			;

declaration:		
				IDENT declaration1 COLON declaration2 INTEGER
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
					if($4.empty() && param) {
						$$ += "= " + variables.front() + ", $0\n";
					}
					
					variables.erase(variables.begin());
				}
			}
			;

declaration1:		
				| COMMA IDENT
			{variables.push_back($2);}
			;

declaration2:		
			{$$ = "";}
				| ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF
			{$$ = $3;}
			;

statement:		
			{$$ = "";}
				|var ASSIGN expression
			{
				if(!$1.empty()) {
					$$ = $1;
				}
				$$ += '=';
				//if R-ARRAY PRINT "[]"
				$$ += ' ';
				$$ += ", ";
				if(!$1.empty())
				{
					//PRINT index + ", " see if this is actually useful
				}
				if(!variables.empty()) {
					$$ += variables.front();
					variables.erase(variables.begin());
				}
				$$ = $3;
			}
				| IF bool_expr THEN statement SEMICOLON statement2 ENDIF
			{$$ = $2 + "?:= __label__" + to_string(labels) + ", __temp__" + to_string(temps-1) + "\n:= __label__" + to_string(labels+1) + "\n: __label__" + to_string(labels) + $4 + $6;
			++temps; ++labels;}
				|WHILE bool_expr BEGINLOOP statement SEMICOLON statement3 ENDLOOP
			{$$ = "__temp__" + to_string(temps) + ' ' + $2 + $4 + "\n?:=__label__" + to_string(labels) + $6;
			labels++; ++temps;}
				| DO BEGINLOOP statement SEMICOLON statement3 ENDLOOP WHILE bool_expr
			{$$ = $3 + $5 + $8;}
				| READ var statement1
			{$$ = ".< " + $2 + $3;}
				| WRITE var statement1
			{$$ = "\n= " + $2 + ", __temp__" + to_string(temps) + "\n.> " + $2 + $3;
			++temps;}
				| CONTINUE
				| RETURN expression
			{
				if (ret == 0) {
				$$ = "\n. __temp__" + to_string(temps+1) + "\n= __temp__" + to_string(temps+1) + ", " + $2 + "ret __temp__" + to_string(temps+1) + "\n: __label__" + to_string(labels);
				++ret;
				++temps;
				}
				else {
					$$ = $2 + "\nret __temp__" + to_string(temps-1);
				}
				++temps;
			}
			;
			
statement1:		
			{$$ = "";}
				| COMMA var statement1
			{$$ = $2 + $3;}
			;

statement2:		
			{$$ = "";}
				| statement SEMICOLON statement2
			{$$ = $1 + $3;}
				| ELSE statement SEMICOLON statement3
			{$$ = $2 + $4;}
			;

statement3:		
			{$$ = "";}
				| statement SEMICOLON statement3
			{$$ = $1 + $3;}
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
			{$$ = ". __temp__" + to_string(temps - 1) + "\n" + "= __temp__" + to_string(temps - 1) + ", " + $1 + "\n" + ". __temp__" + to_string(temps) + "\n" + "= __temp__" + to_string(temps) + ", " + $3 + "\n" + $2;
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
			{$$ = "> ";}
				| GTE
			{$$ = ">= ";}
				| LT
			{$$ = "< ";}
				| EQ
			{$$ = "== ";}
				| NEQ
			{$$ = "!= ";}
				| LTE
			{$$ = ". __temp__" + to_string(temps + 2) + "\n<= __temp__" + to_string(temps + 2) + ", " + "__temp__" + to_string(temps) + ", " + "__temp__" + to_string(temps + 1) + "\n";
			temps++;}
			;

expression:		
				multiplicative_expr expressions
			{$$ = $1;
			$$ += "\n" + $2;}
			;

expressions:		
			{$$ = "";}
				| ADD multiplicative_expr expressions
			{$$ = $2 + ". __temp__" + to_string(temps) + "\n+ __temp__" + to_string(temps) + ", __temp__" + to_string(temps-5) + ", __temp__" + to_string(temps-1)+ $3;
			++temps;}
				| SUB multiplicative_expr expressions
			{$$ = ". __temp__" + to_string(temps+1) + "\n= __temp__" + to_string(temps+1) + ", " + $2 + "\n. __temp__" + to_string(temps+2) + "\n- __temp__" + to_string(temps+2) + ", __temp__" + to_string(temps) + ", __temp__" + to_string(temps+1)+ $3;
			++temps;}
			;

multiplicative_expr:	
				term
			{$$ = $1;}
				| term MULT multiplicative_expr
			{$$ = $1 + " * " + $3;}
				| term DIV multiplicative_expr
			{$$ = $1 + " / " + $3;}
				| term MOD multiplicative_expr
			{$$ = " % " + $1;}
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
				| IDENT L_PAREN expression R_PAREN
			{$$ = "\n. __temp__" + to_string(temps - 1) + "\n= __temp__" + to_string(temps - 1) + ", " + $3 + "\nparam __temp__" + to_string(temps + 1) + "\n. __temp__" + to_string(temps + 2) + "\ncall " + $1 + ", __temp__" + to_string(temps + 2) + "\n";
			temps = temps + 3; labels++;}
			;

var:			
				IDENT
			{$$ = $1;}
				| IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET
			{$$ = $3;}
			;
%%

int main(int argc, char *argv[]) {
    file.open("mini_l.mil");
	yy::parser p;
	return p.parse();
}

void yy::parser::error(const yy::location& l, const std::string& m) {
	std::cerr << l << ": " << m << std::endl;
}
