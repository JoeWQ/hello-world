//管理类,参数化模板
#ifndef    __ARRAY_LIST_H
#define   __ARRAY_LIST_H
// 这个类的特点是，遍历的 次数要远远多于 删除，添加 操作
//知识点，平摊分析
//2013年12月27日
//2014年3月8日
/*
  *修改的地方，每次扩张的规模不再是 原来的2倍
  */
#include<stdlib.h>
#include<string.h>
  template<typename   Key>
  class    ArrayList
  {
  private:
// address of array
		   Key         **base;
//  real size
	       int          _size;
// total size
		   int          total_size;
//清除标志
		   bool        _clean_flag;
       enum
      {
                default_original_size=8
       };
  public:
	       ArrayList()
        {
		               this->base =(Key **)malloc(sizeof(Key *)*default_original_size);
	                 this->_size = 0;
		               this->total_size = default_original_size;
		               this->_clean_flag = 0;
         }
//每次 存储数据的容量
	      ~ArrayList()
      {
      		     if(   _clean_flag )
		          {
			                 int   i=0;
			          	     while(i< _size )
			        	      {
				           	      delete     base[i];
					            	  ++i;
				              }
		          }
	     	      free(base);
      }

//返回索引  d处的 元素值
	Key    *indexOf(int  udx)
 {
	         if(   udx>=0 && udx <_size )
			           return   base[udx];
		       return   NULL;
 }
//插入元素
	void     insert(Key    *y)
 {
	       if(  _size <total_size )
                     base[_size++] = y;
		   else
		   {
//容器的容量 扩充为原来 的1.618 倍
			         total_size =(int)(1.618*total_size);
					    Key     **new_base=(Key   **)malloc(sizeof(Key *)*total_size);
					    memcpy(new_base,base,_size*sizeof(Key *));
					    free(base);
					    base = new_base;
					    base[_size++]= y;
		   }
 }
//删除 索引 d 处的元素
	Key     *removeIndexOf(int    udx)
 {
	       int      i;
		     Key    *y=NULL;
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
						                   Key    **new_base=(Key **)malloc(sizeof(Key *)*m);
								               memcpy(new_base,base,_size*sizeof(Key *) );
								               free(base);
								               base = new_base;
				        	}
		    }
		   return   y;
  }
//删除元素
	void     remove(Key   *obj)
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
                       Key    *newBase=(Key **)malloc(sizeof(Key *)*ysize);
                       if(this->_size>0)
                           memset(newBase,base,this->_size);
                       this->total_size=ysize;
            }
 }
//设置 删除标志，0 表示忽略 存入 模板中的 指针 值，1表示在西沟时，删除掉容器中的指针对象
	void     setClearFlag(bool   b)
 {
	     this->_clean_flag = b;
 }
//返回 容器 当前的容量
	    int       getSize()
    {
        return this->_size;
     }
//清除 容器中的所有元素
	   void     clear()
    {
	        	if(   _clean_flag )
	      	{
			             	int   i=0;
			            	while(i< _size )
			           	{
				                		delete     base[i];
				                		++i;
			           	}
		      }
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
