/*
  *�������ݽṹ
  *2017-06-22
  *@author:xiaohuaxiong
 */
#ifndef __COMMON_H__
#define __COMMON_H__
#include<vector>
#include<string>
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
//����һ������������ݼ���
struct FishVisual
{
	int              id;//fish id
	float           scale;//������ű���
	std::string name;//�����������
	float          from;//��3d��������ʼ֡
	float          to;//3d�����Ľ���֡
};

extern const char *_static_bessel_Vertex_Shader;
extern const char *_static_bessel_Frag_Shader;

extern const char *_static_spiral_Vertex_Shader;
extern const char *_static_spiral_Frag_Shader;

extern const int     _static_bessel_node_max_count;//����������������������ڵ���

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
#endif