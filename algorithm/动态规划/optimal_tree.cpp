/*
  *@aim:�����Ŷ��������
  *@date:2014-9-26
  *@author:�ҽ���
  */
  #include"Array.h"
  #include<stdio.h>
//�������
  #define    infine        0x3FFFFFFF 
/*
  *@func:optimal_tree
  *@param: pΪ���ڵ�Ĵ��ۣ�
  *@param: dΪp������Ľڵ��Ҷ�ӽڵ�Ĵ���
  *@param: eΪ �������д��۵�����ʢ��λ��
  *@param: wΪ ��һ������ d[i]--d[j]���۵Ĺ��������������ʢ��λ��
  *@note:d�ĳ���Ϊsize+1
  *@request:p�����������
  */
//       p0      p1       p2       p3        p4        p5        p6         p7
//  d0      d1        d2       d3       d4        d5        d6        d7         d8
   void      optimal_tree(Array   *e,Array   *w,Array   *r,int    *p,int    *d,int   size)
  {
            int       i,j,k,m;
            int       f,t,trace;
//��ʼ���Թ����������ص��Ĳ��ֽ��е�һ�ֵ��������
            for( i= 1;i<=size+1; ++ i )
           {
                     e->set(i,i-1,d[i-1]);
                     w->set(i,i-1,d[i-1]);
            }
//���µĹ��̶��ǽ������ص��������ϣ�������ǰ�������⹹�쵱ǰ�����Ž�
//ÿ�εݽ�����ȡ�����������еĳ���
            for( i= 1;i<=size;++i )
           {
//��ַ
                     for( j=1; j <=size-i+1; ++j  )
                    {
                              f=infine;
                              trace=0;
//�ұ߽�
                              m=i+j-1;
//���� (j,m)��ֵ,ע�⣬�������������p�е����ݴ�����0��ʼ��Ч,������ʹ��ʱ��������m-1
                              w->set(j,m,  w->get(j,m-1) + p[m-1] +d[m]);
//�� i--j ֮������Ŷ��������
                              for( k=j; k<=m;++k)
                             {
                                       t =  e->get(j,k-1) + e->get(k+1,m) +w->get(j,m); 
                                       if(   f > t )
                                      {
                                               f=t;
                                               trace=k;
                                       }
                              }
                              e->set(j,  m,  f );
                              r->set(j,  m,  trace);
                     }
            }
   }
    int      main(int   argc,char    *argv[])
   {

            int       p[5]={5, 15, 25, 27 , 30};
            int       d[6]={7,6,12,20,16,18};
            int       size=5;
            Array      ee(size+2,size+2);
            Array      ww(size+2,size+2);
            Array      rr(size+2,size+2);
            Array      *e=&ee,*w=&ww,*r=&rr;
//
           int         i,j;
           for(i=0;i < size+2;++i)
          {
                  for(j=0;j<size+2;++j)
                 {
                           e->set(i,j,0);
                           w->set(i,j,0);
                           r->set(i,j,0);
                  }
          }
         optimal_tree(e,w,r,p,d,size);
         printf("-----------------------------e--------------------------\n");
         for(i=1;i<size+2;++i)
        {
                 for( j=0;j<i-1;++j)
                        printf("        ");
                 for( j =i-1;j < size+2;++j)
                        printf("%8d " ,e->get(i,j) );
                 putchar('\n');
         }
         printf("---------------------w------------------------------\n");
         for(i=1;i<size+2;++i)
        {
                 for( j=0;j<i-1;++j)
                        printf("          ");
                 for( j =i-1;j < size+2;++j)
                        printf("%8d" ,w->get(i,j) );
                 putchar('\n');
         }
         printf("-----------------------r----------------------------\n");
         for(i=1;i<size+2;++i)
        {
                 for( j=0;j<i-1;++j)
                        printf("        ");
                 for( j =i-1;j < size+2;++j)
                        printf("%8d" ,r->get(i,j) );
                 putchar('\n');
         }
         return  0;
    }
