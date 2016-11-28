/*
  *@aim:��С͹��������ʵ��
  *@date:2015-5-12
  */
   #include"rotate_jam.h"
   #include<stdio.h>
   #include<stdlib.h>
   #include<math.h>
   #include<assert.h>
 //  #include<vector>
   #define         _RADIANS_       57.29577951308233f
   RotateJam::RotateJam(Point      *points,int    size)
   {
               assert(size>=3);
               this->m_points=(Point   *)malloc(sizeof(Point)*size);
               this->m_angles=(float    *)malloc(sizeof(float)*size);
               this->m_size=size; 
               for(int   idx=0;idx<size;++idx)
                       m_points[idx]=points[idx];
   }
   RotateJam::~RotateJam()
   {
              free(m_points);
              free(m_angles);
              this->m_size=0;
   }
   //���Ѿ������õĵ�Ԥ����
    void      RotateJam::preprocess()
  {
//����ÿ������ļ�����,����ѡ������С��������Ϊԭ��
               int            i,size=m_size-1,j,k;
               Point        *p=m_points,*q=m_points;
               Point        origin;
               float          angle,x,y;
//���ҵ�һ��������Сy����Ķ��㣬��������������y������ȣ�ѡ��x������С��
               for( i=1;i<this->m_size;++i,++p)
              {
                            if(p->y<q->y)
                                    q=p;
                            else if(p->y==q->y && p->x<q->x)
                                     q=p;
               }
//��������Ľṹ
                if(  q != (m_points+size) )
                {
                             origin=*q;
                            *q=m_points[size];
                              m_points[size]=origin;
                              q=m_points+size;
                }
                p=m_points;
               for(i=0;i< size;++i,++p)
              {
                              x=p->x-q->x;
                              y=p->y-q->y;
                               angle=asin( y/sqrt(x*x+y*y ))*_RADIANS_;
//����ڵڶ�����
                               if(    x<0 )
                                          angle=180.0f-angle; 
                               m_angles[i]=angle;
              }
 //����m_angle[i]��������
              for(i=0;i<size;++i)
             {
                            k=i;
                            for(j=i+1;j<size;++j)
                           {
                                          if( m_angles[k]>m_angles[j] )
                                                       k=j;
                            }
                            if( k   != i )
                           {
                                          angle=m_angles[k];
                                          m_angles[k]=m_angles[i];
                                          m_angles[i]=angle;
                                          Point       temp=m_points[k];
                                          m_points[k]=m_points[i];
                                          m_points[i]=temp;
                            }
              }
              m_results.reserve(3);
              m_results.push_back(m_points+size);
              m_results.push_back(m_points);
              m_results.push_back(m_points+1);
    }
 //������յķ���
    void                RotateJam::resolve()
   {
  //m_point[m_size-1]�ǵ�һ����С�Ķ���
                  Point        origin,spread;
 //�������ڵ�������ʹ�ò�����ж������ڿռ��еķ���
                  Point        *p=&origin;
                  Point        *q=&spread;
                  float         cross;
                  int            idx;                  
//
                  for(idx=2;idx<m_size;++idx)
                 {
//��������֮��Ĳ��
                                do
                                {
                                                p->x=m_results[m_results.size()-1]->x-m_results[m_results.size()-2]->x;
                                                p->y=m_results[m_results.size()-1]->y-m_results[m_results.size()-2]->y;
                                               q->x=m_points[idx].x-m_results[m_results.size()-1]->x;
                                               q->y=m_points[idx].y-m_results[m_results.size()-1]->y;
                                               cross=p->x*q->y-p->y*q->x;
                                               if(cross<0)
                                                           m_results.pop_back();
                                }while(cross<0);
                                m_results.push_back(m_points+idx);
                  }
    }
    void                RotateJam::result(Point      *point,int      *size)
   {
                  int                 idx;
                  for(idx=0;idx<m_results.size();++idx)
                 {
                                 point[idx]=*m_results[idx];
                 }
                 *size=m_results.size();
                 
    }
    //
    int              main(int     argc,char     *argv[])
   {
                 Point                 points[8]={
                                                                  {1.0f,0.0f},{6.0f,1.0f},
                                                                  {9.0f,3.0f},{8.0f,7.0f},
                                                                  {5.0f,4.1f},{4.0f,7.0f},
                                                                  {3.0f,8.0f},{0.0f,9.0f}
                                                              };
                  int                    size=8;
                  RotateJam              jam(points,size);
                  Point               result[8];
                  int                   result_size;
                  
                  jam.preprocess();
                  jam.resolve();
                  jam.result(result,&result_size);
                  
                  for(int   i=0;i<result_size;++i)
                 { 
                                 printf("%d--------------------->(%f,%f)\n",i,result[i].x,result[i].y);
                 }
                  return    0;
    }