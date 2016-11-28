/*
  *@aim:单纯形算法实现
  *@date:2015-6-11 18:59
  */
 #include"simplex.h"
 #include<assert.h>
 #include<stdio.h>
 //标准型转换为松弛型
 //注意,函数可能会修改src的内容
  static      bool            simplex_normal_switch_relax(CSimplex     *src,CSimplex   *dst);
  //注意,函数可能会修改simplex的内容,如果初始现行约束不可行返回CSimplexTypeInvalide
  static      CSimplexType            init_simplex(CSimplex   *simple);
 //构造函数和析构函数
   CSimplex::CSimplex()
  {
             this->basicVariableIndexes=NULL;
             this->nonbasicVariableIndexes=NULL;
             this->relaxConstants=NULL;
             this->relaxExpressRestrict=NULL;
             this->objectFunc=NULL;
             this->objectConstant=0.0f;
   }
   CSimplex::CSimplex(int     basicVariableSize,int    nonVariableSize)
  {
             this->basicVariableIndexes=new    CArray<int>(basicVariableSize);
             this->nonbasicVariableIndexes=new   CArray<int>(nonVariableSize);
             this->objectFunc=new    CArray<float>(basicVariableSize+nonVariableSize);
             this->relaxExpressRestrict=new    CArray2D<float>(basicVariableSize+nonVariableSize,basicVariableSize+nonVariableSize);
             this->relaxConstants=new    CArray<float>(basicVariableSize+nonVariableSize);
             this->objectConstant=0.0f;
   }
   CSimplex::~CSimplex()
  {
             delete       basicVariableIndexes;
             delete       nonbasicVariableIndexes;
             delete       relaxConstants;
             delete       relaxExpressRestrict;
             delete       objectFunc;
             objectConstant=0.0f;
   }
//主元的交换,方程组之间的代换
//主元的交换,方程组之间的代换
//@param:swap_out被换出的基本变量的索引,
//@param:swap_in被换入的非基本变量索引
//交换后swap_in,swap_out的身份交换,基本变量和非基本变量的互换
//@request:relaxExpressRestrict->get(swap_out,swap_in)>0
  static         void            swap_pivot(CSimplex        *simplex,int  swap_out,int  swap_in   )
 {
              float              factor;
              float              relaxConstant;
              float              coef;
              int                 i,j,k;
//选择目标约束行,更新约束中的常数因子
              factor=simplex->relaxExpressRestrict->get(swap_out,swap_in);
              relaxConstant=simplex->relaxConstants->get(swap_out);
//写入新的位置swap_in,更新松弛约束中的常数项
              relaxConstant/=factor;
              const       float    swap_in_constant=relaxConstant;
              simplex->relaxConstants->set(swap_in,relaxConstant);
//更新swap_in行的松弛约束表达式
//在新的松弛约束中加入swap_out非基本变量
              simplex->relaxExpressRestrict->set(swap_in,swap_out,1.0f/factor);
              for(i=0;i<simplex->nonbasicVariableIndexes->size;++i)
             {
                            j=simplex->nonbasicVariableIndexes->get(i);
//取出源松弛约束中的系数
                            relaxConstant=simplex->relaxExpressRestrict->get(swap_out,j);
                            relaxConstant/=factor;
//写入新的松弛约束行中
                            simplex->relaxExpressRestrict->set(swap_in,j,relaxConstant);
              }
//更新剩余的松弛约束行
               for(i=0;i<simplex->basicVariableIndexes->size;++i)
              {
//首先加入新的swap_out非基本变量约束
                           k=simplex->basicVariableIndexes->get(i);
                           if(  k  !=  swap_out   )
                          {
                                      relaxConstant=simplex->relaxConstants->get(k);
                                      relaxConstant-=simplex->relaxExpressRestrict->get(k,swap_in)*swap_in_constant;
                                      simplex->relaxConstants->array[k]=relaxConstant;
//更新剩余的松弛约束中非基本变量的系数
                                      coef=simplex->relaxExpressRestrict->get(k,swap_in);
                                      for(j=0;j<simplex->nonbasicVariableIndexes->size;++j)
                                     {
                                                 int     column=simplex->nonbasicVariableIndexes->get(j);
                                                 if( column !=  swap_in )//剔除掉换入变量
                                                {
//查找系数
                                                           relaxConstant=simplex->relaxExpressRestrict->get(k,column);
                                                           relaxConstant-=simplex->relaxExpressRestrict->get(swap_in,column)*coef;
                                                           simplex->relaxExpressRestrict->set(k,column,relaxConstant);
                                                 }
                                      }
//最后加上换出变量swap_out的系数约束
                                      relaxConstant=-coef/factor;
                                      simplex->relaxExpressRestrict->set(k,swap_out,relaxConstant);
                           }
               }
//更新目标函数
//1:常数项
               simplex->objectConstant+=simplex->objectFunc->get(swap_in)*swap_in_constant;
//更新剩余的目标函数中的常数项
              relaxConstant=simplex->objectFunc->get(swap_in);
              simplex->objectFunc->array[swap_out]=-relaxConstant*1.0f/factor;
              for(i=0;i<simplex->nonbasicVariableIndexes->size;++i)
             {
                               k=simplex->nonbasicVariableIndexes->get(i);
                               if( k !=swap_in )
                              {
                                             coef=simplex->objectFunc->get(k);
                                             coef-=simplex->relaxExpressRestrict->get(swap_in,k)*relaxConstant;
                                             simplex->objectFunc->set(k,coef);
                               }
              }
//将swap_in从非基本变量集合中删掉,swap_out从基本变量集合中删掉
//并将两者相互添加到对方原来所在的集合中
            for(i=0;i<simplex->nonbasicVariableIndexes->size;++i )
           {
                            if(  simplex->nonbasicVariableIndexes->get(i)  == swap_in )
                           {
                                             simplex->nonbasicVariableIndexes->set(i,swap_out);
                                             break;
                            }
            }
            for(i=0;i<simplex->basicVariableIndexes->size;++i)
           {
                             if(simplex->basicVariableIndexes->get(i) == swap_out)
                            {
                                          simplex->basicVariableIndexes->set(i,swap_in);
                                          break;
                             }
            }
  }
