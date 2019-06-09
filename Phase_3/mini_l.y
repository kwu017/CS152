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
    #include <vector>
    
    using namespace std;
    
    yy::parser::symbol_type yylex();
    
    //error function declarations
    int yyerror (char* s);          
	bool in_symbol_table(string);      
	bool in_arr_table(string);      
	bool in_func_table(string);    
	
	int params = 0, temps = 0, labels = -1;
	bool isparam = false; 
	
	vector<string> param_table;
	vector<string> func_table; //Stores the names of functions for the function lookup table
	vector<string> symbol_table;  
	vector<string> sym_type;   //Stores the data type of the variables denoted by the symbols 
	vector<string> operands;         
	vector<string> statement_vector; //Stores the statements in machine language
	string temp_string;         //temporary variable
	vector<vector<string> > iflabels; 
	vector<vector<string> > looplabels;  
	stack<string> param_queue; 
	stack<string> read_queue;  
                            
    ofstream file;
             
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
%token <std::string> NUMBERS 
%token <std::string> IDENT
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
				| function functions
			;
			
function_name:
				FUNCTION IDENT
			{func_table.push_back($2); 
             file << "func " << $2 << endl;}
             ;

function: 		
				function_name SEMICOLON begin_param declarations end_param BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY
			{
				for (unsigned j = 0; j < symbol_table.size(); j++) {
					if (sym_type.at(j) == "INTEGER") {
						file << ". " << symbol_table.at(j) << endl;
					}
				
					else {
						file << ".[] " << symbol_table.at(j) << ", " << sym_type.at(j) << endl;
					}	
				}
				
            	while (!param_table.empty()) {
                	file << "= " << param_table.front() << ", $" << params << endl;
                	param_table.erase(param_table.begin());
                	params++;
            	}
            	
            	for (unsigned i = 0; i < statement_vector.size(); i++) {
                	file << statement_vector.at(i) << endl;
            	}
            	
            	file << "endfunc\n" << endl;
            	statement_vector.clear();
            	symbol_table.clear();
            	sym_type.clear();
            	param_table.clear();
            	params = 0;
			}
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
				identifiers COLON INTEGER
			{sym_type.push_back("INTEGER");}
			    | ARRAY L_SQUARE_BRACKET NUMBERS R_SQUARE_BRACKET OF INTEGER
			{
				stringstream ss;
				ss << $3;
				string s = ss.str();
				sym_type.push_back(s);
			} 
			;
			
declarations:		
				| declaration SEMICOLON declarations
			;

statements:		
				statement SEMICOLON statements
				| statement SEMICOLON
			;
			
