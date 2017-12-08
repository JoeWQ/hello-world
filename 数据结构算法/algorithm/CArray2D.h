/*
  *@aim:2D动态泛型数组,只能装载基本数据类型和指针类型
  *@priority:动态规划
  *@date:2015-5-20
  */
  #ifndef    __CARRAY2D_H__
  #define   __CARRAY2D_H__
  #include<stdlib.h>
 //@note:函数不会对输入的参数做任何的有效性检查,有所的一切都必须由使用者自己保证
  template<typename    _type_>
    class      CArray2D
   {
private:
           _type_              *y;
           int                     row;
           int                     column;
//在图算法中可能会被用到
     #ifdef       _GRAPH_
           _type_                    invalideValue;
     #endif
private:
          CArray2D(CArray2D &);
public:
         CArray2D(int   row,int    column)
        {
                    this->row=row;
                    this->column=column;
                    y=(_type_   *)malloc(sizeof(_type_)*row*column);
         }
         ~CArray2D()
        {
                   free(y);
         }
//返回/修改数组的内容
        inline      _type_           get(int    _row,int   _column)
       {
                    return      *(y+_row*column+_column);
       }
       inline        void             set(int   _row,int  _column,_type_   c)
      {
                    *(y+_row*column+_column)=c;
      }
//返回数组的行列
       inline         int              rowCount()
      {
                   return      this->row;
       }
       inline          int              columnCount()
      {
                   return       this->column;
       }
       inline          void           fillWith(_type_    c)
      {
                   int          i=0;
                   _type_    *x=y;
                   int         size=row*column;
                   while(i++<size)
                           *(x++)=c;
       }
 #ifdef     _GRAPH_
      inline          void           setInvalideValue(_type_     c)
     {
                   this->invalideValue=c;
      }
     inline         _type_         getInvalideValue()
    {
                   return       this->invalideValue;
     }
#endif
//数组之间的复制
//@request:要求两者之间有相同的行列
     inline           void          copyWith(CArray2D<_type_>   *other)
    {
                   int              size=row*column;
                   _type_        *src=this->y;
                   _type_        *dst=other->y;
                   int             i=0;
                   while(i<size)
                  {
                               src[i]=dst[i];
                               ++i;    
                   }
     }
 };
#endif
   