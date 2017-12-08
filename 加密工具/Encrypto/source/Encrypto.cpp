// Encrypto.cpp : �������̨Ӧ�ó������ڵ㡣
//

#include<stdio.h>
#include<queue>
#include<string.h>
#include<stdlib.h>
#include"Common.h"

int main(int argc, char *argv[])
{
	/*
	*�������ж�ȡ����
	*/
	if (argc < 3)
	{
		printf("Usage:'%s' 'file or directory name encrypto-key'.\n", argv[0]);
		exit(1);
	}
	int   stringSize = strlen(argv[1]);
	if (stringSize > 512 || stringSize < 2)
	{
		printf("too long or too short file name it is!\n");
		exit(2);
	}
	if (argv[1][stringSize - 1] == '/' || argv[1][stringSize - 1] == '\\')
		stringSize -= 1;
	char    targetDirectory[512];
	strncpy(targetDirectory, argv[1], stringSize);
	targetDirectory[stringSize] = 0;
	//���ܵļ�
	const std::string    encryKey = argv[2];
	if (encryKey.size() < 4)
	{
		printf("Encrypto Key is too short.Please input again.\n");
		exit(3);
	}
	int    length = 0;
	//�жϸ������ļ����Ƿ���Ŀ¼,�Դ˾����Ƿ�ִֻ��һ�μ��ܻ��߼���ָ�����ļ���
	encrypto::FileAttrib   fileAttrib = encrypto::GetFileAttrib(targetDirectory);
	if (fileAttrib == encrypto::FileAttrib::FileAttrib_File)
	{
		encrypto::byte    *data = encrypto::GetFileContent(targetDirectory, &length);
		if (data != nullptr)
		{
			//����
			encrypto::EncryData(data, length, encryKey);
			//����
			//encrypto::DecodeData(data, length, encryKey);
			//����д���ļ�
			encrypto::WriteFile(targetDirectory, data, length);
			delete[] data;
			data = nullptr;
			printf("Encrypto file '%s' Successfully!\n", targetDirectory);
		}
		else
			printf("error ,read target file '%s' error.\n", targetDirectory);
	}
	else if (fileAttrib == encrypto::FileAttrib::FileAttrib_Directory)//�ݹ�����ļ�
	{
		std::vector<std::string>  fileListVec;//�ļ��б�
		encrypto::GetChildrenFileList(targetDirectory, fileListVec);
		//��������
		std::queue<std::string>   fileQueue;
		for (std::vector<std::string>::iterator it = fileListVec.begin(); it != fileListVec.end(); ++it)
			fileQueue.push(*it);
		//����
		while (!fileQueue.empty())
		{
			std::string   filename = fileQueue.front();
			fileQueue.pop();
			//
			fileAttrib = encrypto::GetFileAttrib(filename.c_str());
			if (fileAttrib == encrypto::FileAttrib::FileAttrib_File)
			{
				encrypto::byte *data = encrypto::GetFileContent(filename.c_str(), &length);
				if (data != nullptr)
				{
					//����
					encrypto::EncryData(data, length, encryKey);
					//����
					//encrypto::DecodeData(data, length, encryKey);
					//
					encrypto::WriteFile(filename.c_str(), data, length);
					delete[] data;
					data = nullptr;
					printf("Encrypto file '%s' Copmplete\n", filename.c_str());
				}
				else
				{
					printf("Get File '%s' Content Failed.\n", filename.c_str());
				}
			}
			else if (fileAttrib == encrypto::FileAttrib::FileAttrib_Directory)
			{
				std::vector<std::string>  fileList;
				encrypto::GetChildrenFileList(filename.c_str(), fileList);
				printf("Enter Directory '%s' \n", filename.c_str());
				//
				for (std::vector<std::string>::iterator it = fileList.begin(); it != fileList.end(); ++it)
					fileQueue.push(*it);
			}
		}
	}
	else
	{
		printf("Unknown File Type,file name is '%s'.\n", targetDirectory);
	}
	//getchar();
	return 0;
}

