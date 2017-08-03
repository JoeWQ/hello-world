/*
  *所有词法单元的父类
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
	//词法单元的类型
	LexicalType    _lexType;
	//词法单元的名字
	std::string       _lexString;
public:
	Token(LexicalType lexType,const std::string &lexString);
	//返回词法单元的类型
	inline LexicalType getType()const { return _lexType; };
	//返回词法单元的字符串表示
	const std::string    getString()const { return _lexString; };
};

#endif