statement:		
				IDENT ASSIGN expression
        	{
            	string var = $1;
            	if (!in_symbol_table(var)) {
                	exit(0);
            	}    
            	statement_vector.push_back("= " + var + ", " + operands.back());
            	operands.pop_back();
        	}
        		| IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET ASSIGN expression
        	{
            	string var = $1;
            	if (!in_arr_table(var)) {
                	exit(0);
            	}	
            	string array_result_expression = operands.back();
            	operands.pop_back();
            	string array_expression = operands.back();
            	operands.pop_back();
            	statement_vector.push_back("[]= " + $1 + ", " + array_expression + ", " + array_result_expression);
        	}
		    	| if_statement statements ENDIF
        	{statement_vector.push_back(": " + iflabels.back().at(1));
            iflabels.pop_back();}
        		| elseif_statment statements ENDIF 
			{statement_vector.push_back(": " + iflabels.back().at(2));
        	iflabels.pop_back();}
		    	| while_statement statements ENDLOOP 
			{
            	statement_vector.push_back(":= " + looplabels.back().at(0));
            	statement_vector.push_back(": " + looplabels.back().at(2));
            	looplabels.pop_back();
        	}
		    	| do_statement WHILE bool_expr 
			{
            	statement_vector.push_back("?:= " + looplabels.back().at(0) + ", " + operands.back());
            	operands.pop_back();
            	looplabels.pop_back();
        	}
	       		| READ IDENT ident        
        	{                               
            	string var = $2;       
            	if (!in_symbol_table(var)) {
            		exit(0);
            	}	
            	statement_vector.push_back(".< " + $2); 
            	while (!read_queue.empty()) {
                	statement_vector.push_back(read_queue.top());
                	read_queue.pop();
            	}
        	}
        		| READ IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET ident
        	{
            	string var = $2; 
            	if (!in_arr_table(var)) {
                	exit(0);
            	}	
                int stuff = temps;
            	temps++;                       
            	string temp = "__temp__" + to_string(stuff); 
            	symbol_table.push_back(temp);      //adding temporary variable to symbol table
            	sym_type.push_back("INTEGER");          //adding datatype for the temp var to symbol table
            	statement_vector.push_back(".< " + temp);
            	statement_vector.push_back("[]= " + $2 + ", " + operands.back() + ", " + temp);
            	operands.pop_back();
            	while (!read_queue.empty()) {
                	statement_vector.push_back(read_queue.top());
                	read_queue.pop();
            	}
        	}
            	| WRITE term_again vars
        	{
            	while (!operands.empty()) {
            		string s = operands.front();
                	operands.erase(operands.begin());
                	statement_vector.push_back(".> "+ s);
            	}
            	operands.clear();
        	}
            	| CONTINUE 
        	{
            	if (!looplabels.empty()) {
                	if (looplabels.back().at(0).at(0) == 'd') {
                    	statement_vector.push_back(":= "+ looplabels.back().at(1)); 
                	}
                	
                	else {
                    	statement_vector.push_back(":= " + looplabels.back().at(0));
                	}
            	}
        	}
        		| RETURN expression
        	{statement_vector.push_back("ret " + operands.back());
            operands.pop_back();}
			;
        
if_statement:		
				IF bool_expr THEN
        	{
            	labels++;     //Generating two discrete labels for this if statement
                int lab = labels;
            	string label1 = "__label__" + to_string(lab); //if true label
            	
            	labels++;
            	lab = labels;
            	string label2 = "__label__" + to_string(lab); //if false label
            	
            	labels++;
            	lab = labels;
            	string label3 = "__label__" + to_string(lab); //else label
            	
            	vector<string> temp_label;        //temp label vector
            	temp_label.push_back(label1);    //pushing first label onto temp label vectr
            	temp_label.push_back(label2);    //pushing second label onto temp vector
            	temp_label.push_back(label3);
            	iflabels.push_back(temp_label);   //pushing temp vector onto if label
            	statement_vector.push_back("?:= " + iflabels.back().at(0) + ", " + operands.back());
                                        //MC: evaluate if condition and goto first_label
            	operands.pop_back();
            	statement_vector.push_back(":= " + iflabels.back().at(1));  //MC: goto second_label
            	statement_vector.push_back(": " + iflabels.back().at(0));      //MC: declaration first_label
        	}
        	;

elseif_statment:    
				if_statement statements ELSE
            {statement_vector.push_back(":= " + iflabels.back().at(2));
             statement_vector.push_back(": " + iflabels.back().at(1));}
            ;

while_print:  
				WHILE
        	{
            	labels++; 
            	int lab = labels;
            	string label1 = "__label__" + to_string(lab);  //while loop label
            	
            	labels++;
            	lab = labels;
            	string label2 = "__label__" + to_string(lab);  //while true label
            	
            	labels++;
            	lab = labels;
            	string label3 = "__label__" + to_string(lab);  //while false label
            	
            	vector<string> temp_label;        //temp label vector
            	temp_label.push_back(label1);    //pushing first label onto temp label vectr
            	temp_label.push_back(label2);    //pushing second label onto temp vector
            	temp_label.push_back(label3);    //pushing third label onto temp vector
            	looplabels.push_back(temp_label);   //pushing temp vector onto if label
            	statement_vector.push_back(": " + looplabels.back().at(0));      //MC: declaration looplabels
        	}
        	;
        	
