LEX = flex
YACC = bison -d

OS := $(shell uname)
ifeq ($(OS), Darwin)
LDFLAGS = -ll
else
LDFLAGS = -lfl
endif

demo: demo.c parser.tab.c lexer.c
	$(CC) $^ -o $@  $(LDFLAGS)

parser.tab.c parser.tab.h: parser.y
	$(YACC) parser.y

lexer.c: lexer.l

clean:
	$(RM) *.o lexer.c parser.tab.c parser.tab.h demo