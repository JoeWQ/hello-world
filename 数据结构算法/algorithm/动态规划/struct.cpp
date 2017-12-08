/*
  *@aim:对结构体的成员进行排序,所期望的结果是重新排列成员的顺序以使得的成员的占据的总的空间最小
  *@date:2015-11-7 10:49:34
  *@author:狄建彬
  *@idea:动态规划
  */
  #include<stdio.h>
  #include"CArray2D.h"
//结构体建模
  struct         Member
 {
//结构体成员的尺寸
             int                      width;
//成员的对齐粒度
             int                      alignWidth;
//结构体成员的名字
//             std::string          name;
  };
//结构体的成员
//成员的数目,注意成员的有效索引从1开始
  void         struct_member_total_size(struct    Member     *_mem,int     size)
 {
//记录成员i,j所占据的空间
             int                                   i,j,k;
             int                                   _offset;
             int                                   _width;
             int                                   _index;
             struct             Member   mem;
//             const             int            *y=new    int[size+2];
//初始化,将最简单明了的情况写出来
//             y[0]=0;
//             y[1]=_mem[1].width;
             _mem->width=0;
             _mem->alignWidth=4;
//从处理成员j开始,成员0不用考虑,因为前面已经没有成员了
             for( j=2 ; j<size; ++j )
            {
//成员_mem[d]尝试着从索引i开始依次进行尝试插入并比较所产生的代价
                          _width=0x7FFFFFFF;
                          _index=0;
                          for(i=1;i<=j  ;++i  )//
                         {
                                         _offset=0;
                                         for( k=0;k<i;++k)
                                       {
                                                         if(_offset%_mem[k].alignWidth)
                                                                    _offset+=_mem[k].alignWidth-_offset%_mem[k].alignWidth;
                                                         _offset+=_mem[k].width;
                                        }
                                        if(_offset%_mem[j].alignWidth)
                                                         _offset+=_mem[j].alignWidth-_offset%_mem[j].alignWidth;
                                        _offset+=_mem[j].width;
                                        for(      ;k<j;++k)
                                       {
                                                          if(_offset%_mem[k].alignWidth)
                                                                     _offset+=_mem[k].alignWidth-_offset%_mem[k].alignWidth;
                                                          _offset+=_mem[k].width;
                                        }
                                        if(_offset<_width)
                                       {
                                                       _width=_offset;
                                                       _index=i;
                                        }
                          }
//移动数据,并更新局部的成员数据的偏移量
                         if(_index  !=  j )
                        {
                                      mem=_mem[  j  ];
                                      for(  k=j;k>_index;--k  )
                                                   _mem[k]=_mem[k-1];
                                      _mem[ _index ]=mem;
                         }
                         printf("_index:%d, _offset:%d\n",_index,_width);
             }
  }
//***********************************************************************
      int        main(int    argc,char    *argv[])
     {
//第0个成员为一个哑元
                     struct           Member             _mem[13]={ {0,4},     {1,1},{4,4},{1,1},{8,8},
                                                                                                 {4,4},{1,1},{8,8},{2,2},
                                                                                                 {1,1},{4,4},{2,2},{4,4}
                                                                                          };
                    const           int                        _size=13;
                    
                    struct_member_total_size(_mem,_size);
                    return    0;
      }