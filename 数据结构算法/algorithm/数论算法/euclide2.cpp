/*
  *@aim:使用欧几里得算法求解不定方程
  */
  #include<stdio.h>
   struct      EuclideResult
  {
  //最大公约数
              int         gcd;
 //输入结果的乘数因子  a*x+b*y=gcd;
              int         x,y;
   };
 //@request:a>=b>0
   void              euclide_algorithm(int    a,int    b,EuclideResult     *result)
  {
               int           gcd=1;
               int           trace[32];
               int           size=0;
               while( b )
              {
                           trace[size]=a;
                           gcd=a%b;
                           a=b;
                           b=gcd;
                           ++size;
               }
 //可以肯定，此时a的结果一定是输入数字的最大公约数,trace[size-1]一定不是最大公约数
               result->gcd=a;
                int            x=0,y=1;
                while(--size>0)
                {
                           b=a;
                           a=trace[size];
                           gcd=y;
                           y=x-a/b*y;
                           x=gcd;
                }
                result->x=x;
                result->y=y;
   }
   int    main(int    argc,char   *argv[])
  {
               EuclideResult             result;
               int           a,b;
               a=24,b=14;
               euclide_algorithm(a,b,&result);
               printf("%d*%d+%d*%d=%d\n",a,result.x,   b, result.y,result.gcd);
               
               a=4,b=2;
               euclide_algorithm(a,b,&result);
               printf("%d*%d+%d*%d=%d\n",a,result.x,   b, result.y,result.gcd);

               a=25,b=7;
               euclide_algorithm(a,b,&result);
               printf("%d*%d+%d*%d=%d\n",a,result.x,   b, result.y,result.gcd);
               return    0;
   }