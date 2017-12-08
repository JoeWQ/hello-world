/*
  *@aim:计算几何
  *@date:2015-6-24 10:27:59
  */
 #ifndef   _GEOMETRY_H__
 #define  _GEOMETRY_H__
 //1:数据结构部分
 //点坐标
  struct       CPoint
 {
            float          x,y;
  };
  struct      CVector2
 {
            float         x,y;
  };
  struct      CVector3
 {
            float         x,y,z;
  };
  struct      CVector4
 {
            float         x,y,z,w;
  };
 //二维直线
 struct            CLine2
{
           CPoint             a;//起始点
           CPoint             b;//终止点
 };
//圆
  struct          CCycle2
 {
            CPoint         center;//中心坐标
            float            radius;//半径
  };
//函数,注意在以下的函数中，都不会对参数的有效性做检查
//向量之间的点乘
  float              dot2(CPoint     *p,CPoint    *q);
//求两向量的叉乘
  float               cross2(CPoint       *s,CPoint          *t);
 //判断一个点是否在一个线段上
  bool               isPointInLine2(CLine2         *line,CPoint   *p);
 //求两直线的交点,如果没有交点就返回false
  bool                lineCrossAt2(CLine2     *line1,CLine2      *line2,CPoint     *p);
 //******************************************************************************
 //求凸多边形的直径,其最远点的起始索引与终止索引被写入from,to中
 //@request:size>3
   float              convexHullDiameter(CPoint        *convex,int   size,int   *from,int  *to);
//判断任意一点是否包含在凸多边形内
    bool              isPointInPolygon(CPoint        *convex,int    size,CPoint   *p);
 #endif
 