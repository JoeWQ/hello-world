/*
  *ŷ������㷨
  *
  */
/****************��ⷽ��  ax+by=gcd(a,b)�Ľ�************************************/

#include<stdio.h>
struct      Solve
{
      int     r;
      int     x;
      int      y;
};
//���ù���,a>b>=0
 void        euclide_extend(int   a,int   b,struct   Solve    *s)
{
        int        r,x,y;
//�ݹ�վ
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
//��ǰa�������Լ��
        r=a;
        s->r=r;
        x=1,y=0;
//�Ե����ϼ���x,y��ֵ
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
//***********************************************************
  int    main(int   argc,char   *argv[])
 {
         struct      Solve      ss,*s=&ss;
         int     a=24;
         int      b=4;
//
         euclide_extend(a,b,s);
         printf("ax+by=d: %d*%d+%d*%d=%d\n",a,s->x,b,s->y,s->r);
//
         a=14,b=4;
         euclide_extend(a,b,s);
         printf("ax+by=d: %d*%d+%d*%d=%d\n",a,s->x,b,s->y,s->r);
//
         a=25,b=7;
         euclide_extend(a,b,s);
         printf("ax+by=d: %d*%d+%d*%d=%d\n",a,s->x,b,s->y,s->r);
//
         a=5,b=17;
         euclide_extend(a,b,s);
         printf("ax+by=d: %d*%d+%d*%d=%d\n",a,s->x,b,s->y,s->r);
//
         a=20,b=8;
         euclide_extend(a,b,s);
         printf("ax+by=d: %d*%d+%d*%d=%d\n",a,s->x,b,s->y,s->r);
         return  0;
 }
