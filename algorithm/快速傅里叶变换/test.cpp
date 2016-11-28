/*
 *快速傅里叶变换测试
 */
#include"FastFFT.h"
#include<stdio.h>
#include<sys/time.h>
//int     reverse_low_bit(int ,int);
 void             polygon(float      *x,float     *y,float     *r,int    poly_size)
{
                int          i,j;
                int          size=poly_size<<1;
                for(i=0;i<poly_size;++i)
               {
                           for(j=0;j<poly_size;++j)
                                      r[i+j]=r[i+j]+y[j]*x[i];
                }
                for(i=0;i<poly_size;++i)
                                    r[i]=0;
 }
 int  main(int   argc,char   *argv[])
{
         float       x[2048];
         float       y[2048];
         float       r[2048];
         float       t[2048];
         int          size=2048;
         int          poly_size=1024;
//比较次数，10w次
         int          count=100000;
         int          i,j,k;
         struct    timeval    prev,next;
         int         copy_time;//复制数据花费的时间
//
        for(i=0;i<size;++i)
       {
               if(i<poly_size)
              {
                      x[i]=i+2;
                      y[i]=(i<<1)+1;
               }
               else
              {
                      x[i]=0;
                      y[i]=0;
              } 
              r[i]=0;
        }
//快速傅里叶变换 对象
         FastFFT       a(x,size);
         FastFFT       b(y,size);
//使用快速傅里叶变换
         FastFFT       *p=&a,*q=&b;
 //使用普通算法计算
        gettimeofday(&prev,NULL);
                 for(i=0;i<count;++i)
                            polygon(x,y,r,poly_size);
        gettimeofday(&next,NULL);
        printf("general method cost time :%d.%d\n",next.tv_sec-prev.tv_sec,(next.tv_usec-prev.tv_usec)/1000);
 //
        gettimeofday(&prev,NULL);
        q->fastTransform();
        for(k=0;k<count;++k)
       {
                 p->fastTransform();
                 p->polyMultiply(q);
                 p->reverse();
//数据的复制
                for(i=0;i<size;++i)
               {
                        p->root[i].real=x[i],p->root[i].img=0;
 //                       q->root[i].real=y[i],q->root[i].img=0;
                }
        }
        gettimeofday(&next,NULL);
        printf("Fourier method cost time :%d.%d\n",next.tv_sec-prev.tv_sec,(next.tv_usec-prev.tv_usec)/1000);
 /*       printf("1-->reverse(1,4): %d\n",reverse_low_bit(1,4));
        printf("2-->reverse(2,4): %d\n",reverse_low_bit(2,4));
        printf("3-->reverse(3,4): %d\n",reverse_low_bit(3,4));
        printf("4-->reverse(4,4): %d\n",reverse_low_bit(4,4));
        printf("5-->reverse(1,4): %d\n",reverse_low_bit(5,4));
*/
        putchar('\n');
         return    0;
 }
