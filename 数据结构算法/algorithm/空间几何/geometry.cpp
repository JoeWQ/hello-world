//二维几何向量之间的运算
#include"geometry.h"
//#include<vector>
//点乘
  float            dot2(CPoint    *p,CPoint   *q)
 {
              return            p->x*q->x+p->y*q->y;
  }
//叉乘,计算s*t
  float            cross2(CPoint        *s,CPoint         *t)
 {
          return         s->x*t->y-s*y*t->x;
  }
 //判断一个点是否在一个线段上
   bool           isPointInLine2(CLine2     *line,CPoint    *p)
  {
           float          x=p->x-line->a.x;
           float          y=p->y-line->a.y;
           float          x1=line->b.x-line->a.x;
           float          y1=line->b.y-line->a.y;
           return      x*y1-y*x1==0 && x*(p->x-line->b.x)+(p->y-line->b.y)*y<=0;
   }
 //求两直线的交点
 //line1 a,b   line2 cd
   bool          lineCrossAt2(CLine2     *line1,CLine2   *line2,CPoint    *p)
  {
            float        x=line1->b.x-line1->a.x;
            float        y=line1->b.y-line1->a.y;
//求交叉面积abc
            float        s1=x*(line2->a.y-line1->a.y)-y*(line2->a.x-line1->a.x);
//交叉面积abd
            float        s2=x*(line2->b.y-line1->a.y)-y*(line2->b.x-line1->a.x);
//此时两条直线平行
            if(s1 == s2 )
                   return   false;
            p->x=(s1*line2->b.x-s2*line2->a.x)/(s1-s2);
            p->y=(s1*line2->b.y-s2*line2->a.y)/(s1-s2);
            return  true
   }
//求凸多边形直径
    float               convexHullDiameter(CPoint    *convex,int     size,int   *from,int   *to)
   {
             float                             diameter=0;
//             std::vector<int>          rotate;
             int                                 i,j;
             CPoint                           *p,*q,*r,*w;
             float                             value;//中间表达式的结果
             
//             rotate.reserve(size);
//i便利所有的有效索引？,j记录当前在那个索引点所得到的三角形i,i+1,j的面积最大
             for(i=0,j=1;i<size;++i)
            {
                         p=convex+i,q=convex+(i+1)%size;
                         r=convex+j,w=convex+(j+1)%size;
//循环条件,有向面积单调递增
                          while(  (q->x-p->x)*(r->y-p->y)-(q->y-p->y)*(r->x-p->x)>=
                                            (q->x-p->x)*(w->y-q->y)-(w->x-q->x)*(q->y-p->y)  )
                                    j=(j+1)%size;
//比较当前得到的直径
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
 //判断任意一点是否落在凸多边形内
   bool                isPointInPolygon(CPoint     *convex,int    size,CPoint    *p)
  {
             int                  left,right,mid;
             CPoint           center;
             left=0;
             right=size;
//选择中心点作为参考坐标
             center.x=(convex[left].x+convex[right/3].x +convex[right*2/3].x)/3.0f;
             center.y=(convex[left].y+convex[right/3].y+convex[right*2/3].y)/3.0f;
//
             while( left +1 <right )
            {
                         mid=(left+right)>>1;
//计算向量center-->p在center-->mid的哪个方向
//如果在其逆时针
                         if( (convex[mid].x-center.x)*(p->y-center.y)-(p->x-center.x)*(convex[mid].y-center.y)>0  )
                                      left=mid+1;
                         else
                                      right=mid-1;
             }
//现在可以将点p锁定在left,right之间,此时可以检测点p在内还是外      
             right%=size;//为了防止极端的情况出现,取模
             return         (convex[left].x-p->x)*(convex[right].y-p->y)-(convex[right].x-p->x)*(convex[left].y-p->y)>=0;
   }