#ifndef AST_H
#define AST_H

typedef enum { NodeTypeConstant, NodeTypeVar, NodeTypeOp } NodeType;

enum VarTypeEnum { VarTypeInt, VarTypeChar };
typedef VarTypeEnum VarType;

typedef struct
{
    int value;
    bool charconst;
} ConstantNode;

typedef struct
{
    char * name;
    char * type;
    bool is_reg;
    char * reg;
    int dimensions;
    int addr;
    int d[10][2];
} VarNode;

typedef struct
{
    int op_type;
    int num_ops;
    struct NodeStruct **ops;
} OpNode;

struct NodeStruct
{
    NodeType type;
    union
    {
        ConstantNode constant;
        VarNode var;
        OpNode op;
    };
};
typedef NodeStruct Node;


Node * create_constant(int value, bool charconst);
Node * create_var(const char * name, const char * type, bool is_reg, int dimensions, int d[10][2]);
Node * create_op(int op_type, int num_ops, ...);
Node * get_var(const char * name);
void print_env(FILE * fp);
Node * execute(Node *p);


#endif



