//2013��3��28��9:32:20
//�ж�һ���ǳ�������� �Ƿ�Ϊ����
  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>

//�� a^b mode m ��ֵ
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
//�ж�һ�������Ƿ�Ϊ����,�� a^b mode m (b=m-1)����һ�ֿ���ʵ��,������ĺ���һ����
//�������Ҳ��Ҫһ�����й����۵�֪ʶ
  static  int  witness(int  a,int  m)
 {
       int  i,k,w;
       int  x,y=0;
       int  b=m-1;
//���ȶ�b���зֽ� ��b=w*2^k
       k=0;
       for(i=0;i<32;++i)
      {
             if( b & (1<<i) )
                   break;
             else
                   k=i+1;
       }
       w=b>>k;
       x=modular_extention(a,w,m); //��a^w mod m
//������õ��� �й�ƽ��ʣ���һ������
       for(i=0;i<k;++i)
      {
             y=x*x%m;
//ע����һ����Ҫ��� (m-1)�༴-1 ������ζ��ʲô,��������ƽ����ƽ��ʣ����
             if(y==1 && x!=1  && x!=b)
                  return 1;
             x=y;
       }
       if(x!=1)
             return 1;
       return 0;
  }
//�ж�һ���ǳ���������Ƿ�Ϊ����
  int  prim(int  n)
 {
       int   i,factor[12];

       factor[0]=2;
       for(i=1;i<12;++i)
              factor[i]=rand()%n;
//����Ĺ��̿����� �ϴ�ļ�����ȷ��һ�������Ƿ�Ϊ����
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
              printf("����!\n");
       printf("\n*******************************************\n");
       if( prim(97) )
              printf("4999����!\n");

       printf("\n7 ^ 560 mod 561= %d \n",modular_extention(7,560,561));
       printf("\n2^ 63 mod 127=%d  \n",modular_extention(2,63,127));
       return 0;
  }