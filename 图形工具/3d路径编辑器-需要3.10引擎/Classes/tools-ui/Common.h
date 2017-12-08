/*
  *公共数据结构
  *2017-06-22
  *@author:xiaohuaxiong
 */
#ifndef __COMMON_H__
#define __COMMON_H__
#include<vector>
#include<string>
#include<map>
 /*
 *关于鱼和路径的具体的关联数据结构
 */
struct FishPathMap
{
	std::vector<int>        	  fishPathSet;
};
//使用一个鱼的名字反向查找与其关联的路径
struct FishIdMap
{
	std::vector<int>          fishIdSet;
};
//3d模型动画信息
struct AnimationFrameInfo
{
	int   startFrame;//起始帧
	int   endFrame;//结束帧
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
//关于一个鱼的所有数据集合
struct FishVisual
{
	int														id;//fish id
	float														scale;//鱼的缩放比例
	std::string											name;//关于鱼的文件路径
	std::string											label;//鱼的显示名字
	std::vector<AnimationFrameInfo> fishAniVec;//模型的动画集合,至少有一个动画
};

extern const char *_static_bessel_Vertex_Shader;
extern const char *_static_bessel_Frag_Shader;

extern const char *_static_spiral_Vertex_Shader;
extern const char *_static_spiral_Frag_Shader;

extern const int     _static_bessel_node_max_count;//贝赛尔曲线所能允许的最大节点数
//一般类型的Shader
#define _SHADER_TYPE_COMMON_    "_shader_type_common_"
//带有自身模型变换矩阵的shader
#define _SHADER_TYPE_MODEL_       "_shader_type_model_"
enum CurveType//曲线的类型
{
	CurveType_Line = 0,//直线
	CurveType_Bessel = 1,//贝塞尔曲线
	CurveType_Circle = 2,//圆
	CurveType_Delay = 3,//延迟曲线
	CurveType_Spiral = 4,//螺旋曲线类型
};
//关于螺旋曲线的各个参数的类型
enum SpiralValueType
{
	SpiralValueType_BottomRadius=0,//上半径
	SpiralValueType_TopRadius=1,//上半径
};
//关于文法解析过程中产生的词法单元类型
enum SyntaxType
{
	SyntaxType_None=0,//非法的词法单元
	SyntaxType_Number = 1,//数字
	SyntaxType_LeftBracket =2,//左侧中括号
	SyntaxType_RightBracket=3,//右侧中括号
	SyntaxType_Minus =4,//减号
	SyntaxType_Comma = 5,//逗号
};
///////////////////////////////公共函数/////////////////////
/*
  *检测vector中是否有目标数据
 */
bool checkVector(const std::vector<int> &someVector, int value);
/*
  *检测vector中是否有目标数据,如果有的话替换成另一个值
 */
bool checkVector(std::vector<int> &someVector,int tgarget,int targetValue);
/*
  *检测vector中是否有目标元素,如果有的话删除该元素
 */
bool removeVector(std::vector<int> &someVector, int tgarget);
/*
  *字符串到浮点数
 */
float strtof(const char *str);
/*
  *词法单元解析类
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
	std::map<std::string, Token>   _reservedSyntax;//保留字
public:
	SyntaxParser(const std::string &syntax);
	//返回下一个词法单元
	void  getToken(Token &);
};
#endif