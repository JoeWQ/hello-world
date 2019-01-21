/*
  *˫�˶���,2013.12.18
  *version2 ,���ӹ��ܣ��������
  *2014��1��23��
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
	   int             size;         //��ǰ�ڵ����Ŀ
	   Node         *head;      //ͷ�ڵ�
	   Node         *tail;        //β�ڵ�
	   Node         *current;   //��ǰ���ʵĽڵ�
	   Node         *indx;       //��ǰ�����Ľڵ� ��������ע�⣬������в���֧�ֱ�������
       Node         *cache;     //���棬Ϊ�˼��� �ڴ�ķ���
	   bool            can_clean;  //��������������־��������Զ�������е� ����
public:
	   LinkedList();
	   ~LinkedList();
// ��һ���ڵ� ��ӵ� ������
	   void         addFirst(Key     *v);
//ɾ��ͷ���,����Ѿ�û�нڵ㣬�򷵻ؿ�
	   Key*         removeFirst();
//�ڶ��е�ĩβ���һ���ڵ�
	   void          addLast(Key    *);
//ɾ�����е�β�ڵ�,����Ѿ�û�нڵ㣬�򷵻ؿ�
	   Key*         removeLast();
//���б���,������ĩβʱ�����ؿ�
	   Key*          next();
//�� ��ǰ�����Ľڵ� ���ã���������ָ���һ���ڵ�
	   void         rewind();
//
	   void          setCleanupFlag(bool   clean);
//�����е��������
	   void          clean();
//��ȡ�ڵ�� ��Ŀ
	   int            getSize();
};
#endif