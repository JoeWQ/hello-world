/*
  *关于类的名称表示,以及其他的属性
  *2017-8-2
  *@Author:xiaohuaxiong
 */
#ifndef __CLASS_H__
#define __CLASS_H__

#include "Token.h"

class Class :public Object
{
	//类型
	ClassType      _classType;
	//类名
	std::string     _className;
	//关于类的注释
	std::string     _classComment;
public:
	//类名
	Class(ClassType classType,const std::string &className);
	Class(ClassType classType, const std::string className,const std::string &classComment);
	//返回类的类型
	inline ClassType   getClassType()const { return _classType; };
	//返回类名
	const std::string &getClassName()const;
	//返回关于类的描述
	const std::string &getClassComment()const;
	//设置关于类的描述
	void   setClassComment(const std::string &classComment);
	//格式化类的开头头文件
	void   formatClassHeader(std::string &result);
	//格式化类的构造函数析构函数,初始化函数头文件中
	void   formatConstructorH(std::string &result);
	//格式化类的
};

#endif