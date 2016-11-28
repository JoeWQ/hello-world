/*
  *@aim:线性规划,单纯形算法实现
  *@note:这里的实现比常规的实现相比，需要更大的存储空间,但灵活性更强,所需要的代码更少
  *@date:2015-6-11
  */
  #ifndef    __SIMPLEX_H__
  #define   __SIMPLEX_H__
  #include"CArray2D.h"
  #include"CArray.h"
//单纯型算法所需要的数据结构
//@note:使用的规则
/*
  *@1:松弛约束表达式中第k个基本变量的下标是k,非基本变量的下标为m+i,m为基本变量的最大索引
  *@2:系数矩阵的行列(m+n,m+n),m为基本变量数目,n非基本变量的数目
  */
  struct        CSimplex
 {
//记录基本变量的索引
             CArray<int>              *basicVariableIndexes;
//记录非基本变量得索引
             CArray<int>              *nonbasicVariableIndexes;
//记录每个松弛约束中的常数,其长度和nonbasicVariableIndexes+basicVariableIndexes相等
             CArray<float>           *relaxConstants;
//松弛约束表达式的矩形阵列
             CArray2D<float>      *relaxExpressRestrict;
//目标函数,其内容的长度为nonbasicVariableIndexes->size+bacsicVariableIndexes->size
//计算目标函数的最大值
             CArray<float>           *objectFunc;
//目标函数中的常数项             
             float                            objectConstant;
//
             CSimplex();
             CSimplex(int     basicVariableSize,int    nonVariableSize);
             ~CSimplex();
  };
   enum      CSimplexType
  {
             CSimplexTypeInvalide,//单纯型输入不可行
             CSimplexTypeNoBound,//单纯型算法所得到的结果是无界的
             CSimplexTypeOK,//单纯形算法可能得到一个正常的结果
   };
 //单纯形算法实现
 //@request:调用前simple已经是松弛型的
 //@return:返回上面的枚举类型中的一种,如果计算成功，则将结果写入到result中
   CSimplexType           simplex_algorithm(CSimplex    *simplex,float   *result);
  #endif
  