/*
  *Shader�ű����빤������Ҫ�õ���ȫ�����ݽṹ
  *2017-8-2
  *@Author:xiaohuaxiong
*/
#ifndef __COMMMON_H__
#define __COMMMON_H__
#include<string>
/*
  *�ʷ���Ԫ������
  *������־��Ψһ�Ĵʷ���Ԫ
 */
enum LexicalType
{
	LexicalType_None = 0,//��Ч�Ĵʷ�������Ԫ
	LexicalType_ClassComment = 1,//��ע��
	LexicalType_ClassName = 2,//������
	LexicalType_Field = 3,//����
	LexicalType_Attribute =4,//������
	LexicalType_Type = 5,//����
	LexicalType_Note = 6,//��/���Ե�ע��
	LexicalType_Colon = 7,//ð��
	LexicalType_Comma = 8,//����
	LexicalType_String = 18,//�ַ���
};
/*
  *�������
 */
enum  ClassType
{
	ClassType_VFS = 24,//����Ƭ��shader
	ClassType_VGFS = 25,//���㼸��Ƭ��shader
	ClassType_CS=26,//����shader
};
/*
  *���������������˵,���ǵ�����
 */
enum VariableType
{
	VariableType_Int = 32,//����
	VariableType_Float = 33,//����
	VariableType_Vec2 = 34,//Vec2
	VariableType_Vec3 = 35,//Vec3
	VariableType_Vec4 = 36,//Vec4
	VariableType_Mat3 = 37,//3�׾���
	VariableType_Mat4 = 38,//4�׾���
	VariableType_Sampler2D = 39,//������
	VariableType_SamplerCube = 40,//��������ͼ
	VariableType_Shadow = 41,//��Ӱ��ͼ
	VariableType_ShadowArray = 42,//������Ӱ��ͼ
};
//��ȡϵͳʱ��
struct SysTime
{
	int year;
	int month;
	int day;
	int hour;
	int second;
	int minus;
};
//��ȡϵͳʱ��
void    getSysTime(SysTime  &sysTime);
//�����ַ���,����ͷ�ļ������к��ж��ַ���
void    getHeaderMicro(const std::string &input,std::string &micro);
/*
*����Shader������,��ͬ���Ͷ�Ӧ�Ĳ�ͬ�ĳ�ʼ�������Ĳ����б�
*/
const char *getClassParam(ClassType  classType);
/*
  *��ȡÿһ�ֱ������Ͷ�Ӧ�������е����ݽṹ������
 */
const std::string  &getVariableType(VariableType   variableType);
//����Ӧ������ת��Ϊ��Shader�ļ��к��������б��еĲ�������
void   convertFieldNameToFuncParam(const std::string &fieldName,std::string &shaderName);
//����Ӧ��������ת��Ϊ��CPP�ļ��б���������
void   convertAttributeNameToCppVariable(const std::string &attribName,std::string &variableName);
//����Ӧ���������ת��ΪCPP�ļ��б���������
void   convertFieldNameToCppVariable(const std::string &fieldName,std::string &variableName);
#endif