//检测,目标函数中是否有一个系数大于0,如果有大于0并且是最大的的系数,在idx中返回她的索引
   static           bool            isCoefficientPositive(CSimplex   *simplex,int     *idx)
  {
//注意下面的寻址方式
             int           udx=-1;
             float        factor=0.0f;
             for(int  i=0;i<simplex->nonbasicVariableIndexes->size;++i)
            {
                         int        k=simplex->nonbasicVariableIndexes->array[i];
                         if(simplex->objectFunc->array[k] >factor )
                        {
                                       factor=simplex->objectFunc->array[k];
                                       udx=k;
                         }
             }
             *idx=udx;
             return         udx != -1;
    }
//单纯形算法,如果运行成功，会在result中返回运算的最终结果
   CSimplexType          simplex_algorithm(CSimplex         *simplex,float     *result)
  {
                 const           float         einf=1e8;
                 float             factor,relax;
                 int                i,j,k;
                 int                idx;
//首先初始化最初的标准型
                 if(  init_simplex(simplex) == CSimplexTypeInvalide )
                            return    CSimplexTypeInvalide;
//                 printf("init_simplex over -----------------\n");
                 while(  isCoefficientPositive(simplex,&idx)  )
                {
//在所有的松弛约束中,选择一个最紧凑的一个
                                printf("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
                                factor=einf;
                                j=-1;
                                for(i=0;i<simplex->basicVariableIndexes->size;++i)
                               {
                                             k=simplex->basicVariableIndexes->get(i);
                                             relax=simplex->relaxExpressRestrict->get(k,idx);
                                             if(  relax>0.0f )
                                            {
                                                          float            value=simplex->relaxConstants->get(k)/relax;
                                                          if( value<factor )
                                                         {
                                                                           factor=value;
                                                                           j=k;
                                                          }
                                             }
                                }
//如果没有找到使得factor!=einf的解,说明此单纯型是无界的
                                if( j == -1)
                                           return       CSimplexTypeNoBound;
//剩下的步骤,基变量与非基变量之间的转换
                                 swap_pivot(simplex,j,idx);
                 }
                 *result=simplex->objectConstant;
//注意,在剩下的解码步骤中，将集合simplex->basicVariableIndexes中的基本变量设定为0就可以求出最后的解
                 return     CSimplexTypeOK;
   }
//标准型转换为松弛型
//request:simplex的各个一维的列和二维数组的行列要比其中变量+松弛约束的数目之和大1,
//@request:否则会出现数组访问越界,运行时异常
   CSimplexType              init_simplex(CSimplex          *simplex)
  {
                 float               factor=1e8;
                 float               coef,value;
                 int                  i,j,k;
//检测常系数
                  j=-1;
                 for(i=0;i<simplex->basicVariableIndexes->size;++i)
                {
                                k=simplex->basicVariableIndexes->get(i);
                                coef=simplex->relaxConstants->get(k);
                                if( coef <factor)
                               {
                                                factor=k;
                                                j=k;
                                }
                 }
//如果没有负的常系数,此时就可以直接返回
                 if(  factor>=0.0f)
                             return      CSimplexTypeOK;
//否则,执行变换
//重新建立新的线性规划数据结构,并使用新的结构来判断当前的结构是否有最优解,代码稍后实现
//加入新的非基变量(m+n-1),设定目标函数为max=-X(m+n-1),如果目标函数的最优值不为0,则线性规划是不可行的的
                 CSimplex       asimplex;
                 CSimplex       *other=&asimplex;
                 other->basicVariableIndexes=new    CArray<int>(simplex->basicVariableIndexes->size);
                 other->nonbasicVariableIndexes=new   CArray<int>(simplex->nonbasicVariableIndexes->size+1);
                 const int           size=other->basicVariableIndexes->size+other->nonbasicVariableIndexes->size;
                 other->relaxConstants=new   CArray<float>(size);
                 other->relaxExpressRestrict=new    CArray2D<float>(size,size);
                 other->objectFunc=new   CArray<float>(size);
//使用源数据对新生成的数据结构进行初始化
//目标函数
                 other->objectFunc->fillWith(0.0f);
                 other->objectFunc->array[size-1]=-1;
//基变量
                 other->basicVariableIndexes->copyWith(simplex->basicVariableIndexes);
//非基变量
                 other->nonbasicVariableIndexes->copyWith(simplex->nonbasicVariableIndexes);
                 other->nonbasicVariableIndexes->array[i]=size-1;
//常数项
                 other->relaxConstants->copyWith(simplex->relaxConstants);
//交换,求解当前的线性规划是否有可行解
                 swap_pivot(other,j,size-1);
                 int                idx;
                 while( isCoefficientPositive(other,&idx)  )
                {
                              factor=1e8;
                              j=-1;
                              for(i=0;i<other->basicVariableIndexes->size;++i)
                             {
                                             k=other->basicVariableIndexes->array[i];
                                             coef=other->relaxExpressRestrict->get(k,idx);
                                             if(coef>0)
                                            {
                                                           value=other->relaxConstants->array[k]/coef;
                                                           if(value<factor)
                                                          {
                                                                         factor=coef;
                                                                         j=k;
                                                           }
                                             }
                               }
                               if( j == -1 )
                                        return         CSimplexTypeNoBound;
                               swap_pivot(other,j,idx);
                 }
//检测最后的目标值
                 if( other->objectConstant < 0.0f  )
                            return       CSimplexTypeInvalide;
//将变量size-1剔除掉
                 simplex->objectFunc->copyWith(other->objectFunc,size-1);
                 simplex->objectConstant=other->objectConstant;
//从非基变量集合中将size-1剔除掉
                for(j=0,i=0;i<size;++i  )
               {
                            if(  other->nonbasicVariableIndexes->array[i] != size-1  )
                                       simplex->nonbasicVariableIndexes->array[j++]=other->nonbasicVariableIndexes->array[i];
                }
//严格地说，size-1不会在基变量集合中出现,
                for( j=0,i=0;i<size;++i )
               {
                            k=other->basicVariableIndexes->array[i];
                            if(  k != size-1 ) 
                                      simplex->basicVariableIndexes->array[j++]=k;
                }
//二维系数矩阵复制
                for(i=0;i<size-1;++i)
               {
                             for(j=0;j<size-1;++j)
                            {
                                             factor=other->relaxExpressRestrict->get(i,j);
                                             simplex->relaxExpressRestrict->set(i,j,factor);
                             }
                }
//松弛约束的常系数
                 simplex->relaxConstants->copyWith(other->relaxConstants);
                 return            CSimplexTypeOK;
   }
 //
    int               main(int       argc,char     *argv[])
   {
                 CSimplex            asimplex;
                 CSimplex            *simplex=&asimplex;
//系数矩阵,注意这是松弛型系数
                 const                  int                       size=4;
                 float                    coefficient[4][4]={
                                                          {0,0,2,-1},{0,0,1,-4}
                                                };
//松弛表达式的系数集合
                 float                    relaxConstants[5]={2,-4};
//目标函数
                 float                    objectFunc[5]={0,0,2,-1};
                 float                    objectConstant=0.0f;
//基本变量集合
                 int                       variableSize=2;
                 int                       basicVariable[2]={0,1};
//非基本变量集合
                 int                       nonVariableSize=2;
                 int                       nonbasicVariable[3]={2,3};
//创建单纯型数据结构
                 int                       i,j,k;
                 simplex->basicVariableIndexes=new    CArray<int>(variableSize);
                 simplex->nonbasicVariableIndexes=new    CArray<int>(nonVariableSize);
                 simplex->relaxConstants=new     CArray<float>(size);
                 simplex->relaxExpressRestrict=new    CArray2D<float>(size,size);
                 simplex->objectFunc=new     CArray<float>(size);
//使用程序里面的数据写入到单纯型数据结构中
                 for(i=0;i<simplex->basicVariableIndexes->size;++i)
                              simplex->basicVariableIndexes->array[i]=basicVariable[i];
                 for(i=0;i<simplex->nonbasicVariableIndexes->size;++i)
                              simplex->nonbasicVariableIndexes->array[i]=nonbasicVariable[i];
//常数项
                 for(i=0;i<simplex->relaxConstants->size;++i)
                              simplex->relaxConstants->array[i]=relaxConstants[i];
//系数矩阵
                 for(i=0;i<simplex->relaxExpressRestrict->rowCount();++i)
                              for(j=0;j<simplex->relaxExpressRestrict->columnCount();++j)
                                                 simplex->relaxExpressRestrict->set(i,j,coefficient[i][j]);
//目标函数
                 for(i=0;i<simplex->objectFunc->size;++i)
                              simplex->objectFunc->array[i]=objectFunc[i];
                 simplex->objectConstant=objectConstant;
                 float         result;
//                 printf("begin--------------------\n");
                 if(  simplex_algorithm(simplex,&result) == CSimplexTypeOK )
                             printf("result  is %f  \n",result);
                 else
                             printf(" error    !\n");
                 return        0;
    }
    