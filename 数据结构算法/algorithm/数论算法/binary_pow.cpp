/*
  *@aim:二进制幂的两种实现
  *&2016-3-2 20:19:47
  */
#include<stdio.h>
   int         _left_right_pow(int   a,int   b)
 {
             int         c=1;
             int         d;
 
             for(d=(sizeof(int)<<3)-1;d>=0;--d)
            {
                        c=c*c;
                        if(   b  & (1<<d) )
                                   c=c*a;
             }
             return     c;
  }
//从右向左
   int          _right_left_pow(int   a,int   b)
  {
             int        _factor=a;
             int        d=b&0x1?a:1;
   
             b>>=1;
             while(   b  ) 
            {
                        _factor=_factor*_factor;
                        if( b & 0x1 )
                                     d=d*_factor;
                        b>>=1;
             }
             return    d;
   }
   
   int        main(int    argc,char    *argv[])
  {
              const         int          a=4;
              const         int          b=5;
              int             c=_left_right_pow(a,b);
              printf("_left_right_pow(%d,%d):%d\n",a,b,c);
              int             d=_right_left_pow(a,b);
              printf("_right_left_pow(%d,%d):%d\n",a,b,d);
              
              return   0;
   }