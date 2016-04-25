/*
  *@aim:求解线性方程组
  &2016-2-29 19:26:56
  */
#include<stdio.h>
#include<stdlib.h>
#include<math.h>
//定义矩阵的列
#define      __MATRIX_COLUMN__            16
//矩阵的LU分解
    void            matrix_lu_decompose(const   float   (*_matrix)[__MATRIX_COLUMN__],
                                                                                             float  (*_lu)[__MATRIX_COLUMN__] ,const  int   size )
 {
//中心点
            int             _focus;
//行列
            int             _row,_column;
            float          _factor;
            for(_row=0;_row<size;++_row)
                       for(_column=0;_column<size;++_column)
                                          _lu[_row][_column]=_matrix[_row][_column];
            for(_row=0;_row<size;++_row)
           {
//下三角
                           _factor=_lu[_row][_row];
                          for(_focus=_row+1;_focus<size;++_focus)
                                        _lu[_focus][_row]/=_factor;
//Schur补矩阵
                          for(_focus=_row+1;_focus<size;++_focus)
                         {
                                          const      float      _temp=_lu[_focus][_row];
                                          for(_column=_row+1;_column<size;++_column)
                                                         _lu[_focus][_column]-= _lu[_row][_column]*_temp;
                          }
            }
  }
//求解线性方程组
   float            *solve_equation(const float (*_matrix)[__MATRIX_COLUMN__],
                                                             float  (*_lu)[__MATRIX_COLUMN__],const  float   *_value,const   int size)
 {
               float         *_yvalue=new     float[size];
               int            _row,_column;
               float         _factor;
//分解矩阵
               matrix_lu_decompose(_matrix,_lu,size);
//测试代码
               for(_row=0;_row<size;++_row)
              {
                             for(_column=0;_column<size;++_column)
                            {
                                       int          _final=_row>_column?_column:_row;
                                       if(_row>_column)
                                                      _factor=_lu[_column][_column]*_lu[_row][_column];
                                       else
                                                      _factor=_lu[_row][_column];
                                       for(int  k=0;k<_final;++k)
                                                  _factor+=_lu[_row][k]*_lu[k][_column];
                                       printf("%f    ",_factor);
                             }
                             printf("\n");
               }
//先求解下三角矩阵方程
               for(_row=0;_row<size;++_row)
              {
                             _factor=_value[_row];
                             for(_column=0;_column<_row;++_column)
                                              _factor-=_yvalue[_column]*_lu[_row][_column];
                             _yvalue[_row]=_factor;
               }
//求解上三角矩阵方程
               for(_row=size-1;_row>=0;--_row)
              {
                            _factor=_yvalue[_row];
                            for(_column=_row+1;_column<size;++_column)
                                         _factor-=_yvalue[_column]*_lu[_row][_column];
                            _yvalue[_row]=_factor/_lu[_row][_row];
               }
               return    _yvalue;
  }
//
   int        main(int    argc,char    *argv[])
  {
              const       float     _matrix[4][__MATRIX_COLUMN__]={{4,5,3,1},{6,7,1,1},{1,2,8,9},{2,9,10,5}};
              float                      _lu[4][__MATRIX_COLUMN__];
              const       float     _value[__MATRIX_COLUMN__]={7,10,16,25};
              
              const       int        size=4;
              const       float     *_yvalue=solve_equation(_matrix,_lu,_value,size);
              
              for(int    k=0;k<size;++k)
             {
                          float         _temp=0.0f;
                          for(int  j=0;j<size;++j)
                                        _temp=_temp+_matrix[k][j]*_yvalue[j];
                          printf("equation %d result is %f\n",k,_temp);
              }
              return    0;
   }