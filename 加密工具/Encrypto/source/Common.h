/*
  *公共头文件
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
	  *文件属性定义
	 */
	enum   FileAttrib
	{
		FileAttrib_Unknown = 0,//未知的属性
		FileAttrib_File = 1,//文件
		FileAttrib_Directory = 2,//目录
	};
	/*
	  *获取给定文件的内容
	  *文本或者二进制文件数据
	  *如果文件不存在或者文件打开失败,则返回空值
	  *否则返回文件的内容,以及文件的长度
	 */
	byte   *GetFileContent(const char *filename, int   *length);

	//给定文件名,判断是文件还是目录
	FileAttrib     GetFileAttrib(const char *filename);
	/*
	  *如果是目录,则获取该目录下的所有子文件与子目录的集合
	 */
	void       GetChildrenFileList(const char *filename,std::vector<std::string> &children);
	/*
	  *使用给定的字符串对给定的数据加密
	 */
	void     EncryData(byte *data,int size,const std::string &encryString);
	/*
	  *使用给定的字符串将数据解密
	 */
	void       DecodeData(byte *data,int size,const std::string &encryString);
	/*
	  *将数据写入到指定的文件中,如果写入失败,则返回0
	  *失败的原因可能是文件不存在,存取权限不够
	 */
	int      WriteFile(const char *filename,byte *data,int length);
}
#endif
