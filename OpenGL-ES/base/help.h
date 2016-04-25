/*
  *@aim:系统函数库,常用的各种辅助函数
  &2016-3-7 16:50:13
  */
#ifndef    __HELP_H__
#define   __HELP_H__
class     Help
{
//禁止创建类的对象
private:
	Help();
	Help(Help &);
	~Help();
public:
//是否是小尾端序
static    bool        littleEndin();
//从给定的文件中读取文件内容,如果打开文件失败,返回NULL
static    const      char     *getFileContent(const  char *_file_name);
};
#endif