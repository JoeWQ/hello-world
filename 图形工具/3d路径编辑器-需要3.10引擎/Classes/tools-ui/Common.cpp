/*
  *公共函数,数据
  @2017-07-12
  @Author:xiaoxiong
 */
 //OpenGL Shader
#include "Common.h"

const  int _static_bessel_node_max_count = 27;

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
////////////////////////////////////////////////
SyntaxParser::SyntaxParser(const std::string &text)
{
	_text = text;
	_index = 0;
	//添加保留字
	_reservedSyntax["["] = Token("[",SyntaxType::SyntaxType_LeftBracket);
	_reservedSyntax["]"] = Token("]",SyntaxType::SyntaxType_RightBracket);
	_reservedSyntax[","] = Token(",",SyntaxType::SyntaxType_Comma);
	_reservedSyntax["-"] = Token("-",SyntaxType::SyntaxType_Minus);
}

void  SyntaxParser::getToken(Token &token)
{
	//过滤空白符
	while (_index<_text.size() && (_text[_index] == ' ' || _text[_index] == '\t'))
		_index = _index + 1;
	token.syntaxType = SyntaxType::SyntaxType_None;
	do
	{
		if (_index >= _text.size())
			break;
		std::string key;
		char w = _text[_index];
		if (w >= '0' && w <= '9')
		{
			do
			{
				key.append(&w, 1);
				_index = _index + 1;
			} while (_index < _text.size() && _text[_index] >= '0' && _text[_index] <= '9');
			token.syntaxType = SyntaxType::SyntaxType_Number;
			token.syntax = key;
			break;
		}
		key.append(&w, 1);
		//保留字都是单字符,可以不用再接着判断了
		if (_reservedSyntax.find(key) != _reservedSyntax.end())
		{
			Token &ctoken = _reservedSyntax[key];
			token.syntax = ctoken.syntax;
			token.syntaxType = ctoken.syntaxType;
			_index = _index + 1;
		}
	} while (0);
}