/*
  *@aim:Floyd���·���㷨ʵ��
  *@date:2014-11-8 17:42:17
  *@author:�ҽ���
  *@idea:��̬�滮
  */
   #include"Array.h"
   #include<stdio.h>
   #include<stdlib.h>
   #define      infine      0x3FFFFFFF
//
/*
  *@function:floyd_shortest_path
  *@idea:����ÿ��������֮����м䶥�㶼����0---k֮��,��ǰ��������ȫ����ʹ���ϴμ���Ľ��
  *@param:y���·�����,w�����Ȩֵ�ֲ�,parent���������ǰ��
  *@note:parent�е���������ʾ�ĺ�����μ�matrix_each_vertex_path.cpp fast_matrix_multiple������˵��
  */
   void    floyd_shortest_path(Array    *y,Array   *w,Array   *parent)
  {
           int     i,j,k;
           int     e,new_weight,pai;
           int     row=w->getRow();
//û�ж���֮��ֱ�������ӵ�ֵ
           pai = w->getInvalideValue();
           for(i=0;i <row;++i )
          {
                      for(j=0;j<row;++j)
                     {
                                e=w->get(i,j);
                                y->set(i,j,e);
                                k=-1;
                                if(  e != pai );
                               {
                                         if( i != j )
                                               k = i;
                                }
                                parent->set(i,j,k);
                      }
            }
//Robot-Floyd
           for( k=0; k<row;++k)
          {
                     for(i=0;i<row;++i)
                    {
                              for(j=0;j<row;++j)
                             {
                                       if( j !=i )
                                      {
                                                  new_weight = y->get(i,k)+y->get(k,j);
                                                  if(  y->get(i,j) >new_weight )
                                                 {
                                                              y->set(i,j,new_weight);
                                                              parent->set(i,j,k);
                                                  }
                                        }
                              }
                     }
           }
   }