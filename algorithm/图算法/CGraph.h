/*
  *@aim:�й�ͼ�����ݽṹ��һЩ�����㷨
  *@date:2014-10-31 16:44:26
  *@author:�ҽ���
  */
  #ifndef  __CGRAPH_H__
  #define  __CGRAPH_H__
  #include"Array.h"
//ͼ�ڲ�ʹ�õ����ݽṹ
//�ٽֱ�ĸ�����ĺ�̶���ֱ�ӱ�ʾ
          struct    CSequela
         {
//����ı�ʾ
                  int                           vertex_tag;
//�ö����ǰ���̽���ʾ
                  int                           prev_vertex;
//����prev_vertex��vertex_tag֮��Ļ�����ʾ��Ȩֵ
                  int                           weight;
 //                 struct    CVertex      *prev;
                  struct    CSequela      *next;
//��ֹ���ƹ��캯��
                private:
                      CSequela(  CSequela &);
          };
          struct      CVertex
         {
//��ǰ�ڵ�ĺ�̽���ʾ
                   struct          CSequela          *post_vertex;
//��ǰ����ı�ʾ����һ����������λ��������ȣ�Ҳ����Ϊ����ֵ
//                   int               tag;
//��ǰ�ڵ�ĺ�̽����Ŀ
                   int               post_count;
//��ǰ�ڵ��ǰ���ڵ���Ŀ
                   int               prev_count;
//��Ϊ��ʱ���ݶ����ڵ��򣬵�ʹ����������ʱ���õ�
                   bool             is_visited;
//��ֹ�������캯��
               private:
                   CVertex( CVertex &);
          };
//ͼ���ٽֱ��ʾ
  class    CGraph
 {
//--------------------------------------------------------------------------------------------------------
          CVertex          *vertex;//�ٽ�����
          int                   size;   //��ǰ�������Ŀ
//��ֹ����֮��ĸ���
    private:
          CGraph(  CGraph  &);
    public:
//�������Ϊͼ���ڽӾ����ʾ
         CGraph(  Array    *  );
         ~CGraph();
//��ȡͼ�Ķ�����Ŀ
         int        getVertexCount();
//��ȡͼ�бߵ���Ŀ
         int        getEdgeCount();
//���ض���v�����к�̽�����ʼ���ݽṹ��ַ,���v�����������Ч��Χ���򷵻�NULL
         CSequela       *getSequelaVertex(int     v);
//�����йض���v�����ݽṹ
         CVertex         *getCVertex(int   v);
//ͼ�����������������,�������ֵ>0,˵��ͼ�Ŀ��Բ���һ��������������,����˵��ͼ���л�·���޷�����һ��������������
//@request:size of seq >=this->size+1,and the last index contains value -1
         int      topologicSort( int      *vertexes  );
  }; 
  #endif
