/*
  *�����������
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
	//�������
	VariableType  _variableType;
	//�������
	std::string		_fieldName;
	//�����������
	std::string		 _fieldComment;
	//�Ƿ�������
	bool                 _isArray;
public:
	Field(VariableType variableType,const std::string &fieldName,const std::string &fieldComment);
	Field(VariableType variableType, const std::string &fieldName);
	//�����������
	inline VariableType  getFieldType()const { return _variableType; };
	//�����������
	void		setFieldComment(const std::string &fieldComment);
	inline const std::string &getFieldComment()const { return _fieldComment; };
	inline const std::string &getFieldName()const { return _fieldName; };
	//�Ƿ�������
	bool     isArray()const { return _isArray; };
	void     setArray(bool b) { _isArray = b; };
	//��ͷ�ļ��и�ʽ���������
	void     formatFieldInHeader(std::string &result);
	//��ͷ�ļ��и�ʽ��������ĺ���
	void     formatFuncInHeader(std::string &result);
	//��C++�ļ��и�ʽ��������ĺ���
	void     formatFuncInCpp(const std::string &className,std::string &result);
};

#endif