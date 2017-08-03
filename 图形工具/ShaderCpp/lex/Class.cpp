/*
  *类的名字
  *2017-8-2
  *@Author:xiaohuaxiong
 */
#include "Class.h"
Class::Class(ClassType classType, const std::string className, const std::string &classComment) :
	_classType(classType)
	,_className(className)
	,_classComment(classComment)
{

}

Class::Class(ClassType classType, const std::string &className):
	_classType(classType)
,_className(className)
{

}

const std::string &Class::getClassName()const
{
	return _className;
}

const std::string &Class::getClassComment()const
{
	return _classComment;
}

void Class::setClassComment(const std::string &classComment)
{
	_classComment = classComment;
}

void Class::formatClassHeader(std::string &result)
{
	SysTime  sysTime;
	getSysTime(sysTime);
	char         buffer[64];
	sprintf(buffer,"%d-%d-%d", sysTime.year, sysTime.month, sysTime.day);

	result.clear();
	result.append("/*\n");
	result.append(_classComment);
	result.append("	*").append(buffer).append("\n");//时间
	result.append("	*@Author:xiaohuaxiong\n");//追加作者
	result.append("*/\n");//
	//需要包含的头文件
	std::string micro;
	getHeaderMicro(_className,micro);
	result.append("#ifndef  ").append(micro).append("\n");
	result.append("#define ").append(micro).append("\n");
	result.append("#include \"engine/Object.h\"\n");
	result.append("#include \"engine/Geometry.h\"\n");
	result.append("#include \"engine/GLProgram.h\"\n");
	
	result.append("class	").append(_className).append(":public glk::Object\n");
	result.append("{\n");
}

void Class::formatConstructorH(std::string &result)
{
	result.clear();
	result.append("private:\n");
	result.append("	").append(_className).append("();\n");
	result.append("	").append(_className).append("(const ").append(_className).append("	&);\n");
	//判断类型
	const char  *param = getClassParam(_classType);
	result.append("	void		initWithFile(").append(param).append(");\n");

	result.append("public:\n");
	result.append("	~").append(_className).append("();\n");
	result.append("	static ").append(_className).append("		*create(").append(param).append(");\n");
}