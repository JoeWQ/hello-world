//��ά��������֮�������
#include"geometry.h"
//#include<vector>
//���
  float            dot2(CPoint    *p,CPoint   *q)
 {
              return            p->x*q->x+p->y*q->y;
  }
//���,����s*t
  float            cross2(CPoint        *s,CPoint         *t)
 {
          return         s->x*t->y-s*y*t->x;
  }
 //�ж�һ�����Ƿ���һ���߶���
   bool           isPointInLine2(CLine2     *line,CPoint    *p)
  {
           float          x=p->x-line->a.x;
           float          y=p->y-line->a.y;
           float          x1=line->b.x-line->a.x;
           float          y1=line->b.y-line->a.y;
           return      x*y1-y*x1==0 && x*(p->x-line->b.x)+(p->y-line->b.y)*y<=0;
   }
 //����ֱ�ߵĽ���
 //line1 a,b   line2 cd
   bool          lineCrossAt2(CLine2     *line1,CLine2   *line2,CPoint    *p)
  {
            float        x=line1->b.x-line1->a.x;
            float        y=line1->b.y-line1->a.y;
//�󽻲����abc
            float        s1=x*(line2->a.y-line1->a.y)-y*(line2->a.x-line1->a.x);
//�������abd
            float        s2=x*(line2->b.y-line1->a.y)-y*(line2->b.x-line1->a.x);
//��ʱ����ֱ��ƽ��
            if(s1 == s2 )
                   return   false;
            p->x=(s1*line2->b.x-s2*line2->a.x)/(s1-s2);
            p->y=(s1*line2->b.y-s2*line2->a.y)/(s1-s2);
            return  true
   }
//��͹�����ֱ��
    float               convexHullDiameter(CPoint    *convex,int     size,int   *from,int   *to)
   {
             float                             diameter=0;
//             std::vector<int>          rotate;
             int                                 i,j;
             CPoint                           *p,*q,*r,*w;
             float                             value;//�м���ʽ�Ľ��
             
//             rotate.reserve(size);
//i�������е���Ч������,j��¼��ǰ���Ǹ����������õ���������i,i+1,j��������
             for(i=0,j=1;i<size;++i)
            {
                         p=convex+i,q=convex+(i+1)%size;
                         r=convex+j,w=convex+(j+1)%size;
//ѭ������,���������������
                          while(  (q->x-p->x)*(r->y-p->y)-(q->y-p->y)*(r->x-p->x)>=
                                            (q->x-p->x)*(w->y-q->y)-(w->x-q->x)*(q->y-p->y)  )
                                    j=(j+1)%size;
//�Ƚϵ�ǰ�õ���ֱ��
                           value=(r->x-p->x)*(r->x-p->x)+(r->y-p->y)*(r->y-p->y);
                           if( value >diameter)
                          {
                                         diameter=value;
                                         *from=i;
                                         *to=j;
                           }
                           value=(w->x-q->x)*(w->x-q->x)+(w->y-q->y)*(w->y-q->y);
                           if(  value>diameter)
                          {
                                         diameter=value;
                                         *from=i;
                                         *to=j;
                           }
             }
             return       sqrt(diameter);
    }
 //�ж�����һ���Ƿ�����͹�������
   bool                isPointInPolygon(CPoint     *convex,int    size,CPoint    *p)
  {
             int                  left,right,mid;
             CPoint           center;
             left=0;
             right=size;
//ѡ�����ĵ���Ϊ�ο�����
             center.x=(convex[left].x+convex[right/3].x +convex[right*2/3].x)/3.0f;
             center.y=(convex[left].y+convex[right/3].y+convex[right*2/3].y)/3.0f;
//
             while( left +1 <right )
            {
                         mid=(left+right)>>1;
//��������center-->p��center-->mid���ĸ�����
//���������ʱ��
                         if( (convex[mid].x-center.x)*(p->y-center.y)-(p->x-center.x)*(convex[mid].y-center.y)>0  )
                                      left=mid+1;
                         else
                                      right=mid-1;
             }
//���ڿ��Խ���p������left,right֮��,��ʱ���Լ���p���ڻ�����      
             right%=size;//Ϊ�˷�ֹ���˵��������,ȡģ
             return         (convex[left].x-p->x)*(convex[right].y-p->y)-(convex[right].x-p->x)*(convex[left].y-p->y)>=0;
   }