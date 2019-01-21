                 float                    coefficient[6][6]={
                                                          {0,0,0,1,1,3},{0,0,0,2,2,5},{0,0,0,4,1,2}
                                                };
//松弛表达式的系数集合
                 float                    relaxConstants[6]={30,24,36};
//目标函数
                 float                    objectFunc[6]={0,0,0,3,1,2};
                 float                    objectConstant=0.0f;
//基本变量集合
                 int                       basicVariable[3]={0,1,2};
//非基本变量集合
                 int                       nonbasicVariable[3]={3,4,5};
//******************************************************************                 
//系数矩阵,注意这是松弛型系数
                 const                  int                       size=5;
                 float                    coefficient[5][5]={
                                                          {0,0,1,1,0},{0,0,0,-1,1}
                                                };
//松弛表达式的系数集合
                 float                    relaxConstants[5]={8,0};
//目标函数
                 float                    objectFunc[5]={0,0,1,1,1};
                 float                    objectConstant=0.0f;
//基本变量集合
                 int                       variableSize=2;
                 int                       basicVariable[2]={0,1};
//非基本变量集合
                 int                       nonVariableSize=3;
                 int                       nonbasicVariable[3]={2,3,4};