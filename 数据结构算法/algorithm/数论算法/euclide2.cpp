/*
  *@aim:ʹ��ŷ������㷨��ⲻ������
  */
  #include<stdio.h>
   struct      EuclideResult
  {
  //���Լ��
              int         gcd;
 //�������ĳ�������  a*x+b*y=gcd;
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
 //���Կ϶�����ʱa�Ľ��һ�����������ֵ����Լ��,trace[size-1]һ���������Լ��
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