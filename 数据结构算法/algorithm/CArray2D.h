/*
  *@aim:2D��̬��������,ֻ��װ�ػ����������ͺ�ָ������
  *@priority:��̬�滮
  *@date:2015-5-20
  */
  #ifndef    __CARRAY2D_H__
  #define   __CARRAY2D_H__
  #include<stdlib.h>
 //@note:�������������Ĳ������κε���Ч�Լ��,������һ�ж�������ʹ�����Լ���֤
  template<typename    _type_>
    class      CArray2D
   {
private:
           _type_              *y;
           int                     row;
           int                     column;
//��ͼ�㷨�п��ܻᱻ�õ�
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
//����/�޸����������
        inline      _type_           get(int    _row,int   _column)
       {
                    return      *(y+_row*column+_column);
       }
       inline        void             set(int   _row,int  _column,_type_   c)
      {
                    *(y+_row*column+_column)=c;
      }
//�������������
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
//����֮��ĸ���
//@request:Ҫ������֮������ͬ������
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
   