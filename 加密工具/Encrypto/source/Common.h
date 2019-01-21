/*
  *����ͷ�ļ�
  *2017-10-21 11:54:51
  *@Author:xiaoxiong
 */
#ifndef __COMMON_H__
#define __COMMON_H__
#include<stdio.h>
#include<vector>
#include<string>
namespace encrypto
{
	typedef unsigned char byte;
	/*
	  *�ļ����Զ���
	 */
	enum   FileAttrib
	{
		FileAttrib_Unknown = 0,//δ֪������
		FileAttrib_File = 1,//�ļ�
		FileAttrib_Directory = 2,//Ŀ¼
	};
	/*
	  *��ȡ�����ļ�������
	  *�ı����߶������ļ�����
	  *����ļ������ڻ����ļ���ʧ��,�򷵻ؿ�ֵ
	  *���򷵻��ļ�������,�Լ��ļ��ĳ���
	 */
	byte   *GetFileContent(const char *filename, int   *length);

	//�����ļ���,�ж����ļ�����Ŀ¼
	FileAttrib     GetFileAttrib(const char *filename);
	/*
	  *�����Ŀ¼,���ȡ��Ŀ¼�µ��������ļ�����Ŀ¼�ļ���
	 */
	void       GetChildrenFileList(const char *filename,std::vector<std::string> &children);
	/*
	  *ʹ�ø������ַ����Ը��������ݼ���
	 */
	void     EncryData(byte *data,int size,const std::string &encryString);
	/*
	  *ʹ�ø������ַ��������ݽ���
	 */
	void       DecodeData(byte *data,int size,const std::string &encryString);
	/*
	  *������д�뵽ָ�����ļ���,���д��ʧ��,�򷵻�0
	  *ʧ�ܵ�ԭ��������ļ�������,��ȡȨ�޲���
	 */
	int      WriteFile(const char *filename,byte *data,int length);
}
#endif
