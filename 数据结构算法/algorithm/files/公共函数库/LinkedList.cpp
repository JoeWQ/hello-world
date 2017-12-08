#include"LinkedList.h"
#include<stdlib.h>
#include<string.h>
/*
  *modify at 2013年12月18日
  *2014年1月23日
  *version 2
  *增加功能，缓存管理
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
		  memset(this,0,sizeof(LinkedList<Key>));
  }

  template<typename Key>
  void    LinkedList<Key>::addFirst(Key    *v)
  {
	       Node    *p ;
//先在缓存中查找 是否有 可用的内存
         if(  cache )
        {
                 p = cache;
                 cache = cache->next;
        }
        else
               p = (Node *)malloc(sizeof(Node ) );
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
				   p->next = cache;
                   p->prev =NULL;
                  cache = p;
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
	    Node    *p=NULL;
      if(  cache )
     {
            p = cache;
            cache = cache->next;
      }
      else
            p=(Node  *)malloc(sizeof(Node));
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
             p->prev=NULL;
             p->next= cache;
             cache = p;
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