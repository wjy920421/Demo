#ifndef AST_H
#define AST_H

#include <iostream>
#include <unordered_map>
#include <string>

using namespace std;

typedef enum { NodeTypeConstant, NodeTypeVar, NodeTypeOp, NodeTypeRef } NodeType;

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
    int dimensions;
    union
    {
        char * reg;
        char * addr;
        int d[10][2];
    };
} VarNode;

typedef struct
{
    VarNode var;
    int dimensions;
    int d[10];
} RefNode;

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
        RefNode ref;
        OpNode op;
    };
};
typedef NodeStruct Node;


Node * create_constant(int value, bool charconst);
Node * create_var(const char * name, const char * type, int dimensions, int d[10][2]);
Node * create_op(int op_type, int num_ops, ...);
Node * get_var(const char * name, int dimensions, int d[]);
void print_env();
Node * execute(Node *p);

#endif



