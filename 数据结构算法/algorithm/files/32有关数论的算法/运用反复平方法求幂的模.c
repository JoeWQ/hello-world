//2013年3月27日10:17:10
//运用反复平方法求  a^b % m
  #include<stdio.h>
  
//注意下面的代码，它非常地简洁，但是也很难理解
//它的思路是运用反复平方法,这个过程涉及到比较高深得有关数论的知识
  int   modular_power(int  a,int  b,int  m)
 {
        int  i,d=1;
        int  c,n,k;
//求取b的最高有效位 的索引
        for(i=0,n=32;i<n;++i)
       {
               if( b &  (1<<i))
                      k=i;
        }
//下面是反复平方法的运用
        for(i=k;i>=0;--i)
       {
               d= d*d %m;
               if(b & (1<<i) )
                    d=d*a%m;
        }
        return d;
  }
//
  int  main(int argc,char  *argv[])
 {
        int   a=7;
        int   b=560;
        int   m=561;
        printf("( %d ^ %d )mod %d = %d \n",a,b,m,modular_power(a,b,m));
        return 0;
  }

        
        