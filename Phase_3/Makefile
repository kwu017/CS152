parser: mini_l.lex mini_l.y
	bison -v -d --file-prefix=parser mini_l.y
	flex mini_l.lex
	g++ -std=c++11 -o parser parser.tab.c lex.yy.c -lfl

clean:
	rm -f lex.yy.c parser.tab.* parser.output *.o parser location.hh position.hh stack.hh 
