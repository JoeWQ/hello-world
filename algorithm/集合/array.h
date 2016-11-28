/*
  *@aim:动态二维数组的实现,设计的目标是使用方便，执行快速
  *@time:2014-9-22
  *@author:狄建彬
  */
#ifndef   __ARRAY_H__
#define   __ARRAY_H__
//操作动态数组的宏
 class   Array
{
   private:
//数组的首地址,切记，以下的三个数据不要在程序里面自行更改，这里之所以开放它的权限，完全是为了效率
       int        *yr;
//记录数组的行与列
       int        row;
       int        column;
   public:
       Array(int   row,int   column);
       ~Array();
//获取数组的元素
       int          get(int  x,int  y);
       void        set(int  x,int  y,int  c);
//数组与数组之间分享底层的实现
       void    share(Array   *);
  private:
       Array(Array &);
 };
#endif
