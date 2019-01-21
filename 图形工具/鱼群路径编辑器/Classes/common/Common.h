/*
  *�������ݽṹ/����
  *@2017-8-4
  *@Author:xiaohuaxiong
 */
#ifndef __COMMON_H__
#define __COMMON_H__
/*
  *Ⱥ���˶�������
 */
enum GroupType
{
	GroupTYpe_None=0,//��Ч������
	GroupType_Rolling = 1,//����(��ĳһЩ����ת����ת)
};
//���������Ϣ
struct FishInfo
{
	int				fishId;//���Id
	float				scale;//������ű���
	std::string   name;//��ģ�͵�����
	int               startFrame;//��������ʼ֡
	int               endFrame;//�����Ľ���֡
};
//Shader,���в������Ա任����
extern const char *_static_common_vertex_shader;
extern const char *_static_common_frag_shader;
//Shader�������Ա任����
extern const char *_static_common_model_vertex_shader;
extern const char *_static_common_model_frag_shader;

 //��x�ķ���
#define _signfloat(x) (((x>0)<<1)-1)
//
#define CC_CALLBACK_4(__selector__,__target__, ...) std::bind(&__selector__,__target__, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3, std::placeholders::_4,##__VA_ARGS__)
#endif