//����ͱ���ص����ݽṹ
  typedef  struct  _Edge
 {
//��ʼ����
       int   from;
//Ŀ�Ľ��
       int   to;
//�ߵ�Ȩֵ
       int   cost;
       struct  _Edge  *next;
  }Edge;
//��¼�ߵ������Ϣ�Ľṹ
  typedef  struct  _EdgeInfo
 {
//��¼�ߵ���Ŀ
       int   size;
//ָ��ߵ�ָ��
       struct  _Edge   *front;
  }EdgeInfo;