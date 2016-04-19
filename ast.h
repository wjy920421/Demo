typedef enum { typeCon, typeId, typeOpr } nodeEnum;

typedef struct {
    int value;
} conNodeType;

typedef struct {
    char * i;
} idNodeType;

typedef struct {
    int oper;
    int nops;
    struct nodeTypeTag **op;
} oprNodeType;

struct nodeTypeTag {
    nodeEnum type;
    union {
        conNodeType con;
        idNodeType id;
        oprNodeType opr;
    };
};
typedef nodeTypeTag nodeType;

extern int sym[26];