while_statement: 
				while_print bool_expr BEGINLOOP
            {
                statement_vector.push_back("?:= " + looplabels.back().at(1) + ", " + operands.back());
                operands.pop_back();
                statement_vector.push_back(":= " + looplabels.back().at(2));
                statement_vector.push_back(": " + looplabels.back().at(1));
            }
            ;

do_print: 
				DO BEGINLOOP
    		{
            	labels++;   
            	int lab = labels;
            	string label1 = "__label__" + to_string(lab);  //do label
            	
            	labels++;
            	lab = labels;
            	string label2 = "__label__" + to_string(lab);
            	
            	vector<string> temp_label;
            	temp_label.push_back(label1);
            	temp_label.push_back(label2);
            	looplabels.push_back(temp_label);
            	statement_vector.push_back(": " + label1);
        	}
        	;

do_statement: 
				do_print statements ENDLOOP
        	{statement_vector.push_back(": " + looplabels.back().at(1));}
        	
bool_expr:		
				relation_and_expr
				| bool_expr OR relation_and_expr 
			{
                int stuff = temps;
            	temps++;
            	string temp = "__temp__" + to_string(temps);
            	symbol_table.push_back(temp);    
            	sym_type.push_back("INTEGER");      
            	string operandstuff2 = operands.back();
            	operands.pop_back();
            	string operandstuff1 = operands.back();
            	operands.pop_back();
            	statement_vector.push_back("|| " + temp + ", " + operandstuff1 + ", " + operandstuff2);    
            	operands.push_back(temp); 
			}
			;
			
relation_and_expr:	
				relation_expr 
				| relation_and_expr AND relation_expr 
			{
                int stuff = temps;
            	temps++;
            	string temp = "__temp__" + to_string(stuff); 
            	symbol_table.push_back(temp);     
            	sym_type.push_back("INTEGER");      
            	string operandstuff2 = operands.back();
            	operands.pop_back();
            	string operandstuff1 = operands.back();
            	operands.pop_back();
            	statement_vector.push_back("&& " + temp + ", " + operandstuff1 + ", " + operandstuff2);    
            	operands.push_back(temp); 
        	}
        	;
        	
relation_expr:		
				relation_exp
				| NOT relation_exp
        	{
                int stuff = temps;
            	temps++;
            	string temp = "__temp__" + to_string(stuff); 
            	symbol_table.push_back(temp);     
            	sym_type.push_back("INTEGER");          
            	string operandstuff1 = operands.back();
            	operands.pop_back();                          
            	statement_vector.push_back("! " + temp + ", " + operandstuff1);   
            	operands.push_back(temp);
        	}
			;
			
