/*
  *@aim:��̬��ά�����ʵ��,��Ƶ�Ŀ����ʹ�÷��㣬ִ�п���
  *@time:2014-9-22
  *@author:�ҽ���
  */
#ifndef   __ARRAY_H__
#define   __ARRAY_H__
//������̬����ĺ�
 class   Array
{
   private:
//������׵�ַ,�мǣ����µ��������ݲ�Ҫ�ڳ����������и��ģ�����֮���Կ�������Ȩ�ޣ���ȫ��Ϊ��Ч��
       int        *yr;
//��¼�����������
       int        row;
       int        column;
   public:
       Array(int   row,int   column);
       ~Array();
//��ȡ�����Ԫ��
       int          get(int  x,int  y);
       void        set(int  x,int  y,int  c);
//����������֮�����ײ��ʵ��
       void    share(Array   *);
  private:
       Array(Array &);
 };
#endif
