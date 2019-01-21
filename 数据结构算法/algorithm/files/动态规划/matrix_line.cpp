/*
  *@aim:�������˷��Ķ�̬�滮˼��ʵ��
  *@time:2014-9-22
  *@author:�ҽ���
  */

  #include"array.h"
  #include<stdio.h>
  #define       infine       0x3FFFFFFF
/*
  *@func:matrix_line_multiply
  *@aim:�������˷�����С����
  */
/*
  *@param:r,��¼ÿ�η��Ѿ������С���ۣ�r[i][j]��ʾ����i,i+1.....j֮��˷�����С������
  *@param:s,��¼ÿ�η��Ѿ�����С���۴�������
  *@param p:�������е�ά����ע��p[i]��ʾ��ʾ����i��������i=1,2,3,....size,p[0]��ʾ����1������,���ھ���˷��Ĺ�����μ��ߵȴ���
  */
  void    matrix_line_multiply(Array   *r,Array     *s,int     *p,int    size)
 {
        int             d;//ÿ�ξ������ĳ���
        int             i,j;
//��ʱ����
        int             e,t;
//��ʼ���Խ���Ԫ�ظ�ֵΪ0����Ϊ���������ǲ������κγ˷������
        for(i=1;i<=size;++i)
       {
                r->set(i,i,0);
                s->set(i,i,0);
        }
//�Ե������ع�
//���ȵݽ�,ע�����������һ���������ȣ����i�ǻ�ַ��d�ͱ�ʾ��(i,��i+d�ķ�Χ)
        for(  d=1;d<size;++d)
       {
//���������(i,i+1,i+2,....   i+d)����С�������
                for( i=1; i<=size-d;++i  )
               {
                         e=infine;
                         for(  j=i ; j<i+d;++j  )
                        {
                                    t = r->get(i,j) + r->get(j+1,i+d) +p[i-1] *p[j]*p[i+d];
                                    if(   t  <   e )
                                   {
                                           e=t;
                                           s->set(i,i+d,j);
                                   }
                         }
                         r->set(i,i+d,e);
                }
        }
   }
   int      main(int   argc,char    *argv[])
  {
        int     p[5]={100,10,80,9,50};      
        int     size=4;
        Array     a(size,size),b(size,size);
        Array     *r=&a,*s=&b;
//
        matrix_line_multiply(r,s,p,size);
//���������
        int        i=0,j=0;
        printf("output value of min   quantity of multiply :\n");
        for(i=1;i<=size;++i)
       {
             for(j=1;j<i;++j)
                    printf("      ");
             for( j=i ; j<= size ;++j)
                    printf("%6d",r->get(i,j));
             putchar('\n');
       }
//
        printf("output index of min quantity of multiply:\n");
        for(i=  1;  i <=size;++i)
       {
                  for(  j=1; j<i;++j)
                        printf("      ");
                  for(j=i;j<=size;++j)
                        printf(" %6d",s->get(i,j));
                  putchar('\n');
        }
        return   0;
   }
