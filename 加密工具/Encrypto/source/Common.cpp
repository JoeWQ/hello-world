/*
  *公共函数实现
  *@author:xiaoxiong
  *2017-10-21 12:01:22
 */
#include<fstream>
#include"Common.h"
#ifdef _WIN32
#include<windows.h>
#else
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include<dirent.h>
#endif
namespace encrypto
{
	byte   *GetFileContent(const char *filename, int   *length)
	{
		byte      *_buff = nullptr;
		FILE      *_file = fopen(filename, "rb");

		if (!_file)
			return    NULL;
		fseek(_file, 0, SEEK_END);
		int      _size = (int)ftell(_file);

		fseek(_file, 0, SEEK_SET);
		_buff = new   byte[_size + 2];
		fread(_buff, _size, 1, _file);
		_buff[_size] = '\0';

		fclose(_file);
		_file = nullptr;
		if (length)
			*length = _size;
		//std::ifstream infile;
		//infile.open(filename,std::ios::binary);
		//if (!infile.is_open())
		//	return nullptr;
		//infile.seekg(0, std::ios::end);
		//std::streampos ps = infile.tellg();
		//const int size = ps;
		//if (length)
		//	*length = size;
		//infile.seekg(0, std::ios::beg);
		////
		//_buff = new byte[size+2];
		//infile.read((char*)_buff, size);
		//infile.close();
		return   _buff;
	}

	FileAttrib GetFileAttrib(const char *filename)
	{
		FileAttrib   fileAttrib = FileAttrib::FileAttrib_Unknown;
#ifdef _WIN32
		DWORD   attrib = GetFileAttributes(filename);
		if (attrib != -1)
		{
			if (attrib & FILE_ATTRIBUTE_DIRECTORY)
				fileAttrib = FileAttrib::FileAttrib_Directory;
			else
				fileAttrib = FileAttrib::FileAttrib_File;
		}
#else
		struct stat fileState;
		if (!stat(filename, &fileState))
		{
			if (S_ISREG(fileState.st_mode))
				fileAttrib = FileAttrib::FileAttrib_File;
			else if(S_ISDIR(fileState.st_mode))
				fileAttrib = FileAttrib::FileAttrib_Directory;
		}
#endif
		return fileAttrib;
	}

	void  GetChildrenFileList(const char *filename,std::vector<std::string> &children)
	{
		children.clear();
		children.reserve(64);
        char buffer[512];
#ifdef _WIN32
		strcpy(buffer, filename);
		strcat(buffer, "/*");
		WIN32_FIND_DATAA    findFileData;
		HANDLE     fHandle;
		fHandle = FindFirstFileA(buffer,&findFileData);
		if (fHandle == INVALID_HANDLE_VALUE)
		{
			printf("Illegal directory name:%s\n",filename);
			return;
		}
		while (FindNextFileA(fHandle, &findFileData))
		{
			//过滤掉当前目录和上层目录,以及svn自己的目录
			if (!strcmp(findFileData.cFileName, ".") || !strcmp(findFileData.cFileName, "..") || !strcmp(findFileData.cFileName,".svn"))
				continue;
			//需要构建完整的路径
			sprintf(buffer,"%s/%s",filename,findFileData.cFileName);
			children.push_back(buffer);
		}
		FindClose(fHandle);
		fHandle = nullptr;
#else
        //struct stat fileState;
        DIR  *directory=opendir(filename);
        if( ! directory)
        {
            printf("Error to Visit Directory '%s'.\n",filename);
            return;
        }
        struct dirent *dirEntry=nullptr;
        while((dirEntry = readdir(directory))!=nullptr)
        {
            //do not visit current directory and parent directory and svn
            if(!strcmp(dirEntry->d_name,".") || !strcmp(dirEntry->d_name,"..")
               || !strcmp(dirEntry->d_name,".svn"))
                continue;
            sprintf(buffer,"%s/%s",filename,dirEntry->d_name);
            children.push_back(buffer);
        }
        //close dirent
        closedir(directory);
        directory=nullptr;
#endif
	}
	static const int  otherKey = 0x45;
	void   EncryData(byte *data, int size, const std::string &encryString)
	{
		const int stepSize = encryString.size();
		const char *encryptoChar = encryString.c_str();
		int     j = 0;
		for (; j +stepSize< size; j += stepSize)
		{
			for (int k = j,c=0; c < stepSize; ++k,++c)
				data[k] = (data[k] ^ encryptoChar[c]) + otherKey;
		}
		//不管上面的循环怎么进行,下面的代码一定会走
		for (int  c=0; j < size; ++j,++c)
			data[j] = (data[j] ^ encryptoChar[c]) + otherKey;
	}

	void   DecodeData(byte *data, int size, const std::string &encryString)
	{
		const  int  stepSize = encryString.size();
		const char *encryptoChar = encryString.c_str();
		int     j = 0;
		for (; j + stepSize < size; j += stepSize)
		{
			for (int k = j, c = 0; c < stepSize; ++k, ++c)
				data[k] = (data[k] - otherKey)^ encryptoChar[c];
		}
		//不管上面的循环怎么进行,下面的代码一定会走
		for (int c = 0; j < size; ++j, ++c)
			data[j] = (data[j] - otherKey) ^ encryptoChar[c];
	}

	int  WriteFile(const char *filename,byte *data, int length)
	{
		FILE      *file = fopen(filename, "wb");

		if (!file)
			return    0;
		fwrite(data, length, 1, file);
		fclose(file);
		file = nullptr;
		return 1;
	}
}
