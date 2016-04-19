CC = g++
LEX = flex
YACC = bison -d -v

OS := $(shell uname)
ifeq ($(OS), Darwin)
LDFLAGS = -ll -std=c++11 -Wno-deprecated-register
else
LDFLAGS = -lfl -std=c++11 -Wno-deprecated-register
endif

demo: demo.cc compiler.cc parser.tab.c lexer.c
	$(CC) $^ -o $@  $(LDFLAGS)

parser.tab.c parser.tab.h: parser.y
	$(YACC) parser.y

lexer.c: lexer.l

clean:
	$(RM) *.o lexer.c parser.tab.c parser.tab.h parser.output demo