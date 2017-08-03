/*
  *Shader脚本翻译工具中所要用到的全局数据结构
  *2017-8-2
  *@Author:xiaohuaxiong
*/
#ifndef __COMMMON_H__
#define __COMMMON_H__
#include<string>
/*
  *词法单元的类型
  *用来标志着唯一的词法单元
 */
enum LexicalType
{
	LexicalType_None = 0,//无效的词法分析单元
	LexicalType_ClassComment = 1,//类注释
	LexicalType_ClassName = 2,//类名字
	LexicalType_Field = 3,//域名
	LexicalType_Attribute =4,//属性名
	LexicalType_Type = 5,//类型
	LexicalType_Note = 6,//域/属性的注释
	LexicalType_Colon = 7,//冒号
	LexicalType_Comma = 8,//逗号
	LexicalType_String = 18,//字符串
};
/*
  *类的类型
 */
enum  ClassType
{
	ClassType_VFS = 24,//顶点片段shader
	ClassType_VGFS = 25,//顶点几何片段shader
	ClassType_CS=26,//计算shader
};
/*
  *对于域或者属性来说,他们的类型
 */
enum VariableType
{
	VariableType_Int = 32,//整型
	VariableType_Float = 33,//浮点
	VariableType_Vec2 = 34,//Vec2
	VariableType_Vec3 = 35,//Vec3
	VariableType_Vec4 = 36,//Vec4
	VariableType_Mat3 = 37,//3阶矩阵
	VariableType_Mat4 = 38,//4阶矩阵
	VariableType_Sampler2D = 39,//采样器
	VariableType_SamplerCube = 40,//立方体贴图
	VariableType_Shadow = 41,//阴影贴图
	VariableType_ShadowArray = 42,//级联阴影贴图
};
//获取系统时间
struct SysTime
{
	int year;
	int month;
	int day;
	int hour;
	int second;
	int minus;
};
//获取系统时间
void    getSysTime(SysTime  &sysTime);
//给定字符串,返回头文件中首行宏判断字符串
void    getHeaderMicro(const std::string &input,std::string &micro);
/*
*关于Shader类型中,不同类型对应的不同的初始化函数的参数列表
*/
const char *getClassParam(ClassType  classType);
/*
  *获取每一种变量类型对应的引擎中的数据结构的名字
 */
const std::string  &getVariableType(VariableType   variableType);
//将对应的域名转换为在Shader文件中函数参数列表中的参数名字
void   convertFieldNameToFuncParam(const std::string &fieldName,std::string &shaderName);
//将对应的属性名转换为在CPP文件中变量的名字
void   convertAttributeNameToCppVariable(const std::string &attribName,std::string &variableName);
//将对应的域的名字转换为CPP文件中变量的名字
void   convertFieldNameToCppVariable(const std::string &fieldName,std::string &variableName);
#endif