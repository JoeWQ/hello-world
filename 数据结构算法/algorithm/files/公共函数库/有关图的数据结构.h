//2013/1/20/16:40
//����ͼ�����ݽṹ
  typedef  struct  _PostVertex
 {
        int        vertex;
        struct  _PostVertex  *next;
  }PostVertex;
  typedef  struct  _PostGraph
 {
//��¼�ýڵ��ǰ�����
        int   vp;
//��¼�ýڵ�ı�ʾ
        int   vertex;
//Ȩֵ
        int   weight;
        struct  _PostGraph   *next;
  }PostGraph;
  typedef   struct  _Graph
 {
//��¼���ĺ�̽��
       int                    count;
//��¼���㱻���ʵ����
       int                    v;
//��¼�ý���뿪ջʱ��ʱ���
       struct   _PostGraph    *front;
//��¼�����������ǰ��̹�ϵ�Ķ���
       struct   _PostVertex   *adj;
  }Graph;
//ͼ����Ϣͷ
  typedef  struct  _GraphHeader
 {
//��¼ͼ�ж������Ŀ
       int   size;
//��¼�ڽӱ��ʾ��ͼ����ʼָ��
       struct  _Graph    *graph;
  }GraphHeader;
        