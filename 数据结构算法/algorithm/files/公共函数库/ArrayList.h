//������,������ģ��
#ifndef    __ARRAY_LIST_H
#define   __ARRAY_LIST_H
// �������ص��ǣ������� ����ҪԶԶ���� ɾ������� ����
//֪ʶ�㣬ƽ̯����
//2013��12��27��
  template<typename   Key>
  class    ArrayList
  {
  private:
//  real size
	       int          ssize;
// total size
		   int          total_size;
// address of array
		   Key         **base;
		   bool        flag;
  public:
	       ArrayList();
		   ~ArrayList();
//��������  d���� Ԫ��ֵ
		   Key    *indexOf(int  d);
//����Ԫ��
		   void     insert(Key    *);
//ɾ�� ���� d ����Ԫ��
		   Key     *removeIndexOf(int    d);
//ɾ��Ԫ��
		   void     remove(Key   *);
//���� ɾ����־��0 ��ʾ���� ���� ģ���е� ָ�� ֵ��1��ʾ������ʱ��ɾ���������е�ָ�����
		   void     setClearFlag(bool   flag);
//���� ���� ��ǰ������
		   int       size();
//��� �����е�����Ԫ��
		   void     clear();

  };
#endif