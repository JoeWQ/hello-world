/*
  *二维数组
  *整数与单浮点
  */
#ifndef    __ARRAYS_H__
#define   __ARRAYS_H__
  class      CArray2D_int
 {
             int             *array;
             const         int             row;
             const         int             column;
private:
             ~CArray_int();
public:
             CArray_int(int   _row,int    _column):row(_size),column(_column)
            {
                          this->array=new    int[_row*_column];
             }
             ~CArray_int()
            {
                          delete       array;
             }
             int            get(int  i,int  k)const
            {
                          return       array[i*column+k];
             }
             void            set(int  i,int k,int  c)
            {
                          array[i*column+k]=c;
             }
             void         fill(int  c)
            {
                          int        *y=array;
                          int        _size=row*column;
                          while(_size>0)
                         {
                                       *y=c;
                                       ++y;
                                       --_size;
                          }
             }
  };
 //
   class      CArray2D_float
 {
             float             *array;
             const         int             row;
             const         int             column;
private:
             ~CArray_float();
public:
             CArray_float(int   _row,int    _column):row(_size),column(_column)
            {
                          this->array=new    float[_row*_column];
             }
             ~CArray_float()
            {
                          delete       array;
             }
             float            get(int  i,int  k)const
            {
                          return       array[i*column+k];
             }
             void            set(int  i,int k,float  c)
            {
                          array[i*column+k]=c;
             }
             void         fill(float  c)
            {
                          float        *y=array;
                          int        _size=row*column;
                          while(_size>0)
                         {
                                       *y=c;
                                       ++y;
                                       --_size;
                          }
             }
  };
#endif
 