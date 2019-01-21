/*
  *域描述
 */
#include "Field.h"
#include<map>
/*
  *每一种参数类型对应一种格式化函数
  *每一种分为头文件/Cpp文件
 */
//格式化整型
static void		_static_format_int_header(Field *field,std::string &result)
{
	result.clear();
	//关于函数的描述
	result.append("/*\n").append(field->getFieldComment()).append("\n");
	result.append("*/\n");
	std::string paramName;
	convertFieldNameToFuncParam(field->getFieldName(), paramName);

	result.append("		void		").append("set").append(field->getFieldName()).append("(int ");
	if (!field->isArray())
		result.append(paramName).append(");\n");
	else
		result.append("*").append(paramName).append(",int size);\n");
}

static void _static_format_int_cpp(Field * field,const std::string &className,std::string  &result)
{
	result.clear();
	result.append("void		").append(className).append("::set").append(field->getFieldName()).append("(int ");
	std::string paramName;
	convertFieldNameToFuncParam(field->getFieldName(),paramName);
	if (!field->isArray())
		result.append(paramName).append(")\n");
	else
		result.append("*").append(paramName).append(",int		size)\n");
	result.append("{\n");
	std::string variableName;
	//获取类成员变量的名字
	convertFieldNameToCppVariable(field->getFieldName(), variableName);
	result.append("		if(").append(variableName).append(">=0)\n");
	if (field->isArray())
		result.append("			glUniform1iv(").append(variableName).append(",").append("size,&").append(paramName).append(")\n");
	else
		result.append("			glUniform1i(").append(variableName).append(",").append(paramName).append(");\n");
	result.append("		}");
	result.append("}\n");
}
//格式化单浮点型
static void		_static_format_float_header(Field *field, std::string &result)
{
	result.clear();
	//关于函数的描述
	result.append("/*\n").append(field->getFieldComment()).append("\n");
	result.append("*/\n");
	std::string paramName;
	convertFieldNameToFuncParam(field->getFieldName(), paramName);

	result.append("		void		").append("set").append(field->getFieldName()).append("(float ");
	if (!field->isArray())
		result.append(paramName).append(");\n");
	else
		result.append("*").append(paramName).append(",int size);\n");
}

static void _static_format_float_cpp(Field * field, const std::string &className, std::string  &result)
{
	result.clear();
	result.append("void		").append(className).append("::set").append(field->getFieldName()).append("(float ");
	std::string paramName;
	convertFieldNameToFuncParam(field->getFieldName(), paramName);
	if (!field->isArray())
		result.append(paramName).append(")\n");
	else
		result.append("*").append(paramName).append(",int		size)\n");
	result.append("{\n");
	std::string variableName;
	//获取类成员变量的名字
	convertFieldNameToCppVariable(field->getFieldName(), variableName);
	result.append("		if(").append(variableName).append(">=0)\n");
	if (field->isArray())
		result.append("			glUniform1fv(").append(variableName).append(",").append("size,&").append(paramName).append(")\n");
	else
		result.append("			glUniform1f(").append(variableName).append(",").append(paramName).append(");\n");
	result.append("		}");
	result.append("}\n");
}
//Vec2类型
static void		_static_format_vec2_header(Field *field, std::string &result)
{
	result.clear();
	//关于函数的描述
	result.append("/*\n").append(field->getFieldComment()).append("\n");
	result.append("*/\n");
	std::string paramName;
	convertFieldNameToFuncParam(field->getFieldName(), paramName);

	result.append("		void		").append("set").append(field->getFieldName()).append("(const glk::GLVector2 ");
	if (!field->isArray())
		result.append("&").append(paramName).append(");\n");
	else
		result.append("*").append(paramName).append(",int size);\n");
}

