/*
  *@aim:�����������
  *@time:2014-9-23
  *@author:�ҽ���
  */
//
   #include"array.h"
   #include<string.h>
   #include<stdio.h>
/*
  *@func:longest_common_sequence
  *@aim:����������У���̬�滮ʵ��
  *@param:@sԭ�ַ�����dĿ���ַ�����x[i][j],��¼s,d��ǰ׺(i,j)(i>0,j>0)�������������
  *@param:@y��¼����x[i][j]��������������У���һ��������е�����
  */
//�����ǰ��i,��j
  enum    SequenceOption
 {
         SO_MIDDLE,//ǰ����м�һ������i-1,j-1
         SO_UP,       //ѡȡ �ϲ�i-1,j
         SO_LEFT  //ѡȡ��� i,j-1
  };
   void      longest_common_sequence(char    *s,char    *d,Array    *x,Array   *y)
  {
           int      i,j,k;
           int      ssize,dsize;
//����Ĵ����ǲ�������ַ����ĳ���
           for(i=0; s[i] ; ++i)
                 x->set(i,0,0);
           ssize=i;
           for(j=0; d[j];++j )
                 x->set(0,j,0);
           dsize=j;
//�������������ȡ��ע�⣬���ĺ���˼���� ʹ�����ǵ�ǰ׺�����й��쵱ǰ�������������
           for(i=1; i <=ssize;++i)
          {
                    for(j=1;j<=dsize;++j)
                   {
                             if( s[i-1] == d[j-1] )
                            {
                                    x->set(i,j, x->get(i-1,j-1) +1   );
                                    y->set(i,j, SO_MIDDLE );
                            }
                             else if(  x->get(i-1,j) >=  x->get(i,j-1)  )
                            {
                                    x->set(i,j,x->get(i-1,j) );
                                    y->set(i,j, SO_UP );
                             }
                             else 
                            {
                                     x->set(i,j, x->get(i,j-1) );
                                     y->set(i,j, SO_LEFT );
                             }
                    }
           }
   }
    int    main(int    argc,char    *argv[])
  {
         char        *p="hello xiao huaxiong";
         char        *q="mxwthlhuangdrgq";
         int           psize=strlen(p);
         int           qsize=strlen(q);
         Array       xx(psize+1,qsize+1);
         Array       rr(psize+1,qsize+1);
//
         Array       *x=&xx;
         Array       *r=&rr;
         int            i,j;
//
         for(i=0;i<=psize;++i)
        {
                for(j=0;j<=qsize;++j)
               {
                       x->set(i,j,0);
                       r->set(i,j,0);
                }
         }
         longest_common_sequence(p,q,x,r);
//�����
         printf("longest common sequence is :%d\n",x->get(psize,qsize) );
//
         for(i=1;i<=psize;++i)
        {
 //                 for(j=0;j<i;++j)
  //                       printf("%3c",' ');
                  for(j=1;j<=qsize;++j)
                         printf("%3d",x->get(i,j));
                  putchar('\n');
         }
         printf("--------------------------------------------\n");
         for(i=1;i<=psize;++i)
        {
  //                for(j=0;j<i;++j)
 //                        printf("%3c",' ');
                  for(j=1;j<=qsize;++j)
                         printf("%3d",r->get(i,j));
                  putchar('\n');
         }
         return    0;
   }
