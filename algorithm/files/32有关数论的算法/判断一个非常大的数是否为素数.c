//2013年3月28日9:32:20
//判断一个非常大的数字 是否为素数
  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>

//求 a^b mode m 的值
  static  int  modular_extention(int  a,int  b,int m)
 {
       int  i,k,d;

       k=0;
       d=1;
       for(i=0;i<32;++i)
      {
              if( b & (1<<i) )
                   k=i;
       }
       for(i=k;i>=0;--i)
      {
              d=d*d%m;
              if( b & (1<<i) )
                    d=d*a%m;
       }
       return d;
  }
//判断一个数字是否为合数,求 a^b mode m (b=m-1)的另一种快速实现,和上面的函数一样，
//这个函数也需要一定的有关数论的知识
  static  int  witness(int  a,int  m)
 {
       int  i,k,w;
       int  x,y=0;
       int  b=m-1;
//首先对b进行分解 是b=w*2^k
       k=0;
       for(i=0;i<32;++i)
      {
             if( b & (1<<i) )
                   break;
             else
                   k=i+1;
       }
       w=b>>k;
       x=modular_extention(a,w,m); //求a^w mod m
//下面采用的是 有关平方剩余的一个推论
       for(i=0;i<k;++i)
      {
             y=x*x%m;
//注意这一步，要理解 (m-1)亦即-1 究竟意味着什么,它代表着平凡的平方剩余数
             if(y==1 && x!=1  && x!=b)
                  return 1;
             x=y;
       }
       if(x!=1)
             return 1;
       return 0;
  }
//判断一个非常大得数字是否为素数
  int  prim(int  n)
 {
       int   i,factor[12];

       factor[0]=2;
       for(i=1;i<12;++i)
              factor[i]=rand()%n;
//下面的过程可以在 较大的几率下确定一个数字是否为素数
       for(i=0;i<12;++i)
      {
              if(factor[i]<2)
                   continue;
              if( witness(factor[i],n) )
                   return 0;
       }
       return 1;
  }
  int  main(int  argc,char  *argv[])
 {
       int  n=0xFFFFFFFF;
       --n;
       srand(time(NULL));
       if( prim( (1<<7 )-1) )
              printf("素数!\n");
       printf("\n*******************************************\n");
       if( prim(97) )
              printf("4999素数!\n");

       printf("\n7 ^ 560 mod 561= %d \n",modular_extention(7,560,561));
       printf("\n2^ 63 mod 127=%d  \n",modular_extention(2,63,127));
       return 0;
  }