static void _static_format_vec2_cpp(Field * field, const std::string &className, std::string  &result)
{
	result.clear();
	result.append("void		").append(className).append("::set").append(field->getFieldName()).append("(const glk::GLVector2 ");
	std::string paramName;
	convertFieldNameToFuncParam(field->getFieldName(), paramName);
	if (!field->isArray())
		result.append("&").append(paramName).append(")\n");
	else
		result.append("*").append(paramName).append(",int		size)\n");
	result.append("{\n");
	std::string variableName;
	//获取类成员变量的名字
	convertFieldNameToCppVariable(field->getFieldName(), variableName);
	result.append("		if(").append(variableName).append(">=0)\n");
	if (field->isArray())
		result.append("			glUniform2fv(").append(variableName).append(",").append("size,&").append(paramName).append("->x)\n");
	else
		result.append("			glUniform2fv(").append(variableName).append(",").append("1,&").append(paramName).append(".x);\n");
	result.append("		}");
	result.append("}\n");
}
//Vec3
//Vec2类型
static void		_static_format_vec3_header(Field *field, std::string &result)
{
	result.clear();
	//关于函数的描述
	result.append("/*\n").append(field->getFieldComment()).append("\n");
	result.append("*/\n");
	std::string paramName;
	convertFieldNameToFuncParam(field->getFieldName(), paramName);

	result.append("		void		").append("set").append(field->getFieldName()).append("(const glk::GLVector3 ");
	if (!field->isArray())
		result.append("&").append(paramName).append(");\n");
	else
		result.append("*").append(paramName).append(",int size);\n");
}

