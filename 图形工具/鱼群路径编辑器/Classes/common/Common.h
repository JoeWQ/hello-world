/*
  *公共数据结构/函数
  *@2017-8-4
  *@Author:xiaohuaxiong
 */
#ifndef __COMMON_H__
#define __COMMON_H__
/*
  *群体运动的类型
 */
enum GroupType
{
	GroupTYpe_None=0,//无效的类型
	GroupType_Rolling = 1,//翻滚(绕某一些个旋转轴旋转)
};
//关于鱼的信息
struct FishInfo
{
	int				fishId;//鱼的Id
	float				scale;//鱼的缩放比例
	std::string   name;//鱼模型的名字
	int               startFrame;//动画的起始帧
	int               endFrame;//动画的结束帧
};
//Shader,此中不包含自变换矩阵
extern const char *_static_common_vertex_shader;
extern const char *_static_common_frag_shader;
//Shader包含了自变换矩阵
extern const char *_static_common_model_vertex_shader;
extern const char *_static_common_model_frag_shader;

 //求x的符号
#define _signfloat(x) (((x>0)<<1)-1)
//
#define CC_CALLBACK_4(__selector__,__target__, ...) std::bind(&__selector__,__target__, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3, std::placeholders::_4,##__VA_ARGS__)
#endif