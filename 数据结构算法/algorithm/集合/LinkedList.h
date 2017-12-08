/*
  *双端队列,2014年8月9日
  *@version3 ,增加功能，缓存管理,对缓存的更精细的控制,直接将泛型方法合并到.h文件中
  *@使用的对象：结构体或者对象
  */
#ifndef    __LINKED_LIST_H
#define   __LINKED_LIST_H
#include<stdlib.h>
/*
  *
  */
template<typename   Key>
class      LinkedList
{
	     struct     _Node
			{
				     Key                      *stf;
					 struct    _Node       *prev;
					 struct    _Node       *next;
			};
			typedef    struct    _Node     Node;
private:
	     Node           *head;          //头节点
	     Node           *tail;            //尾节点
	     Node           *current;       //当前访问的节点
       Node           *cache;         //缓存，为了加速 内存的分配
       int              _cache_size;  //当前缓存内存块的大小
	     int              size;             //当前节点的数目
	     bool            can_clean;   //如果设置了这个标志，则队列自动清除所有的 对象
public:
	   LinkedList()
    {
              this->head=NULL;
              this->tail=NULL;
              this->current=NULL;
              this->cache=NULL;
              this->_cache_size=0;
              this->size=0;
              this->can_clean=false;
     }
	   ~LinkedList()
    {
              this->clean();
     }
// 将一个节点 添加到 队列中
  void         addFirst(Key     *v)
 {
	       Node    *p = get_memory_from_cache();
//先在缓存中查找 是否有 可用的内存
		   p->stf = v;
		   ++size;
		   if(  head )
					  head->prev = p;
		   else
			          tail = p;
		   p->next = head;
		   p->prev = NULL;
		   head = p;
 }
//删除头结点,如果已经没有节点，则返回空
	Key*         removeFirst()
 {
	       Node    *p=head;
        Key        *y=NULL;
		   if(  head )
		   {
			       --size;
				   head = head->next;
				   if(  tail == p)
					   tail = NULL;
				   else
					   head->prev =NULL;
		   
				   y = p->stf;
//将删除掉的节点存入缓存中，这样可以加快内存的分配
           push_memory_to_cache( p );
		   }
		   return  y;
  }
//在队列的末尾添加一个节点
	void          addLast(Key    *v)
{
 	    Node    *p=get_memory_from_cache();
      
			p->stf = v;
			if( head )
				      tail->next = p;
			else
				      head = p;
            p->prev = tail;
			tail = p;
			p->next = NULL;
			++size;
 }
//删除队列的尾节点,如果已经没有节点，则返回空
	 Key         removeLast()
  {
	          Node    *p = tail;
            Key         *y=NULL;
		    	  if( tail )
		    	 {					
				         --size;
				         tail = tail->prev;
				         if(  p == head )
                        head = NULL;
				    		else
							          tail->next = NULL;
			      
						 y=p->stf;
//将删除掉的节点 存入缓存中，以待下次使用
             push_memory_to_cache( p );
			     }
		  	 return  y;
   }
//队列遍历,当到达末尾时，返回空
	 Key*          next()
  {
             Key        *y=NULL;
             if( ! current )
				     return y;
			     y= current->stf;
			     current = current->next;
			     return  y;
   }
//将 当前遍历的节点 重置，这样它就指向第一个节点
	 void         rewind()
  {
	       current = head;
   }
//
	   void          setCleanupFlag(bool   _clean)
    {
             can_clean = _clean;
     }
//将队列的内容清空
	void          clean()
 {
	    Node    *p=head,*t;
		  while(  p )
		  { 
			       t = p;
				   p = p->next;
				   if(  can_clean )
					       delete   t->stf;
				   delete   t;
		  }
//调整当前缓存的大小
      int      _size=_cache_size-3;
      if( _size>0 )
     {
                 _cache_size=3;
		             p=cache;
		             while(  _size )
		            {
			                 	 t=p;
				                 p=p->next;
				                 free( t );
                          --_size;
		             }
                 cache=p;
      }
 //
      this->head=NULL;
      this->tail=NULL;
      this->size=0;
      this->current=NULL;
   }
//获取节点的 数目
	   int            getSize()
    {
           return   size;
    }
//私有方法
private:
//获取内存
  Node    *get_memory_from_cache()
 {
           Node   *node=NULL;
           if( cache   )
          {
                   --_cache_size;
                   node = cache;
                   cache=cache->next;
          }
          else
                   node=(Node  *)malloc(sizeof(Node) );
          return   node;
  } 
//将内存块添加到缓存，或者释放掉
//缓存的容量做多不会超过 链表总节点数目的 1/4 +3
  void     push_memory_to_cache( Node *node)
 {
          node->next=NULL;
          if(  _cache_size <=(size>>2)+3    )
         {
                   ++_cache_size;
                   node->next=cache;
                   cache=node;
          }
         else
                  free( node); 
   }
};
#endif
