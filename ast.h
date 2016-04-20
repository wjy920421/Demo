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
    char * reg;
    char * type;
} VarNode;

typedef struct
{
    char * name;
    int offset;
    int dimensions;
    int d[10][2];
} DataNode;

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

extern int sym[26];