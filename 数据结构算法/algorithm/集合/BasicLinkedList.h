/*
  *@date:2014-8-9
  *@author 狄建彬
  *@goal: 基本数据类型使用的集合
  */
#ifndef   __BASIC_LINKED_LIST_H__
#define  __BASIC_LINKED_LIST_H__
  template<typename  Key>
  class      BasicLinkedList<Key>
 {
     struct     _Node
			{
				   Key                        stf;
					 struct    _Node       *prev;
					 struct    _Node       *next;
			};
			typedef    struct    _Node     Node;
private:
	   int             size;         //当前节点的数目
	   Node         *head;      //头节点
	   Node         *tail;        //尾节点
	   Node         *current;   //当前访问的节点
//	   Node         *indx;       //当前遍历的节点 的索引，注意，这个队列并不支持冰法访问
       Node         *cache;     //缓存，为了加速 内存的分配
       int            _cache_size;//当前缓存内存块的大小
public:
	   LinkedList()
    {
              this->size=0;
              this->head=NULL;
              this->tail=NULL;
              this->current=NULL;
              this->cache=NULL;
              this->_cache_size=0;
              this->can_clean=false;
     }
	   ~LinkedList()
    {
              this->clean();
     }
// 将一个节点 添加到 队列中
  void         addFirst(Key     v)
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
	Key         removeFirst()
 {
	      Node    *p=head;
        Key      y=-1;
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
	void          addLast(Key    v)
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
            Key         y=0;
		    	  if( tail )
		    	 {					
				         --size;
				         tail = tail->prev;
				         if(  p == head )
                        head = NULL;
				    		else
							          tail->next = NULL;
			      
						 y =p->stf;
//将删除掉的节点 存入缓存中，以待下次使用
             push_memory_to_cache( p );
			     }
		  	 return  y;
   }
//队列遍历,当到达末尾时，返回空
	 Key*          next()
  {
             if( ! current )
				     return NULL;
			      Key   y=0;
			     y = current->stf;
			     current = current->next;
			     return  stf;
   }
//将 当前遍历的节点 重置，这样它就指向第一个节点
	 void         rewind()
  {
	       current = head;
   }
//
//将队列的内容清空
	void          clean()
 {
	    Node    *p=head,*t;
		  while(  p )
		  { 
			       t = p;
				     p = p->next;
				    delete   t;
		  }
//调整当前缓存的大小
      int      _size=_cache_size-3;
      if( _size>0 )
     {
                 _cache_size=3;
		             p=cache;
		             while(  p && _size )
		            {
			                 	 t=p;
				                 p=p->next;
				                 free( t );
                          --_size;
		             }
                 cvache=p;
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
                  free( nodde); 
   }
//
  };
#endif