static void _static_format_vec3_cpp(Field * field, const std::string &className, std::string  &result)
{
	result.clear();
	result.append("void		").append(className).append("::set").append(field->getFieldName()).append("(const glk::GLVector3 ");
	std::string paramName;
	convertFieldNameToFuncParam(field->getFieldName(), paramName);
	if (!field->isArray())
		result.append("&").append(paramName).append(")\n");
	else
		result.append("*").append(paramName).append(",int		size)\n");
	result.append("{\n");
	std::string variableName;
	//获取类成员变量的名字
	convertFieldNameToCppVariable(field->getFieldName(), variableName);
	result.append("		if(").append(variableName).append(">=0)\n");
	if (field->isArray())
		result.append("			glUniform3fv(").append(variableName).append(",").append("size,&").append(paramName).append("->x)\n");
	else
		result.append("			glUniform3fv(").append(variableName).append(",").append("1,&").append(paramName).append(".x);\n");
	result.append("		}");
	result.append("}\n");
}
//Vec4
static void		_static_format_vec4_header(Field *field, std::string &result)
{
	result.clear();
	//关于函数的描述
	result.append("/*\n").append(field->getFieldComment()).append("\n");
	result.append("*/\n");
	std::string paramName;
	convertFieldNameToFuncParam(field->getFieldName(), paramName);

	result.append("		void		").append("set").append(field->getFieldName()).append("(const glk::GLVector4 ");
	if (!field->isArray())
		result.append("&").append(paramName).append(");\n");
	else
		result.append("*").append(paramName).append(",int size);\n");
}
static void _static_format_vec4_cpp(Field * field, const std::string &className, std::string  &result)
{
	result.clear();
	result.append("void		").append(className).append("::set").append(field->getFieldName()).append("(const glk::GLVector4 ");
	std::string paramName;
	convertFieldNameToFuncParam(field->getFieldName(), paramName);
	if (!field->isArray())
		result.append("&").append(paramName).append(")\n");
	else
		result.append("*").append(paramName).append(",int		size)\n");
	result.append("{\n");
	std::string variableName;
	//获取类成员变量的名字
	convertFieldNameToCppVariable(field->getFieldName(), variableName);
	result.append("		if(").append(variableName).append(">=0)\n");
	if (field->isArray())
		result.append("			glUniform4fv(").append(variableName).append(",").append("size,&").append(paramName).append("->x)\n");
	else
		result.append("			glUniform4fv(").append(variableName).append(",").append("1,&").append(paramName).append(".x);\n");
	result.append("		}");
	result.append("}\n");
}
//Matrix3
static void		_static_format_mat3_header(Field *field, std::string &result)
{
	result.clear();
	//关于函数的描述
	result.append("/*\n").append(field->getFieldComment()).append("\n");
	result.append("*/\n");
	std::string paramName;
	convertFieldNameToFuncParam(field->getFieldName(), paramName);

	result.append("		void		").append("set").append(field->getFieldName()).append("(const glk::Matrix3 ");
	if (!field->isArray())
		result.append("&").append(paramName).append(");\n");
	else
		result.append("*").append(paramName).append(",int size);\n");
}
static void _static_format_mat3_cpp(Field * field, const std::string &className, std::string  &result)
{
	result.clear();
	result.append("void		").append(className).append("::set").append(field->getFieldName()).append("(const glk::Matrix3 ");
	std::string paramName;
	convertFieldNameToFuncParam(field->getFieldName(), paramName);
	if (!field->isArray())
		result.append("&").append(paramName).append(")\n");
	else
		result.append("*").append(paramName).append(",int		size)\n");
	result.append("{\n");
	std::string variableName;
	//获取类成员变量的名字
	convertFieldNameToCppVariable(field->getFieldName(), variableName);
	result.append("		if(").append(variableName).append(">=0)\n");
	if (field->isArray())
		result.append("			glUniformMatrix4fv(").append(variableName).append(",").append("size,&").append(paramName).append("->pointer()\n");
	else
		result.append("			glUniformMatrix4fv(").append(variableName).append(",").append("1,&").append(paramName).append(".pointer();\n");
	result.append("		}");
	result.append("}\n");
}
//Matrix4
static void		_static_format_mat4_header(Field *field, std::string &result)
{
	result.clear();
	//关于函数的描述
	result.append("/*\n").append(field->getFieldComment()).append("\n");
	result.append("*/\n");
	std::string paramName;
	convertFieldNameToFuncParam(field->getFieldName(), paramName);

	result.append("		void		").append("set").append(field->getFieldName()).append("(const glk::Matrix ");
	if (!field->isArray())
		result.append("&").append(paramName).append(");\n");
	else
		result.append("*").append(paramName).append(",int size);\n");
}
static void _static_format_mat4_cpp(Field * field, const std::string &className, std::string  &result)
{
	result.clear();
	result.append("void		").append(className).append("::set").append(field->getFieldName()).append("(const glk::Matrix ");
	std::string paramName;
	convertFieldNameToFuncParam(field->getFieldName(), paramName);
	if (!field->isArray())
		result.append("&").append(paramName).append(")\n");
	else
		result.append("*").append(paramName).append(",int		size)\n");
	result.append("{\n");
	std::string variableName;
	//获取类成员变量的名字
	convertFieldNameToCppVariable(field->getFieldName(), variableName);
	result.append("		if(").append(variableName).append(">=0)\n");
	if (field->isArray())
		result.append("			glUniformMatrix4fv(").append(variableName).append(",").append("size,&").append(paramName).append("->pointer()\n");
	else
		result.append("			glUniformMatrix4fv(").append(variableName).append(",").append("1,&").append(paramName).append(".pointer();\n");
	result.append("		}");
	result.append("}\n");
}
//Sampler2D
static void		_static_format_sampler2D_header(Field *field, std::string &result)
{
	result.clear();
	//关于函数的描述
	result.append("/*\n").append(field->getFieldComment()).append("\n");
	result.append("*/\n");
	std::string paramName;
	convertFieldNameToFuncParam(field->getFieldName(), paramName);

	result.append("		void		").append("set").append(field->getFieldName()).append("(int ");
	result.append(paramName).append("Id").append(",int	unit").append(");\n");
}
static void _static_format_sampler2D_cpp(Field * field, const std::string &className, std::string  &result)
{
	result.clear();
	result.append("void		").append(className).append("::set").append(field->getFieldName()).append("(int ");
	std::string paramName;
	convertFieldNameToFuncParam(field->getFieldName(), paramName);
	result.append(paramName).append("Id").append("int	unit").append(")\n");
	result.append("{\n");
	std::string variableName;
	//获取类成员变量的名字
	convertFieldNameToCppVariable(field->getFieldName(), variableName);
	result.append("		if(").append(variableName).append(">=0)\n");
	result.append("			glActiveTexture(GL_TEXTURE0+unit);");
	result.append("			glBindTexture(GL_TEXTURE_2D,").append(paramName).append("Id);\n");
	//目前采样器数组暂时不支持,再下一个版本中会将这个功能补充
	result.append("			glUniform1i(").append(variableName).append(",").append(paramName).append("Id").append(");\n");
	result.append("		}");
	result.append("}\n");
}
//SamplerCube
static void		_static_format_samplerCube_header(Field *field, std::string &result)
{
	result.clear();
	//关于函数的描述
	result.append("/*\n").append(field->getFieldComment()).append("\n");
	result.append("*/\n");
	std::string paramName;
	convertFieldNameToFuncParam(field->getFieldName(), paramName);

	result.append("		void		").append("set").append(field->getFieldName()).append("(int ");
	result.append(paramName).append("Id").append(",int	unit").append(");\n");
}
static void _static_format_samplerCube_cpp(Field * field, const std::string &className, std::string  &result)
{
	result.clear();
	result.append("void		").append(className).append("::set").append(field->getFieldName()).append("(int ");
	std::string paramName;
	convertFieldNameToFuncParam(field->getFieldName(), paramName);
	if (!field->isArray())
		result.append(paramName).append("Id").append("int	unit").append(")\n");
	else
		result.append("*").append(paramName).append("Id").append(",int		unit,int		size);\n");
	result.append("{\n");
	std::string variableName;
	//获取类成员变量的名字
	convertFieldNameToCppVariable(field->getFieldName(), variableName);
	result.append("		if(").append(variableName).append(">=0)\n");
	result.append("			glActiveTexture(GL_TEXTURE0+unit);");
	result.append("			glBindTexture(GL_TEXTURE_CUBE_MAP,").append(paramName).append("Id);\n");
	//目前采样器数组暂时不支持,再下一个版本中会将这个功能补充
	result.append("			glUniform1i(").append(variableName).append(",").append(paramName).append("Id").append(");\n");
	result.append("		}");
	result.append("}\n");
}
//SamplerShadow
static void		_static_format_samplerShadow_header(Field *field, std::string &result)
{
	result.clear();
	//关于函数的描述
	result.append("/*\n").append(field->getFieldComment()).append("\n");
	result.append("*/\n");
	std::string paramName;
	convertFieldNameToFuncParam(field->getFieldName(), paramName);

	result.append("		void		").append("set").append(field->getFieldName()).append("(int ");
	result.append(paramName).append("Id").append(",int	unit").append(");\n");
}
static void _static_format_samplerShadow_cpp(Field * field, const std::string &className, std::string  &result)
{
	result.clear();
	result.append("void		").append(className).append("::set").append(field->getFieldName()).append("(int ");
	std::string paramName;
	convertFieldNameToFuncParam(field->getFieldName(), paramName);
	result.append(paramName).append("Id").append("int	unit").append(")\n");
	result.append("{\n");
	std::string variableName;
	//获取类成员变量的名字
	convertFieldNameToCppVariable(field->getFieldName(), variableName);
	result.append("		if(").append(variableName).append(">=0)\n");
	result.append("			glActiveTexture(GL_TEXTURE0+unit);");
	result.append("			glBindTexture(GL_TEXTURE_2D,").append(paramName).append("Id);\n");
	//目前采样器数组暂时不支持,再下一个版本中会将这个功能补充
	result.append("			glUniform1i(").append(variableName).append(",").append(paramName).append("Id").append(");\n");
	result.append("		}");
	result.append("}\n");
}
//ShadowArray
static void		_static_format_samplerShadowArray_header(Field *field, std::string &result)
{
	result.clear();
	//关于函数的描述
	result.append("/*\n").append(field->getFieldComment()).append("\n");
	result.append("*/\n");
	std::string paramName;
	convertFieldNameToFuncParam(field->getFieldName(), paramName);

	result.append("		void		").append("set").append(field->getFieldName()).append("(int ");
	if (!field->isArray())
		result.append(paramName).append("Id").append(",int	unit").append(");\n");
	else
		result.append("*").append(paramName).append("Id").append(",int	unit,int	size);\n");
}
static void _static_format_samplerShadowArray_cpp(Field * field, const std::string &className, std::string  &result)
{
	result.clear();
	result.append("void		").append(className).append("::set").append(field->getFieldName()).append("(int ");
	std::string paramName;
	convertFieldNameToFuncParam(field->getFieldName(), paramName);
	if (!field->isArray())
		result.append(paramName).append("Id").append("int	unit").append(")\n");
	else
		result.append("*").append(paramName).append("Id").append(",int		unit,int		size);\n");
	result.append("{\n");
	std::string variableName;
	//获取类成员变量的名字
	convertFieldNameToCppVariable(field->getFieldName(), variableName);
	result.append("		if(").append(variableName).append(">=0)\n");
	result.append("			glActiveTexture(GL_TEXTURE0+unit);");
	result.append("			glBindTexture(GL_TEXTURE_2D_ARRAY,").append(paramName).append("Id);\n");
	//目前采样器数组暂时不支持,再下一个版本中会将这个功能补充
	result.append("			glUniform1i(").append(variableName).append(",").append(paramName).append("Id").append(");\n");
	result.append("		}");
	result.append("}\n");
}
//域格式化函数H文件中
typedef void	(*FieldFormatFuncH)(Field *,std::string &);
//域格式化函数Cpp文件中
typedef void	(*FieldFormatFuncCpp)(Field *,const std::string &,std::string &);
//函数查找表,格式化域名字在H文件中形成的函数
static std::map<VariableType, FieldFormatFuncH>	_static_formatFieldInH = { 
							{ VariableType_Int,_static_format_int_header},
							{ VariableType_Float,_static_format_float_header},
							{ VariableType_Vec2,_static_format_vec2_header},
							{VariableType_Vec3,_static_format_vec3_header},
							{VariableType_Vec4,_static_format_vec4_header},
							{VariableType_Mat3,_static_format_mat3_header},
							{VariableType_Mat4,_static_format_mat4_header},
							{VariableType_Sampler2D,_static_format_sampler2D_header},
							{VariableType_SamplerCube,_static_format_samplerCube_header},
							{VariableType_Shadow,_static_format_samplerShadow_header},
							{VariableType_ShadowArray,_static_format_samplerShadowArray_header},
							};
