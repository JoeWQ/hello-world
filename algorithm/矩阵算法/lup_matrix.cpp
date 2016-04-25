/*
  *@aim:线性方程组的系数矩阵的LUP分解
  *@date:2015-6-9
  */
  #include"CArray2D.h"
  #include<stdio.h>
  #include<math.h>
  #include<assert.h>
  //矩阵的LUP分解
  //@request:coef->rowCount()>=2,coef->rowCount()==lup->rowCount()
  //@request:输入的矩阵必须为方阵
  //@return:true如果矩阵是非奇异矩阵，false如果矩阵是奇异矩阵
  //@param:xchg为交换序列,也就是置换矩阵P的一维表示
    bool           lup_matrix_decomposite(CArray2D<float>   *coef,CArray2D<float>    *lup,int   *xchg)
   {
                 float            factor,e;
                 int               i,j,k;
                 int               n=coef->rowCount();
                 
//将置换矩阵初始化为单位矩阵
                 for(i=0;i<n;++i)
                                   xchg[i]=i;
                  lup->copyWith(coef);
                 for(k=0;k<n;++k)
                {
//查找最大系数
                                   factor=0.0f;
                                   j=-1;
                                   for(i=k;i<n;++i)
                                  {
//使用系数的绝对值
                                                  e=abs(lup->get(i,k));
                                                  if( e>factor)
                                                 {
                                                                factor=e;
                                                                j=i;
                                                  }
                                   }
//如果没有找到大于0的系数绝对值，直接跳出,此时说明矩阵的秩小于n
                                   if(j==-1 )
                                                 return    false;
//交换数字,如果有可能
                                   if(j  != k)
                                  {
                                               for(i=0;i<n;++i  )
                                              {
                                                           e=lup->get(k,i);
                                                           lup->set(k,i,   lup->get(j,i));
                                                           lup->set(j,i,e);
                                               }
//设置置换矩阵
                                               i=xchg[j];
                                               xchg[j]=xchg[k];
                                               xchg[k]=i;
                                   }
//其余部分与矩阵的LU分解是一样的
//factor一定要重新计算,因为上面使用的是矩阵的元素的绝对值
                                    factor=lup->get(k,k);
                                   for(i=k+1;i<n;++i)
                                                  lup->set(i,k,    lup->get(i,k)/factor);
//更新系数矩阵
                                   for(i=k+1;i<n;++i)
                                  {
                                                 for(j=k+1;j<n;++j)
                                                {
                                                               factor=lup->get(i,j)-lup->get(k,j)*lup->get(i,k);
                                                               lup->set(i,j,factor);
                                                 }
                                   }
                 }
                 return  true;
    }
//对返回的LUP矩阵解码,并求解线性方程组
//与矩阵的LU分解的解码相比,lup分解的解码当然地要相对复杂一些
//@return:true如果这个系数矩阵的行列式不等于0,那么返回方程的解,否则返回false
//@note:函数会修改系数矩阵,所以使用者一定要注意这一点
    bool               solve_linear_equation(CArray2D<float>    *coef,float        *b,float     *a)
   {
                 int                i,j,k;
                 float                factor;
                 const    int                n=coef->rowCount();
//
                 CArray2D<float>         alup(n,n);
                 CArray2D<float>         *lup=&alup;
//交换矩阵
                 int               *xchg=new     int[n];
//如果矩阵分解失败
                 if(  ! lup_matrix_decomposite(coef,lup,xchg))
                {
                              delete      xchg;
                              return     false;
                  }
//处理交换矩阵
                 for(i=0;i<n;++i)
                {
                               if(xchg[i] != i)
                              {
                                             factor=b[i];
                                             j=i;
                                             k=xchg[j];
                                             do
                                             {
                                                            b[j]=b[k];
                                                            xchg[j]=j;
                                                            j=k;
                                                            k=xchg[k];
                                              }while(k !=i);
                                              xchg[j]=j;
                                              b[j]=factor;
                               }
                 } 
//删除置换矩阵
                 delete       xchg;
                 xchg=NULL;
//求解下三角矩阵
                 for(i=0;i<n;++i)
                {
                               factor=b[i];
                               for(j=0;j<i;++j)
                                         factor-=lup->get(i,j)*a[j];
                               a[i]=factor;
                 }
//求解上三角矩阵
                 for(i=n-1;i>=0;--i)
                {
                                factor=a[i];
                                for(j=n-1;j>i;--j)
                                          factor-=lup->get(i,j)*a[j];
                                a[i]=factor/lup->get(i,i);
                 }
                 return    true;
    }
//
    int        main(int    argc,char    *argv[])
   {
                 int            size=4;
//4*4系数矩阵
                 float            coefficient[4][4]={
                                                               {4,5,3,1},{6,7,1,1},{1,2,8,9},{2,9,10,5}
                                                   };
                 float            b[4]={7,10,16,25};
                 float            a[4];
                 
                 CArray2D<float>            acoef(size,size);
                 CArray2D<float>            *coef=&acoef;
                 
                 int              i,j;
                 float           factor;
                 
                 for(i=0;i<size;++i)
                           for(j=0;j<size;++j)
                                          coef->set(i,j,coefficient[i][j]);
                 assert(   solve_linear_equation(coef,b,a) );
                 
                 for(i=0;i<size;++i)
                {
                              factor=0;
                              for(j=0;j<size;++j)
                                          factor+=coefficient[i][j]*a[j];
                              printf("row %d is %f\n",i,factor);
                 }
                 return  0;
    }