/*
  *@aim:���㼸��
  *@date:2015-6-24 10:27:59
  */
 #ifndef   _GEOMETRY_H__
 #define  _GEOMETRY_H__
 //1:���ݽṹ����
 //������
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
 //��άֱ��
 struct            CLine2
{
           CPoint             a;//��ʼ��
           CPoint             b;//��ֹ��
 };
//Բ
  struct          CCycle2
 {
            CPoint         center;//��������
            float            radius;//�뾶
  };
//����,ע�������µĺ����У�������Բ�������Ч�������
//����֮��ĵ��
  float              dot2(CPoint     *p,CPoint    *q);
//���������Ĳ��
  float               cross2(CPoint       *s,CPoint          *t);
 //�ж�һ�����Ƿ���һ���߶���
  bool               isPointInLine2(CLine2         *line,CPoint   *p);
 //����ֱ�ߵĽ���,���û�н���ͷ���false
  bool                lineCrossAt2(CLine2     *line1,CLine2      *line2,CPoint     *p);
 //******************************************************************************
 //��͹����ε�ֱ��,����Զ�����ʼ��������ֹ������д��from,to��
 //@request:size>3
   float              convexHullDiameter(CPoint        *convex,int   size,int   *from,int  *to);
//�ж�����һ���Ƿ������͹�������
    bool              isPointInPolygon(CPoint        *convex,int    size,CPoint   *p);
 #endif
 