/*
  *˫�˶���,2014��8��9��
  *@version3 ,���ӹ��ܣ��������,�Ի���ĸ���ϸ�Ŀ���,ֱ�ӽ����ͷ����ϲ���.h�ļ���
  *@ʹ�õĶ��󣺽ṹ����߶���
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
	     Node           *head;          //ͷ�ڵ�
	     Node           *tail;            //β�ڵ�
	     Node           *current;       //��ǰ���ʵĽڵ�
       Node           *cache;         //���棬Ϊ�˼��� �ڴ�ķ���
       int              _cache_size;  //��ǰ�����ڴ��Ĵ�С
	     int              size;             //��ǰ�ڵ����Ŀ
	     bool            can_clean;   //��������������־��������Զ�������е� ����
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
// ��һ���ڵ� ��ӵ� ������
  void         addFirst(Key     *v)
 {
	       Node    *p = get_memory_from_cache();
//���ڻ����в��� �Ƿ��� ���õ��ڴ�
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
//ɾ��ͷ���,����Ѿ�û�нڵ㣬�򷵻ؿ�
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
//��ɾ�����Ľڵ���뻺���У��������Լӿ��ڴ�ķ���
           push_memory_to_cache( p );
		   }
		   return  y;
  }
//�ڶ��е�ĩβ���һ���ڵ�
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
//ɾ�����е�β�ڵ�,����Ѿ�û�нڵ㣬�򷵻ؿ�
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
//��ɾ�����Ľڵ� ���뻺���У��Դ��´�ʹ��
             push_memory_to_cache( p );
			     }
		  	 return  y;
   }
//���б���,������ĩβʱ�����ؿ�
	 Key*          next()
  {
             Key        *y=NULL;
             if( ! current )
				     return y;
			     y= current->stf;
			     current = current->next;
			     return  y;
   }
//�� ��ǰ�����Ľڵ� ���ã���������ָ���һ���ڵ�
	 void         rewind()
  {
	       current = head;
   }
//
	   void          setCleanupFlag(bool   _clean)
    {
             can_clean = _clean;
     }
//�����е��������
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
//������ǰ����Ĵ�С
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
//��ȡ�ڵ�� ��Ŀ
	   int            getSize()
    {
           return   size;
    }
//˽�з���
private:
//��ȡ�ڴ�
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
//���ڴ����ӵ����棬�����ͷŵ�
//������������಻�ᳬ�� �����ܽڵ���Ŀ�� 1/4 +3
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
