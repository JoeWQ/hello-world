/*
  *关于域的描述
  *2017-8-2
  *@Author:xiaohuaxiong
 */
#ifndef __FIELD_H__
#define __FIELD_H__
#include "common/Object.h"
#include "common/Common.h"
#include<string>

class Field :public Object
{
	//域的类型
	VariableType  _variableType;
	//域的名字
	std::string		_fieldName;
	//关于域的描述
	std::string		 _fieldComment;
	//是否是数组
	bool                 _isArray;
public:
	Field(VariableType variableType,const std::string &fieldName,const std::string &fieldComment);
	Field(VariableType variableType, const std::string &fieldName);
	//返回域的类型
	inline VariableType  getFieldType()const { return _variableType; };
	//设置域的描述
	void		setFieldComment(const std::string &fieldComment);
	inline const std::string &getFieldComment()const { return _fieldComment; };
	inline const std::string &getFieldName()const { return _fieldName; };
	//是否是数组
	bool     isArray()const { return _isArray; };
	void     setArray(bool b) { _isArray = b; };
	//在头文件中格式化域的名字
	void     formatFieldInHeader(std::string &result);
	//在头文件中格式化关于域的函数
	void     formatFuncInHeader(std::string &result);
	//在C++文件中格式化关于域的函数
	void     formatFuncInCpp(const std::string &className,std::string &result);
};

#endif