relation_exp:		
				expression EQ expression
        	{
                int stuff = temps;
            	temps++;
            	string temp = "__temp__" + to_string(stuff); 
            	symbol_table.push_back(temp);      
            	sym_type.push_back("INTEGER");         
            	string operandstuff2 = operands.back();
            	operands.pop_back();
            	string operandstuff1 = operands.back();
            	operands.pop_back();
            	statement_vector.push_back("== " + temp + ", " + operandstuff1 + ", " + operandstuff2);    
            	operands.push_back(temp); 
        	}
				| expression NEQ expression
        	{
                int stuff = temps;
            	temps++;
            	string temp = "__temp__" + to_string(stuff); 
            	symbol_table.push_back(temp);      
            	sym_type.push_back("INTEGER");      
            	string operandstuff2 = operands.back();
            	operands.pop_back();
            	string operandstuff1 = operands.back();
            	operands.pop_back();
            	statement_vector.push_back("!= " + temp + ", " + operandstuff1 + ", " + operandstuff2);    
            	operands.push_back(temp); 
        	}

        		| expression LT expression 
        	{
                int stuff = temps;
            	temps++;
            	string temp = "__temp__" + to_string(stuff);  
            	symbol_table.push_back(temp);      
            	sym_type.push_back("INTEGER");       
            	string operandstuff2 = operands.back();
            	operands.pop_back();
            	string operandstuff1 = operands.back();
            	operands.pop_back();
            	statement_vector.push_back("< " + temp + ", " + operandstuff1 + ", " + operandstuff2);    
            	operands.push_back(temp); 
        	}
        		| expression GT expression 
        	{
                int stuff = temps;
            	temps++;
            	string temp = "__temp__" + to_string(stuff); 
            	symbol_table.push_back(temp);      
            	sym_type.push_back("INTEGER");          
            	string operandstuff2 = operands.back();
            	operands.pop_back();
            	string operandstuff1 = operands.back();
            	operands.pop_back();
            	statement_vector.push_back("> " + temp + ", " + operandstuff1 + ", " + operandstuff2);    
            	operands.push_back(temp); 
        	}
        		| expression LTE expression 
        	{
                int stuff = temps;
            	temps++;
            	string temp = "__temp__" + to_string(stuff);
            	symbol_table.push_back(temp);      
            	sym_type.push_back("INTEGER");        
            	string operandstuff2 = operands.back();
            	operands.pop_back();
            	string operandstuff1 = operands.back();
            	operands.pop_back();
            	statement_vector.push_back("<= " + temp + ", " + operandstuff1 + ", " + operandstuff2);    
            	operands.push_back(temp); 
        	}
        		| expression GTE expression 
        	{
                int stuff = temps;
            	temps++;
            	string temp = "__temp__" + to_string(stuff);
            	symbol_table.push_back(temp);      
            	sym_type.push_back("INTEGER");    
            	string operandstuff2 = operands.back();
            	operands.pop_back();
            	string operandstuff1 = operands.back();
            	operands.pop_back();
            	statement_vector.push_back(">= " + temp + ", " + operandstuff1 + ", " + operandstuff2);    
            	operands.push_back(temp); 
        	}
        		| TRUE
        	{
                int stuff = temps;
        		temps++;
            	string temp = "__temp__" + to_string(stuff); 
            	symbol_table.push_back(temp);      
            	sym_type.push_back("INTEGER");          
            	statement_vector.push_back("= " + temp + ", 1"); 
            	operands.push_back(temp);
        	}
				| FALSE
        	{
                int stuff = temps;
            	temps++;
            	string temp = "__temp__" + to_string(stuff);
            	symbol_table.push_back(temp);      
            	sym_type.push_back("INTEGER");          
            	statement_vector.push_back("= " + temp + ", 0"); 
            	operands.push_back(temp);
        	}
				| L_PAREN bool_expr R_PAREN 
        	;
        	
expression:		
				multiplicative_expr expressions
			;
			
expressions:		
				| ADD multiplicative_expr expressions
        	{
            	int stuff = temps;
            	temps++;
            	string temp = "__temp__" + to_string(stuff); 
            	symbol_table.push_back(temp);      
            	sym_type.push_back("INTEGER");          
            	string operandstuff2 = operands.back();
            	operands.pop_back();
            	string operandstuff1 = operands.back();
            	operands.pop_back();
            	statement_vector.push_back("+ " + temp + ", " + operandstuff1 + ", " + operandstuff2);    
            	operands.push_back(temp); 
        	}
				| SUB multiplicative_expr expressions
        	{
                int stuff = temps;
            	temps++;
            	string temp = "__temp__" + to_string(stuff); 
            	symbol_table.push_back(temp);      
            	sym_type.push_back("INTEGER");         
            	string operandstuff2 = operands.back();
            	operands.pop_back();
            	string operandstuff1 = operands.back();
            	operands.pop_back();
            	statement_vector.push_back("- " + temp + ", " + operandstuff1 + ", " + operandstuff2);    
            	operands.push_back(temp); 
        	}
			;
			
