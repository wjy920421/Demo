#include <stdio.h>
#include <string.h>
#include "parser.tab.h"

extern int parser(const char * filename);

int main(int argc, char ** argv)
{
    if (argc > 1 && strcmp(argv[1], "-h") == 0)
    {
        printf("Usage: %s [filename]\n", argv[0]);
        printf("       [-h]        Display available options.\n");
        printf("       [filename]  The file to be compiled.\n");
        printf("                   The program will read from stdin if it is missing.\n");
        return -1;
    }
    else if (argc > 1) 
    {
        parser(argv[1]);
    }
    else
    {
        parser(NULL);
    }

    return 0;
}
