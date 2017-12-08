/*
  *@aim:整数的质因数分解
  *@date:2015-6-16
  */
  #include<stdio.h>
  #include<math.h>
  //任何一个大于1的整数都可以分解为n= p1^e1 * p2^e2 * p3*e3 ......pn^en
  //其中pi为素数,ei为整数
  //final_size返回分解的素数的指数
  void            factor_decompose(int      integer,int    *factor,int    *e,int   *final_size)
 {
                 int           d;
                 int           now;
                 int           size=0;;
                 int           wa;
                 
                 int            k=(int)sqrt(integer)+1;
                 for(d=2;d<k;++d)
                {
                             if(  integer%d == 0  )
                            {
                                           factor[size]=d;
                                           e[size]=0;
                                           while(  integer%d ==0 )
                                          {
                                                        ++e[size];
                                                        integer/=d;
                                           }
                                           ++size;
                                           if(integer == 1)
                                                 break;
                             }
                 }
                 if(integer != 1)
                {
                              factor[size]=integer;
                              e[size]=1;
                              ++size;
                 }
                 *final_size=size;
  } 
 //
    int        main(int    argc,char   *argv[])
   {
                int                     factor[64];
                int                     e[64];
                int                     size=64;
                int                     final_size;
                
                int                    i;
                factor_decompose(64,factor,e,&final_size);
                for(i=0;i<final_size;++i)
                    printf("%d ^ %d     ",factor[i],e[i]);
                printf("\n");
                
                factor_decompose(81,factor,e,&final_size);
                for(i=0;i<final_size;++i)
                    printf("%d ^ %d     ",factor[i],e[i]);
                printf("\n");
                
                factor_decompose(95,factor,e,&final_size);
                for(i=0;i<final_size;++i)
                    printf("%d ^ %d     ",factor[i],e[i]);
                printf("\n");
                
                factor_decompose(105,factor,e,&final_size);
                for(i=0;i<final_size;++i)
                    printf("%d ^ %d     ",factor[i],e[i]);
                printf("\n");                
                return      0;
    }