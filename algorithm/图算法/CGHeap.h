/*
  *@aim:��С�ѵ�C++ʵ��
  *@date:2014-10-30 19:56:25
  *@author:�ҽ���
  */
 #ifndef    __CGHEAP_H__
#define    __CGHEAP_H__
//������װ�ص����ݽṹ
   struct     CGVertex
  {
//����Ĺؼ��֣�������Ա�ʾ�κκ���
            int       key;
//��ͼ������Ӧ�Ķ��㣬����˵�ؽڵ�ı�ʾ
            int       vertex;
   };
   class      CGHeap
  {
     private:
     public:
//�ײ���ʹ�õĶ�̬����
            CGVertex       *root;
//ά��һ�Ŷ���ı�ʾ�����ڶ���������λ�õ��������Ա��ڳ�����Կ��ٲ���
            int                 *vertex_index;
//�����ʵ�ʳ���
            int                 size;
//��ǰ������ܳ���
            int                 total_size;
     private:
            CGHeap(CGHeap   &);
     public:
            CGHeap();
            CGHeap(int    *,int    size);
            ~CGHeap();
//����в���Ԫ��,����
            void             insert(CGVertex   *);
//��ȡ�ѵ�ʵ�ʴ�С
            int                getSize();
//��ȡ���е���СԪ��,���ǲ�ɾ��,�����ǰ�Ѿ�û���κεĽڵ���ڣ��򷵻�NULL
            CGVertex       *getMin();
//ɾ����С�ѵĸ��ڵ�,��������Ѿ�û���κε�Ԫ�أ���ִ���κβ���
            void               removeMin();
//�Զ��е�һ���ڵ�ִ�м�ֵ����
            void               decreaseKey( CGVertex    * );
//�Զ�ִ�п��ٲ��ң���������Ϊ����ı�ʾ(����)�����ض��д洢�ñ�ʾ�Ķѽڵ�Ԫ�صĵ�ַ��
//�����������������ĺ��������õ�ʱ��ʹ�õ�
            CGVertex       *findQuoteByIndex(int    vertex_tag);
//
     private:
//������child�����Զ����µķ�ʽ������,�������ֻ���ڼ���ʽ������ʹ��
            void               adjust_top_bottom(int    parent);
//�Ե����ϵĶԶѵĽṹ���е���,�������ֻ���ڷǼ���ʽ������ʹ��
            void               adjust_bottom_top(int    child);
//�ѵĵײ���������
            void               expand(   );
//�ѵĵײ�ʵ�������ģ����
            void               shrink(   );
   };
#endif