multiplicative_expr:	
				term multiplicative_print 
			;
		
multiplicative_print:	 
				| MULT term multiplicative_print 
        	{
                int stuff = temps;
            	temps++;
            	string temp = "__temp__" + to_string(stuff); 
            	symbol_table.push_back(temp);      
            	sym_type.push_back("INTEGER");         
            	string operandstuff2 = operands.back();
            	operands.pop_back();
            	string operandstuff1 = operands.back();
            	operands.pop_back();
            	statement_vector.push_back("* " + temp + ", " + operandstuff1 + ", " + operandstuff2);    
            	operands.push_back(temp); 
        	}
				| DIV term multiplicative_print
        	{
                int stuff = temps;
            	temps++;
            	string temp = "__temp__" + to_string(stuff); 
            	symbol_table.push_back(temp);      
            	sym_type.push_back("INTEGER");         
            	string operandstuff2 = operands.back();
            	operands.pop_back();
            	string operandstuff1 = operands.back();
            	operands.pop_back();
            	statement_vector.push_back("/ " + temp + ", " + operandstuff1 + ", " + operandstuff2);    
            	operands.push_back(temp); 
    		}
				| MOD term multiplicative_print
        	{
                int stuff = temps;
            	temps++;
            	string temp = "__temp__" + to_string(stuff); 
            	symbol_table.push_back(temp);      
            	sym_type.push_back("INTEGER");         
            	string operandstuff2 = operands.back();
            	operands.pop_back();
            	string operandstuff1 = operands.back();
            	operands.pop_back();
            	statement_vector.push_back("% " + temp + ", " + operandstuff1 + ", " + operandstuff2);    
            	operands.push_back(temp); 
        	}
			;
			
var:			
				IDENT
			{
                string s = $1;
                if (!in_symbol_table(s)) {
            	    exit(0);
                }	
                operands.push_back(s);
            }
                | IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET
            {
                string operandstuff1 = operands.back();
                operands.pop_back();
                string s = $1;
                if (!in_arr_table(s)) {
            	    exit(0);
                }	
                operands.push_back("[] " + s + ", " + operandstuff1);
            }
            ;
            
vars:		 
				| COMMA term_again vars 
		
        	;

term:		
				term_again 
            {}
                | SUB term_again
            {
                int stuff = temps;
                temps++;
                string temp = "__temp__" + to_string(stuff); 
                symbol_table.push_back(temp);  
                sym_type.push_back("INTEGER");     
                statement_vector.push_back("- " + temp + ", 0, " + operands.back());    
                operands.pop_back();  
                operands.push_back(temp); 
            }
                | IDENT ident_term
            {
                int stuff = temps;
                temps++;
                string temp = "__temp__" + to_string(stuff);  
                symbol_table.push_back(temp);     
                sym_type.push_back("INTEGER");     
                if (!in_func_table($1)) {
                    exit(0);
                }    
                statement_vector.push_back("call " + $1 + ", " + temp); 
                operands.push_back(temp); 
            }
            ;
            
term_again:        
				var 
            {
                int stuff = temps;
                temps++;
                string temp = "__temp__" + to_string(stuff);  
                symbol_table.push_back(temp);     
                sym_type.push_back("INTEGER");     
                string operandstuff1 = operands.back();       
                if(operandstuff1.at(0) == '[') {       
                    statement_vector.push_back("=[] " + temp + ", " + operandstuff1.substr(3, operandstuff1.length() - 3));
                }    
                
                else {                               
                    statement_vector.push_back("= " + temp + ", " + operands.back());    
                }    
                operands.pop_back();  
                operands.push_back(temp); 
            }
                | NUMBERS
            {
                int stuff = temps;
                temps++;             
                string temp = "__temp__" + to_string(stuff); 
                symbol_table.push_back(temp);     
                sym_type.push_back("INTEGER");     
                stringstream ss;
                ss << $1;
                statement_vector.push_back("= " + temp + ", " + ss.str());
                operands.push_back(temp);
            }
                | L_PAREN expression R_PAREN
            ;
                
