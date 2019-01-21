/*
  *双端队列,2013.12.18
  *version2 ,增加功能，缓存管理
  *2014年1月23日
  *2014年3月8日
  *版本3，修正缓存的容量管理
  */
#ifndef    __LINKED_LIST_H
#define   __LINKED_LIST_H
/*
  *
  */
template<typename   Key>
class      LinkedList
{
	        struct     _Node
			{
				     Key       *stf;
					 struct    _Node       *prev;
					 struct    _Node       *next;
			};
			typedef    struct    _Node     Node;
private:
	   int             size;         //当前节点的数目
	   Node         *head;      //头节点
	   Node         *tail;        //尾节点
	   Node         *current;   //当前访问的节点
	   Node         *indx;       //当前遍历的节点 的索引，注意，这个队列并不支持冰法访问
     Node         *cache;     //缓存，为了加速 内存的分配
     int             cache_size;
	   bool            can_clean;  //如果设置了这个标志，则队列自动清除所有的 对象
//下面的私有方法 是缓存的管理
//从缓存中获取 内存块
     Node    *get_memory_from_cache();
//将 内存块压入缓存区
     void     push_memory_to_cache( Node *);
private:
public:
	   LinkedList();
	   ~LinkedList();
// 将一个节点 添加到 队列中
	   void         addFirst(Key     *v);
//删除头结点,如果已经没有节点，则返回空
	   Key*         removeFirst();
//在队列的末尾添加一个节点
	   void          addLast(Key    *);
//删除队列的尾节点,如果已经没有节点，则返回空
	   Key*         removeLast();
//队列遍历,当到达末尾时，返回空
	   Key*          next();
//将 当前遍历的节点 重置，这样它就指向第一个节点
	   void         rewind();
//
	   void          setCleanupFlag(bool   clean);
//将队列的内容清空
	   void          clean();
//获取节点的 数目
	   int            getSize();
};
#endif