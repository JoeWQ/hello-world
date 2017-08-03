/*
  *公共数据结构
  *2017-06-22
  *@author:xiaohuaxiong
 */
#ifndef __COMMON_H__
#define __COMMON_H__
#include<vector>
#include<string>
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
//关于一个鱼的所有数据集合
struct FishVisual
{
	int              id;//fish id
	float           scale;//鱼的缩放比例
	std::string name;//关于鱼的名字
	float          from;//鱼3d动画的起始帧
	float          to;//3d动画的结束帧
};

extern const char *_static_bessel_Vertex_Shader;
extern const char *_static_bessel_Frag_Shader;

extern const char *_static_spiral_Vertex_Shader;
extern const char *_static_spiral_Frag_Shader;

extern const int     _static_bessel_node_max_count;//贝赛尔曲线所能允许的最大节点数

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
#endif