ident_term:      
				L_PAREN expression_term R_PAREN
            {
                while (!param_queue.empty()) {
                    statement_vector.push_back("param "+ param_queue.top());
                    param_queue.pop();
                }
            }
                | L_PAREN R_PAREN
            {}
            ;

expression_term:        
				expression
            {param_queue.push(operands.back());
             operands.pop_back();}
                | expression COMMA expression_term
            {param_queue.push(operands.back());
             operands.pop_back();}
            ;
                
identifiers:		
				IDENT 
			{
				symbol_table.push_back($1);
            	if (isparam) {
                	param_table.push_back($1);
            	}	
			}
				| IDENT COMMA identifiers 
			{
				symbol_table.push_back($1);
				sym_type.push_back("INTEGER");
			}
			;
			
ident:  
				| COMMA IDENT ident
            {
                string s = $2;
                if (!in_symbol_table(s)) {
                    exit(0);
                }
                read_queue.push(".< " + $2);

            }
            	| COMMA IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET ident
            {
                string s = $2;
                if (!in_arr_table(s)) {
                    exit(0);
                }    
                int stuff = temps;
                temps++;                       
                string temp = "__temp__" + to_string(stuff);  
                symbol_table.push_back(temp);     
                sym_type.push_back("INTEGER");    
                read_queue.push(".< " + temp);
                read_queue.push("[]= " + $2 + ", " + operands.back() + ", " + temp);
                operands.pop_back();
            }
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

int yyerror(string s) {
  int currLine, currPos;
  char *yytext;	
  
  cerr << "SYNTAX(PARSER) Error at line " << currLine << ", position " << currPos << " : Unexpected Symbol \"" << yytext << "\" Encountered." << endl;
  exit(1);
}

int yyerror(char *s) {
  return yyerror(string(s));
}

bool in_symbol_table(string var) {
    int currLine, currPos; 
    for (unsigned int i = 0; i < symbol_table.size(); i++) {
        if (symbol_table.at(i) == var) {
            if (sym_type.at(i) == "INTEGER") {
                return true;
            }
            
            else {
                file << "SEMANTIC Error at line " << currLine << ", position " << currPos << " : Incompatible Datatype - \"" << var.substr(1, var.length() - 1) << "\" is an ARRAY." << endl; 
                return false;
            }
        }
    }
    cerr << "SEMANTIC Error at line " << currLine << ", position " << currPos << " : Undeclared \"" << var.substr(1, var.length() - 1) << "\" Used." << endl; 
    return false;
}

bool in_arr_table(string var) {
    int currLine, currPos; 
    for (unsigned int i = 0; i < symbol_table.size(); i++) {
        if (symbol_table.at(i) == var) {
            if (sym_type.at(i) == "INTEGER") {
                file << "SEMANTIC Error at line " << currLine << ", position " << currPos << " : Incompatible Datatype - \"" << var.substr(1, var.length() - 1) << "\" is an INTEGER." << endl; 
                return false;
            }
            
            else {
                return true;
            }
        }
    }
    cerr << "SEMANTIC Error at line " << currLine << ", position " << currPos << " : Undeclared \"" << var.substr(1, var.length() - 1) << "\" Used." << endl; 
    return false;
}

bool in_func_table(string var) {
    int currLine, currPos; 
    for (unsigned int i = 0; i < func_table.size(); i++) {
        if (func_table.at(i) == var) {
            return true;
        }    
    }        
    cerr << "SEMANTIC Error at line " << currLine << ", position " << currPos << " : Undeclared Function \"" << var << "\" Called." << endl; 
    return false;
}
