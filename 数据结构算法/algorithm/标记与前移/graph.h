/*
  *@aim:�й�ͼ�����ݽṹ��������ר��Ϊ�����ǰ���㷨���趨��
  @date:2015-6-2
  */
 #ifndef    __GRAPH_H__
 #define   __GRAPH_H__
 //����������
 #define     _GRAPH_      1
 #include"CArray2D.h"
//�ڽӶ���(ǰ���ͺ�̵ļ���)
   struct      CAdjoinVertex
  {
//�ڽӶ���ı�ʾ��
                int                                              adjoinVertex;
//
                struct      CAdjoinVertex         *next;
   };
//����ĺ�̶��㣬�Լ�Ȩֵ�ļ���
   struct      CSequelaVertex
  {
//��ǰ����ĺ�̶���
                int                                              sequelaVertex;
//��ǰ����,������һ������Ϊ�����㷨�����п��Ա��ⲻ��Ҫ�Ĳ���
                int                                              actualVertex;
//��ǰ�������̶���֮�������ɵıߵ�Ȩֵ
                int                                              weight;
//ָ����һ��ͬ���ĺ�̽ڵ�
                struct     CSequelaVertex         *next;
//ָ��ǰһ��������ɾ������
//                struct     CSequelaVertex         *prev;
   };
//ÿһ���������ݽṹ
   struct       CVertex
  {
 //����ĺ�̶���
                CSequelaVertex          *m_sequelaVertex;
//����������ڽӶ���
                CAdjoinVertex            *m_adjoinVertex;
//����ı�ʶ��,ʵ����������ݲ��Ǳ������Ϊ���ڽӱ�������Ѿ���ʾ������ֵ,����ֻ��һ������
//����ʹ����Ҳ���Խ����������������Ŀ��
                int                         m_vertex;
//��̶�����Ŀ                
                int                         m_sequelaCount;
   };
   class    CGraph
  {
private:
//ָ��CVertex�ṹ�����ָ��
                CVertex                *m_vertex;
//����Ĵ�С
                int                         m_size;
private:
                CGraph(CGraph &);
public:
//���ڽӾ������룬���Ǻ����������������Ч��
                CGraph(CArray2D<int>   *);
                ~CGraph();
                int               size();
//���ͼ����������ע�⣬���������Զ���Դ��Ŀ�궥���ų����������Ҫʹ����
//�Լ�ȥ��
               int               topologicSort(int     *);
//���ظ����Ķ�����й����ݽṹ,ע��ʹ���߾����ܲ�Ҫ�����޸����������,
//���Ƕ�����������ǳ��˽�,
               CVertex       *getVertex(int   *);
   };
 #endif
 