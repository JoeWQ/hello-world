/*
  *@aim:��������֮������·��----����˷�ʵ��
  *@idea:��̬�滮˼��
  *@date:2014-11-7 11:34:17
  *@author:�ҽ���
  */
   #include"Array.h"
   #include<stdio.h>
   #include<stdlib.h>
   #define    infine      0x3FFFFFFF
/*
  *@function:matrix_multiple_method
  *@idea:����˷�ʵ��
  *@param:g�������֮������������������
  *@request:y,w,parent has same row and column count,and row=column
  */
   void     matrix_multiple_method(Array    *y,Array   *w,Array   *parent)
  {
               int      m,i,j,k;
               int      e,new_weight,pai;
// 
               int          row=y->getRow();
//��ʼ��Ȩֵ��һ�������ǰ�����ݱ�����
               pai=w->getInvalideValue();
               for(i=0;i<row;++i)
              {
                       for(j=0;j<row;++j)
                      {
                                 m=w->get(i,j);
                                 y->set(i,j,m );
//���i,j�������ֱ�ӿɴ��·��
                                 e=-1;
                                 if( i  !=  j )
                                {
                                             if( m !=  pai )
                                                   e=i;
                                 }
                                 parent->set(i,j,e);  
                       }
               }
               for(m=0;m<row-1;++m)
              {
                          for( i=0;i<row;++i)
                         {
                                      for(j=0;j<row;++j)
                                     {
                                                   if(j != i )
                                                  {
                                                              e=y->get(i,j);
                                                              pai=parent->get(i,j);
                                                              for(k=0;k<row;++k)
                                                             {
//�������һ�������Կ������ߵ�����ÿ��ֻ�ܿ��һ��
                                                                          new_weight=y->get(i,k)+w->get(k,j);
                                                                          if(  e > new_weight )
                                                                         {
                                                                                     e = new_weight;
                                                                                     pai = k;
                                                                          //           if( k == j )
                                                                           //               pai=i;
                                                                           }
                                                             }
                                                            y->set(i,j,e );
                                                            parent->set(i,j,pai);
                                                   }
                                     }
                            }
               }
   }
/*
  *@function:fast_matrix_multiple_method
  *@aim:���پ���˷�,�����溯��������ʱ�������������Ϊn*n*n*ln(n)
  *@request:same as above
  *@note:��ʹ���˿��پ���˷�֮��parent[i][j]����ʾ�ĺ���ͻᷢ���ش�ı仯�������ڱ�ʾj��ֱ��ǰ��
  *@note:���Ǳ�ʾi,j֮������·�����ֳ���������i--->parent->get(i,j) + parent->gert(i,j)---->j
  *@note:һ��Ҫע��������𣬷����ڽ���·����ʱ��ᷢ������Ҫ�����
  */
   void      fast_matrix_multiple_method(Array   *y,Array  *w,Array  *parent)
  {
             int        m,i,j,k;
             int        pai,e,row,new_weight;
//��ʼ�����ݸ���
            row = y->getRow();
            pai=   w->getInvalideValue();
            for( i=0;i<row;++i )
           {
                    for(j=0;j<row;++j)
                   {
                               m=w->get(i,j);
                               y->set(i,j,m );
//���i,j�������ֱ�ӿɴ��·��
                               e=-1;
                               if( i  !=  j )
                              {
                                         if( m !=  pai )
                                               e=i;
                               }
                              parent->set(i,j,e);     
                     }        
            }
//
            for(m=0;  (1<<m) <row-1;++m )
           {
                          for(   i=0;i<row;  ++i  )
                         {
                                     for(j=0;j<row;++j)
                                    {
                                                if(  i != j )
                                               {
                                                             e=y->get(i,j);
                                                             pai=parent->get(i,j);
                                                             for(k=0;k<row;++k)
                                                            {
//��������˼�����ͬ��Դ���·��һ��,����ͬ���ǣ����ڵ�Դ�Ǳ���i

                                                                                      new_weight=y->get(i,k)+y->get(k,j);
                                                                                      if(  e > new_weight )
                                                                                     {
                                                                                               e = new_weight;
                                                                                               pai = k;
                                                                                      } 
                                                              }
                                                             y->set(i,j, e );
                                                            parent->set(i,j,pai);
                                                 }
                                    } 
                          }
            }
   }
 //����
    int     main(int    argc,char   *argv[] )
   {
              int    adj[5][5]={
                                       {0,1,20,infine,3},
                                       {infine,0,infine,50,infine},
                                       {infine,infine,0,7,infine},
                                       {20,infine,infine,0,infine},
                                       {infine,infine,5,100,0}
                                 };
              int      size=5;
              int      i,j;
//Ȩֵ
              Array      weight(size,size);
              Array      *w=&weight;
              for(i=0;i<size;++i)
                      for(j=0;j<size;++j)
                          w->set(i,j,adj[i][j]);
              w->setInvalideValue(infine);
//ǰ������
            Array        parent(size,size);
//���·��
            Array        dist(size,size);
//
            Array        *y,*p;
            y=&dist,p=&parent;
//����˷�����������֮������·��
//            matrix_multiple_method(y,w,p);
//���پ���˷������·��
            fast_matrix_multiple_method(y,w,p);
//������
            printf("-------------------------------- shortest distance -------------------------------\n");
            for(i=0;i<size;++i)
           {
                        for(j=0;j<size;++j)
                                    printf("%8d",y->get(i,j));
                        putchar('\n');
            }
            printf("---------------------------------previous  vertex  ------------------------------------\n");
            for(i=0;i<size;++i)
           {
                        for( j=0;j<size;++j) 
                                    printf("%8d",p->get(i,j));
                        putchar('\n');
            }
            return    0;
    }