//函数查找表,格式化域名字在Cpp文件中形成的函数
static std::map<VariableType, FieldFormatFuncCpp> _static_formatFieldInCpp = {
							{ VariableType_Int,_static_format_int_cpp },
							{ VariableType_Float,_static_format_float_cpp },
							{ VariableType_Vec2,_static_format_vec2_cpp },
							{ VariableType_Vec3,_static_format_vec3_cpp },
							{ VariableType_Vec4,_static_format_vec4_cpp },
							{ VariableType_Mat3,_static_format_mat3_cpp },
							{ VariableType_Mat4,_static_format_mat4_cpp },
							{ VariableType_Sampler2D,_static_format_sampler2D_cpp },
							{ VariableType_SamplerCube,_static_format_samplerCube_cpp },
							{ VariableType_Shadow,_static_format_samplerShadow_cpp },
							{ VariableType_ShadowArray,_static_format_samplerShadowArray_cpp },
						};

Field::Field(VariableType variableType, const std::string &fieldName, const std::string &fieldComment):
	_variableType(variableType)
	,_fieldName(fieldName)
	,_fieldComment(_fieldComment)
	,_isArray(false)
{

}

Field::Field(VariableType variableType, const std::string &fieldName):
	_variableType(variableType)
	,_fieldName(fieldName)
{

}

void Field::setFieldComment(const std::string &fieldComment)
{
	_fieldComment = fieldComment;
}

void Field::formatFieldInHeader(std::string &result)
{
	convertFieldNameToCppVariable(this->getFieldName(),result);
}

void Field::formatFuncInHeader(std::string &result)
{
	_static_formatFieldInH[_variableType](this,result);
}

void Field::formatFuncInCpp(const std::string &className,std::string &result)
{
	_static_formatFieldInCpp[_variableType](this, className,result);
}