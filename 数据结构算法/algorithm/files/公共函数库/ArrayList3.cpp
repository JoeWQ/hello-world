//
/*//2013年12月27日
  *ArrayList<Key>
  *修正版3
  *2014年3月8日
  */
#include"ArrayList.h"
#include<stdlib.h>
template<typename  Key>
ArrayList<Key>::ArrayList()
{
	      this->ssize = 0;
		  this->total_size = 4;
		  this->base =(Key **)malloc(sizeof(Key *)*4);
		  this->flag = 0;
//		  memset(base,0,sizeof(Key *)*4);
}
//另一种扩张
ArrayList<Key>::ArrayList( int  capacity )
{
        if(  capacity <4  )
                capacity=4;
        this->ssize = 0;
        this->total_size = capacity;
        this->base = (Key **)malloc(sizeof(Key *) * capacity);
        this->flag=0;
}
//
template<typename  Key>
ArrayList<Key>::~ArrayList()
{
		 if(   flag )
		 {
			     int   i=0;
				 while(i< ssize )
				 {
					      delete     base[i];
						  ++i;
				 }
		 }
		 free(base);
}
//
template<typename  Key>
int  ArrayList<Key>::size()
{
	    return   ssize;
}
//
template<typename Key>
void  ArrayList<Key>::clear()
{
		if(   flag )
		{
				int   i=0;
				while(i< ssize )
				{
						delete     base[i];
						++i;
				}
		}
//只有在 原来的数组容量超过一定的规模的时候，才会真正释放内存
    if(  total_size >4   )
   {
		        free(base);
		        base = (Key **)malloc(sizeof(Key *)*4);
		        total_size = 4;
	          ssize = 0;
    }
    else
            ssize = 0;
}
//返回索引 udx处的 元素
template<typename   Key>
Key*      ArrayList<Key>::indexOf(int     udx)
{
	      if(   udx>=0 && udx <ssize )
			  return   base[udx];
		  return   NULL;
}
//插入 元素，这个函数 要麻烦一些
template<typename   Key>
void      ArrayList<Key>::insert(Key    *rtf)
{
//	       int       i;
	       if(  ssize <total_size )
                     base[ssize++] = rtf;
		   else
		   {
//容器的容量 扩充为原来 的1.5 倍
			         total_size += total_size>>1;
					 Key     **new_base=(Key   **)malloc(sizeof(Key *)*total_size);
//					 memset(new_base,0,total_size*sizeof(Key *));
					 memcpy(new_base,base,ssize*sizeof(Key *));
					 free(base);
					 base = new_base;
					 base[ssize++]= rtf;
		   }
}
//删除  索引处 udx 处的节点
template<typename   Key>
Key*      ArrayList<Key>::removeIndexOf(int   udx)
{
	       int      i;
		   Key    *rtf=NULL;
	       if( udx>=0 && udx <ssize)
		   {
					rtf = base[udx];
					for( i=udx; i< ssize - 1; ++i   )
						  base[i] = base[i+1];
					--ssize;
//容器 容量 调整
					if(  ssize <( total_size >>2)   && total_size > 4 )
					{
						        total_size >>=1;
						        Key    **new_base=(Key **)malloc(sizeof(Key *)*total_size );
								memcpy(new_base,base,ssize*sizeof(Key *) );
								free(base);
								base = new_base;
					}
		   }
		   return   rtf;
}
//
template<typename   Key>
void    ArrayList<Key>::remove(Key  *obj)
{
	     int    i=0;
		 for( u=0;i<ssize;++i )
		 {
			       if( base[i] == obj )
				   {
					        removeIndexOf(i);
							break;
				   }
		 }
}
template<typename   Key>
void    ArrayList<Key>::setClearFlag(bool  b)
{
	     flag = b;
}
