/*
  *����������Ʊ�ʾ,�Լ�����������
  *2017-8-2
  *@Author:xiaohuaxiong
 */
#ifndef __CLASS_H__
#define __CLASS_H__

#include "Token.h"

class Class :public Object
{
	//����
	ClassType      _classType;
	//����
	std::string     _className;
	//�������ע��
	std::string     _classComment;
public:
	//����
	Class(ClassType classType,const std::string &className);
	Class(ClassType classType, const std::string className,const std::string &classComment);
	//�����������
	inline ClassType   getClassType()const { return _classType; };
	//��������
	const std::string &getClassName()const;
	//���ع����������
	const std::string &getClassComment()const;
	//���ù����������
	void   setClassComment(const std::string &classComment);
	//��ʽ����Ŀ�ͷͷ�ļ�
	void   formatClassHeader(std::string &result);
	//��ʽ����Ĺ��캯����������,��ʼ������ͷ�ļ���
	void   formatConstructorH(std::string &result);
	//��ʽ�����
};

#endif