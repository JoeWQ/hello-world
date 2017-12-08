/*
  *@aim:矩阵LU算法求解线性方程组
  *@date:2015-6-9
  *@request:线性方程组的系数矩阵的行列式不等于0
  */
#include"CArray2D.h"
#include<stdio.h>
//函数在这里不会检查输入参数的有效性
//@param:lu线性方程组的系数矩阵
//@request:输入都是方阵,coeff->rowCount()==lu->columnCount()
//@request:coef对角线系数不为0
//@return:系数矩阵的LU分解,并将结果写入lu中，
//@note:函数会将LU两个矩阵合并到lu中，同时我们假定使用者对这两种矩阵的结构非常了解
//@note:所以对矩阵的解码也能完全由自己解决
  void         lu_matrix_decomposite(CArray2D<float>    *coef,CArray2D<float>   *lu)
 {
                float           factor;
                int              i,j,k;
                int              n=coef->rowCount();
 //第一行首先写入矩阵左上角元素,根据下文,很明显我们不会将这个元素写入到lu矩阵中               
                lu->copyWith(coef);
                for(k=0;k<n;++k)
               {
                             factor=lu->get(k,k);
                             for(j=k+1;j<n;++j)
//两侧的列,行向量         
                                          lu->set(j,k,   lu->get(j,k)/factor   );
//计算Schur补矩阵
                            for(i=k+1;i<n;++i)
                           {
                                         for(j=k+1;j<n;++j)
                                        {
                                                    factor=lu->get(i,j)-lu->get(k,j)*lu->get(i,k);
                                                    lu->set(i,j, factor );
                                         }
                            }
                }
  }
 //对LU矩阵进行解码，以求解线性方程组
 //@param:b方程右边的结果
 //@return:在a中写入方程求解的结果
   void               solve_linear_equation(CArray2D<float>    *coef,float    *b,float   *a)
  {
                 float          factor;
                 int             i,k;
                 int             n=coef->rowCount();
//矩阵分解
                 CArray2D<float>           alu(n,n);
                 CArray2D<float>           *lu=&alu;
                 lu_matrix_decomposite(coef,lu);
//求解下三角系数矩阵方程组
                 for(i=0;i<n;++i)
                {
                             factor=b[i];
                             for(k=0;k<i;++k)
                                          factor-=lu->get(i,k)*a[k];
                             a[i]=factor;
                 }
//求解上三角系数矩阵方程组
                 for( i=n-1  ;i>=0;--i)
                {
                              factor=a[i];
                             for(k=n-1;k>i;--k)
                                        factor-=lu->get(i,k)*a[k];
                             a[i]=factor/lu->get(i,i);
                 }
   }
 //************************************************
   int          main(int    argc,char     *argv[])
  {
                 int            size=4;
//4*4系数矩阵
                 float            coefficient[4][4]={
                                                               {4,5,3,1},{6,7,1,1},{1,2,8,9},{2,9,10,5}
                                                   };
                 float            b[4]={7,10,16,25};
                 float            a[4];
                 CArray2D<float>           acoef(size,size);
                 CArray2D<float>           *coef=&acoef;
                 int               i,k;
                 for(i=0;i<size;++i)
                            for(k=0;k<size;++k)
                                        coef->set(i,k,coefficient[i][k]);
                  solve_linear_equation(coef,b,a);
//验证结果
                  for(i=0;i<size;++i)
                 {
                              float      factor=0;
                              for(k=0;k<size;++k)
                                         factor+=a[k]*coefficient[i][k];
                              printf("row %d ,result is %f\n",i,factor);
                  }
                  return   0;
   }
   