/*
  *公共函数,数据
  @2017-07-12
  @Author:xiaoxiong
 */
 //OpenGL Shader
#include "Common.h"
const char *_static_bessel_Vertex_Shader = "attribute vec4 a_position;"
"void main()"
"{"
"		gl_Position  = CC_MVPMatrix  * a_position;"
"}";
const char *_static_bessel_Frag_Shader = "uniform vec4 u_color;"
"void main()"
"{"
"		gl_FragColor = u_color;"
"}";
//////////////////////////
const char *_static_spiral_Vertex_Shader = "attribute vec4 a_position;"
"uniform mat4 u_modelMatrix;"
"void main()"
"{"
"		gl_Position  = CC_MVPMatrix * u_modelMatrix * a_position;"
"}";
const char *_static_spiral_Frag_Shader = "uniform vec4 u_color;"
"void main()"
"{"
"		gl_FragColor = u_color;"
"}";;
//
////////////////Common function///////////////////////
bool checkVector(const std::vector<int> &someVector, int value)
{
	std::vector<int>::const_iterator it = someVector.cbegin();
	for (; it != someVector.cend(); ++it)
	{
		if (*it == value)
			return true;
	}
	return false;
}

bool checkVector(std::vector<int> &someVector, int target, int targetValue)
{
	std::vector<int>::iterator it = someVector.begin();
	for (; it != someVector.end(); ++it)
	{
		if (*it == target)
		{
			*it = targetValue;
			return true;
		}
	}
	return false;
}

bool removeVector(std::vector<int> &someVector, int target)
{
	std::vector<int>::iterator it = someVector.begin();
	for (; it != someVector.end(); ++it)
	{
		if (*it == target)
		{
			someVector.erase(it);
			return true;
		}
	}
	return false;
}

float strtof(const char *str)
{
	float value = 0;
	float fract = 10.0f;
	while (*str && *str != '.')
	{
		value = 10.0f *value + (*str - '0');
		++str;
	}
	if (*str == '.')
	{
		++str;
		while (*str)
		{
			value += (*str - '0')/fract;
			++str;
			fract *= 10.0f;
		}
	}
	return value;
}