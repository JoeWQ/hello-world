/*
  *@aim:系统函数库
  &2016-3-7 16:56:00
  */
#include"help.h"
#include<stdio.h>
bool      Help::littleEndin()
{
	      int     _endin=1;
		  return     *((char   *)(&_endin)) & 0x1;
}
//从文件中读取内容
const   char  *Help::getFileContent(const char *_file_name)
{
	          char      *_buff=NULL;
			  FILE      *_file=fopen(_file_name,"rb");

			  if( !_file   )
				        return    NULL;
			  fseek(_file,0,SEEK_END);
			  int      _size=(int)ftell(_file);

			  fseek(_file,0,SEEK_SET);
			  _buff=new   char[_size+2];
			  fread(_buff,1,_size,_file);
			  _buff[_size]='\0';

			  fclose(_file);
			  _file=NULL;
			  return   _buff;
}