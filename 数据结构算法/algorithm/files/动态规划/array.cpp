/*
  *@aim:��̬�����ʵ��C++����
  *@time:2014-9-22 
  *author:�ҽ���
  */
#include"array.h"
#include<stdlib.h>
   Array::Array(int   row,int   column)
  {
         this->yr=(int   *)malloc(sizeof(int)*row*column);
         this->row=row;
         this->column=column;
   }
//
   Array::~Array(  )
  {
          free(yr);
  }
//���ٴ�ȡ����Ԫ�صĺ���
   int      Array::get(int  x,int  y)
 {
         return  this->yr[this->column*x+y];
  }
 void     Array::set(int   x,int   y,int   c)
 {
          this->yr[this->column*x+y]=c;
  }
//����乲��һ���ײ�ʵ��,�˺����ݲ����ţ���Ϊ���Ὣ��̬�����ʹ�ø߶ȸ��ӻ�������������ԭ���ĳ���
  void     Array::share(Array   *a)
 {

  }
