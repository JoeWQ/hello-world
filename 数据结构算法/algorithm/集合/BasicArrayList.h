/*
  *@date：2014-8-9
  *@author:狄建彬
  *@aim:  基本数据类型的泛型
  *@BasicArrayList
  */
//
#ifndef   __BASIC_ARRAY_LIST_H_
#define   __BASIC_ARRAY_LIST_H_
#include<stdlib.h>
#include<string.h>
  template<typename   Key>
  class    BasicArrayList
 {
 public:
// address of array
		   Key         *base;
//  real size
	       int          _size;
// total size
		   int          total_size;
//扩大了n次
       int          spread_times;
//缩小了n次
        int         shrink_times;
       enum
      {
                default_original_size=8
       };
  public:
	       BasicArrayList()
        {
		               this->base =(Key *)malloc(sizeof(Key )*default_original_size);
	                 this->_size = 0;
		               this->total_size = default_original_size;
                   this->spread_times=0;
                   this->shrink_times=0;
         }
//每次 存储数据的容量
	      ~BasicArrayList()
       {
	     	          free(base);
       }

//返回索引  d处的 元素值
	Key    indexOf(int  udx)
 {
	        if(   udx>=0 && udx <_size )
			          return   base[udx];
		      return   0;
 }
//插入元素
	void     insert(Key    y)
 {
	       if(  _size <total_size )
                     base[_size++] = y;
		   else
		   {
//容器的容量 扩充为原来 的1.618 倍
			         total_size =(int)(1.618*total_size);
					    Key     *new_base=(Key   *)malloc(sizeof(Key )*total_size);
					    memcpy(new_base,base,_size*sizeof(Key ));
					    free(base);
					    base = new_base;
					    base[_size++]= y;
              ++this->spread_times;
		   }
 }
//删除 索引 d 处的元素
	Key     removeIndexOf(int    udx)
 {
	       int      i;
		     Key    y=0;
	       if( udx>=0 && udx <_size)
		   {
				          	y= base[udx];
				          	for( i=udx; i< _size - 1; ++i   )
				              		  base[i] = base[i+1];
				          	--_size;
//容器 容量 调整
//所见的容量为原来的 total_size 的1/3
                  int      m=(int)(total_size*0.382);
				         	if(  _size <m   && total_size > default_original_size )
			       		{
						                   total_size =m;
						                   Key    *new_base=(Key *)malloc(sizeof(Key )*m);
								               memcpy(new_base,base,_size*sizeof(Key ) );
								               free(base);
								               base = new_base;
                               ++this->shrink_times;
				       	}
		   }
		   return   y;
  }
//删除元素
	void     remove(Key   obj)
 {
	        int    i=0;
		     for( i=0;i<_size;++i )
		    {
			          if( base[i] == obj )
				      {
					            removeIndexOf(i);
							        break;
				      }
		   }
 }
//批量删除,删除范围[udx_from,udx_to)
 void      remove(int    udx_from,int   udx_to)
{
             if(udx_to<=udx_from)
                     return;
             if(udx_from<0)
                    udx_from=0;
             if(udx_to>this->_size)
                    udx_to=this->_size;
//修正
            while(udx_to<_size)
           {
                     this->base[udx_from]=this->base[udx_to];
                     ++udx_from;
                     ++udx_to;
            }
//调整base的大小
            this->_size-=(udx_from-udx_from);
//如果调整后的容量在total_size 的0.382以内，冲调整base
            int    ysize=(int)(this->total_size*0.382);
            if(this->_size<ysize)
           {
                       if( ysize<default_original_size)
                               ysize=default_original_size;
                       Key    *newBase=(Key *)malloc(sizeof(Key )*ysize);
                       if(this->_size>0)
                           memset(newBase,base,this->_size);
                       this->total_size=ysize;
            }
   }
//返回 容器 当前的容量
	    int       getSize()
    {
        return this->_size;
    }
//清除 容器中的所有元素
  	void     clear()
   {
//只有在 原来的数组容量超过一定的规模的时候，才会真正释放内存
             if(  total_size >default_original_size   )
            {
		               free(base);
		               base = (Key **)malloc(sizeof(Key *)*default_original_size);
		               total_size = default_original_size;
	                 _size = 0;
             }
             else
                   _size = 0;
     }
 };
#endif
