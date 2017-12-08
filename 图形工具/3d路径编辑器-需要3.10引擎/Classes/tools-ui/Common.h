/*
  *�������ݽṹ
  *2017-06-22
  *@author:xiaohuaxiong
 */
#ifndef __COMMON_H__
#define __COMMON_H__
#include<vector>
#include<string>
#include<map>
 /*
 *�������·���ľ���Ĺ������ݽṹ
 */
struct FishPathMap
{
	std::vector<int>        	  fishPathSet;
};
//ʹ��һ��������ַ���������������·��
struct FishIdMap
{
	std::vector<int>          fishIdSet;
};
//3dģ�Ͷ�����Ϣ
struct AnimationFrameInfo
{
	int   startFrame;//��ʼ֡
	int   endFrame;//����֡
	AnimationFrameInfo(int astartFrame,int aendFrame)
	{
		startFrame = astartFrame;
		endFrame = aendFrame;
	}
	AnimationFrameInfo()
	{
		startFrame = 0;
		endFrame = 0;
	}
};
//����һ������������ݼ���
struct FishVisual
{
	int														id;//fish id
	float														scale;//������ű���
	std::string											name;//��������ļ�·��
	std::string											label;//�����ʾ����
	std::vector<AnimationFrameInfo> fishAniVec;//ģ�͵Ķ�������,������һ������
};

extern const char *_static_bessel_Vertex_Shader;
extern const char *_static_bessel_Frag_Shader;

extern const char *_static_spiral_Vertex_Shader;
extern const char *_static_spiral_Frag_Shader;

extern const int     _static_bessel_node_max_count;//����������������������ڵ���
//һ�����͵�Shader
#define _SHADER_TYPE_COMMON_    "_shader_type_common_"
//��������ģ�ͱ任�����shader
#define _SHADER_TYPE_MODEL_       "_shader_type_model_"
enum CurveType//���ߵ�����
{
	CurveType_Line = 0,//ֱ��
	CurveType_Bessel = 1,//����������
	CurveType_Circle = 2,//Բ
	CurveType_Delay = 3,//�ӳ�����
	CurveType_Spiral = 4,//������������
};
//�����������ߵĸ�������������
enum SpiralValueType
{
	SpiralValueType_BottomRadius=0,//�ϰ뾶
	SpiralValueType_TopRadius=1,//�ϰ뾶
};
//�����ķ����������в����Ĵʷ���Ԫ����
enum SyntaxType
{
	SyntaxType_None=0,//�Ƿ��Ĵʷ���Ԫ
	SyntaxType_Number = 1,//����
	SyntaxType_LeftBracket =2,//���������
	SyntaxType_RightBracket=3,//�Ҳ�������
	SyntaxType_Minus =4,//����
	SyntaxType_Comma = 5,//����
};
///////////////////////////////��������/////////////////////
/*
  *���vector���Ƿ���Ŀ������
 */
bool checkVector(const std::vector<int> &someVector, int value);
/*
  *���vector���Ƿ���Ŀ������,����еĻ��滻����һ��ֵ
 */
bool checkVector(std::vector<int> &someVector,int tgarget,int targetValue);
/*
  *���vector���Ƿ���Ŀ��Ԫ��,����еĻ�ɾ����Ԫ��
 */
bool removeVector(std::vector<int> &someVector, int tgarget);
/*
  *�ַ�����������
 */
float strtof(const char *str);
/*
  *�ʷ���Ԫ������
 */
struct Token
{
	std::string     syntax;
	SyntaxType   syntaxType;
	Token(const std::string &asyntax, SyntaxType asyntaxType)
	{
		syntax = asyntax;
		syntaxType = asyntaxType;
	}
	Token()
	{

	}
};
class SyntaxParser
{
	std::string                                   _text;
	int                                                _index;
	std::map<std::string, Token>   _reservedSyntax;//������
public:
	SyntaxParser(const std::string &syntax);
	//������һ���ʷ���Ԫ
	void  getToken(Token &);
};
#endif