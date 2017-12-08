/*
  *@aim:�й���������
  *@date:2015-6-13
  */
 #include<stdio.h>
  struct      CSolve
{
      int     r;
      int     x;
      int      y;
};
 //���ù���,a>b>=0
 void        euclide_extend(int   a,int   b,struct   CSolve    *s)
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
 //�й���������ʵ��
//���������ǲ������������ݵ���Ч��
//a������,m��ģ��
  int        china_remind_theory(int    *a,int   *m,int   size)
 {
              int           volume=1;
              int           i;
              int           s=0;
              int           every;
              struct      CSolve        asolve,*solve=&asolve;
              
              for(i=0;i<size;++i)
                          volume*=m[i];
              for(i=0;i<size;++i)
             {
                            every=volume/m[i];
                            euclide_extend(every,m[i],solve);
//
                            s=s+a[i]*every*solve->x;
              }
              return    (s%volume+volume)%volume;
  }
  int        main(int    argc,char    *argv[])
 {
              int           a[3]={2,3,2};
              int           m[3]={3,5,7};
              
              printf("%d\n",china_remind_theory(a,m,3) );
              return     0;
  }