//Ϊͼ���ڽӱ�洢����Ƶ����ݽṹ
  typedef  struct  _PostGraph
 {
//vp�ĺ�̽��
       int          vertex;
//vertex�ĸ��ڵ㣬�����ϸ����˵��vp,vertexֻ��ͼ�������໥�ڽӵĶ���
       int          vp;
//��¼�ߵ�Ȩֵ
       int          cost;
       struct    _PostGraph    *next;
  }PostGraph;
/******************************************/
  typedef  struct  _Graph
 {
//��¼�ʹ˶������ڽӵĶ������Ŀ
      int                   size;
//ָ������ڽӵĶ����ָ��
      struct  _PostGraph   *front;
//���βָ��Ĵ���ֻ��Ϊ�˷����ڽӱ�Ĵ���
      struct  _PostGraph   *rear;
  }Graph;
//**************************************
//��¼����ͼ�ṹ�������Ϣ
  typedef  struct  _GraphHeader
 {
//�������Ŀ
      int              size;
//
      struct  _Graph  *graph;
 }GraphHeader;