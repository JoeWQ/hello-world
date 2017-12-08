/*
  *@aim:单变元模线性方程
  *@date:2015-6-13
  */
 #include<stdio.h>
 #include<vector>
 struct      CSolve
{
      int     r;
      int     x;
      int      y;
};
 //调用规则,a>b>=0
 void        euclide_extend(int   a,int   b,struct   CSolve    *s)
{
        int        r,x,y;
//递归站
        int        recur[32];
        int        size=0;
//********************************************************
        while( b )
       {
                recur[size++]=a;
                r=a%b;
                a=b;
                b=r;
        }
//当前a就是最大公约数
        r=a;
        s->r=r;
        x=1,y=0;
//自底向上计算x,y的值
        while(size > 0 )
       {
               b=a;
               a=recur[--size];
               r=y;
               y=x-y*(a/b);
               x=r;
        }
        s->x=x;
        s->y=y;
 }
 //单变元线性方程组,求ax==b(mod n)
 //如果方程有解返回true并将结果写入到vector中,否则返回false
   bool             line_modular_equation(int    a,int    b,int   n,std::vector<int>    *result)
  {
                struct      CSolve             asolve,*solve=&asolve;
                int           d;
                euclide_extend(a,b,solve);
                d=solve->r;
//只有当d能整除b时，莫线性方程才能有解
                if(  !  (b%d)  )
               {
                              int         x=solve->x;
                              x= (x+n)%n;
//此步保证x是在n的完备系中是最小的                              
                              x=(x*b/d)%(n/d);
                              result->push_back(x);
                              for(int   i=1;i<d;++i)
                                          result->push_back((x+i*n/d)%n);
                              return   true;
                }
                return   false;
   }
   int        main(int     argc,char    *argv[])
  {
              std::vector<int>             aresult,*result=&aresult;
              int                                    i=0;
              int                                    a=6,b=4,n=8;
              if(  line_modular_equation(a,b,n,result) )
             {
                            for(i=0;i<result->size();++i)
                                         printf("%d  ",result->at(i));
                            printf("\n");
              }
              a=5,b=2,n=6;
              result->clear();
              if(  line_modular_equation(a,b,n,result) )
             {
                            for(i=0;i<result->size();++i)
                                         printf("%d  ",result->at(i));
                            printf("\n");
              }
              return    0;
   }