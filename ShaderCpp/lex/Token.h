/*
  *���дʷ���Ԫ�ĸ���
  *@2017-8-2
  *@Author:xiaohuaxiong
 */
#ifndef __TOKEN_H__
#define __TOKEN_H__
#include "common/Object.h"
#include "common/Common.h"
#include <string>

class Token :public Object 
{
	//�ʷ���Ԫ������
	LexicalType    _lexType;
	//�ʷ���Ԫ������
	std::string       _lexString;
public:
	Token(LexicalType lexType,const std::string &lexString);
	//���شʷ���Ԫ������
	inline LexicalType getType()const { return _lexType; };
	//���شʷ���Ԫ���ַ�����ʾ
	const std::string    getString()const { return _lexString; };
};

#endif