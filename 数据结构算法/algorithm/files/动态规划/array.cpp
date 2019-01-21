/*
  *@aim:动态数组的实现C++代码
  *@time:2014-9-22 
  *author:狄建彬
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
//快速存取数组元素的函数
   int      Array::get(int  x,int  y)
 {
         return  this->yr[this->column*x+y];
  }
 void     Array::set(int   x,int   y,int   c)
 {
          this->yr[this->column*x+y]=c;
  }
//数组间共享一个底层实现,此函数暂不开放，因为它会将动态数组的使用高度复杂化，不符合作者原来的初衷
  void     Array::share(Array   *a)
 {

  }
