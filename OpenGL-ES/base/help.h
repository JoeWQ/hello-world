/*
  *@aim:ϵͳ������,���õĸ��ָ�������
  &2016-3-7 16:50:13
  */
#ifndef    __HELP_H__
#define   __HELP_H__
class     Help
{
//��ֹ������Ķ���
private:
	Help();
	Help(Help &);
	~Help();
public:
//�Ƿ���Сβ����
static    bool        littleEndin();
//�Ӹ������ļ��ж�ȡ�ļ�����,������ļ�ʧ��,����NULL
static    const      char     *getFileContent(const  char *_file_name);
};
#endif