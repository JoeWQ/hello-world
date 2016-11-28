#include"LinkedList.h"
#include<stdlib.h>
#include<string.h>
/*
  *modify at 2013年12月18日
  *2014年1月23日
  *version 2
  *增加功能，缓存管理
  *2014年3月8日
  *版本3，修正缓存的容量管理
  *
  */
template<typename Key>
  LinkedList<Key>::LinkedList()
  {
		  memset(this,0,sizeof(LinkedList<Key>));
  }
  template<typename Key>
  LinkedList<Key>::~LinkedList()
  {
//	     if( can_clean)
             clean();
  }
//**********************private******************************************
template<typename Key>
  Node    *LinkedList<Key>::get_memory_from_cache()
 {
           Node   *node=NULL;
           if( cache   )
          {
                   --cache_size;
                   node = cache;
                   cache=cache->next;
          }
          else
                   node=(Node  *)malloc(sizeof(Node) );
          
          return   node;
  } 
//缓存的容量做多不会超过 链表总节点数目的 1/4 +3
template<typename Key>
  void     LinkedList<Key>::push_memory_to_cache( Node *node)
 {
          node->next=NULL;
          if(  cache_size <=(size>>2)    )
         {
                   ++cache_size;
                   node->next=cache;
                   cache=node;
          }
         else
                  free( nodde); 
 }
//******************************************************************
  template<typename  Key>
  int    LinkedList<Key>::getSize()
  {
	       return   size;
  }
  template<typename Key>
  void  LinkedList<Key>::setCleanupFlag(bool   b)
  {
	        can_clean = b;
  }
  template<typename Key>
  void       LinkedList<Key>::clean()
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
		  p=cache;
		  while(  p )
		  {
				 t=p;
				 p=p->next;
				 free( t );
		  }
      bool  b=can_clean;
		  memset(this,0,sizeof(LinkedList<Key>));
      can_clean=b;
  }

  template<typename Key>
  void    LinkedList<Key>::addFirst(Key    *v)
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
  //
  template<typename Key>
  Key*    LinkedList<Key>::removeFirst(   )
  {
	       Node    *p=head;
		   if(  head )
		   {
			       --size;
				   head = head->next;
				   if(  tail == p)
					   tail = NULL;
				   else
					   head->prev =NULL;
		   
				   Key    *stf = p->stf;
//将删除掉的节点存入缓存中，这样可以加快内存的分配
           push_memory_to_cache( p );
//**********************************************************
			//	free(p);
				return  stf;
		   }
		   return  NULL;
  }
  //
  template<typename Key>
  void     LinkedList<Key>::addLast(Key   *v)
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
//
  template<typename Key>
  Key*    LinkedList<Key>::removeLast()
  {
	          Node    *p = tail;
		    	  if( tail )
		    	 {					
				         --size;
				         tail = tail->prev;
				         if(  p == head )
                        head = NULL;
				    		else
							          tail->next = NULL;
			      
						 Key   *stf =p->stf;
//将删除掉的节点 存入缓存中，以待下次使用
             push_memory_to_cache( p );
   //                  free(p);
						 return   stf;
			     }
		  	 return  NULL;
  }

  template<typename Key>
  Key*    LinkedList<Key>::next()
  {
             if( ! current )
				     return NULL;
			      Key   *stf=NULL;

			stf = current->stf;
			current = current->next;
			return  stf;
  }
  //重绕
  template<typename Key>
  void     LinkedList<Key>::rewind()
  {
	        current = head;
  }
//******************************************************