//2013��3��27��10:17:10
//���÷���ƽ������  a^b % m
  #include<stdio.h>
  
//ע������Ĵ��룬���ǳ��ؼ�࣬����Ҳ�������
//����˼·�����÷���ƽ����,��������漰���Ƚϸ�����й����۵�֪ʶ
  int   modular_power(int  a,int  b,int  m)
 {
        int  i,d=1;
        int  c,n,k;
//��ȡb�������Чλ ������
        for(i=0,n=32;i<n;++i)
       {
               if( b &  (1<<i))
                      k=i;
        }
//�����Ƿ���ƽ����������
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

        
        