CC = g++
LEX = flex
YACC = bison -d -v

OS := $(shell uname)
ifeq ($(OS), Darwin)
LDFLAGS = -ll -std=c++11 -Wno-deprecated-register -g -w
else
LDFLAGS = -lfl -std=c++11 -Wno-deprecated-register -g -w
endif

demo: demo.cc compiler.cc parser.tab.c lexer.c
	$(CC) $^ -o $@  $(LDFLAGS)
	cd simulator && $(MAKE)

parser.tab.c parser.tab.h: parser.y
	$(YACC) parser.y

lexer.c: lexer.l

clean:
	$(RM) -r *.o lexer.c parser.tab.c parser.tab.h parser.output demo *.dSYM
	cd simulator && $(MAKE) clean