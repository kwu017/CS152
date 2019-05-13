FL=flex
CC=gcc

LEX=mini_l.lex

SOURCES=y.tab.c lex.yy.c
OBJECTS=$(SOURCES:.cpp=.o)

BISON = bison
BISONFLAG = -v -d --file-prefix=y
BISONOBJ = mini_l.y
BISONOUTPUT = y.output

LEXIGRAM = lex.yy.c
EXECUTABLE=parser
FLAG = -o -ll
all: $(SOURCES) $(EXECUTABLE)
	

$(LEXIGRAM): $(LEX)
	$(BISON) $(BISONFLAG) $(BISONOBJ)
	$(FL) $(LEX)

$(EXECUTABLE): $(OBJECTS) 
	$(CC) -o $@ $(ARCH) $(OBJECTS) -ll 

.PHONY : clean
clean :
	-rm $(EXECUTABLE) $(LEXIGRAM) $(BISONOUTPUT)

