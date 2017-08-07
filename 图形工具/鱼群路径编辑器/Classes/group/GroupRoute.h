/*
  *����Ⱥ���˶��ĸ���
  *���漯��������������Ҫʵ�ֵĺ���
  *@2017-8-4
  *@Author:xiaohuaxiong
 */
#ifndef __GROUP_ROUTE_H__
#define __GROUP_ROUTE_H__
#include "cocos2d.h"
#include "common/common.h"
/*
  *Ⱥ���˶�����������
 */
class GroupData
{
	GroupType								 _groupType;
	std::vector<cocos2d::Vec4> _groupPoint;
public:
	GroupData(GroupType groupType);
	//����������ݸ�ʽ��
	void     format(std::string &output);
};
class GroupRoute :public cocos2d::Node
{
protected:
	//���ߵ�����
	GroupType           _groupType;
	//�����ṩһ��Layer,��Layer�������������߶����
	cocos2d::Layer   *_controlLayer;
	//�ڵ��3d��ת����ת����,Ҳ����ֱ��ͨ��ŷ���Ǽ���,Ҳ����ֱ�ӻ�ȡ
	cocos2d::Mat4           _rotateMatrix;
	//�ص�����,�˺������Ե����Ի���
	std::function<void(GroupType groupType, int param, const cocos2d::Vec3   &xyz, std::function<void(const FishInfo &)> onConfirmCallback)> _chooseDialogUICallback;
	//�ϲ�UI����Ĳ�ѯ����,��ѯ���FishId
	std::function<const FishInfo & (int fishId)>         _queryFishCallback;
protected:
	GroupRoute(GroupType groupType);
public:
	GroupType   getType()const { return _groupType; };
	/*
	  *�ϲ�Ļص�����,�����������¼���Ctrl�������µ�ʱ�����
	 */
	virtual  bool  onTouchBegan(const cocos2d::Vec2 &touchPoint,cocos2d::Camera *camera);
	virtual  void  onTouchMoved(const cocos2d::Vec2 &touchPoint, cocos2d::Camera *camera);
	virtual  void  onTouchEnded(const cocos2d::Vec2 &touchPoint, cocos2d::Camera *camera);
	/*
	  *�������Ҽ���ʱ��ص�����
	 */
	virtual  void  onMouseClick(const cocos2d::Vec2 &clickPoint,cocos2d::Camera *camera);
	virtual  void  onMouseMoved(const cocos2d::Vec2 &clickPoint,cocos2d::Camera *camera);
	virtual  void  onMouseEnded(const cocos2d::Vec2 &clickPoint,cocos2d::Camera *camera);
	//��������,����ά����ת����2d��Ļ����,�������˶�������
	void      project2d(cocos2d::Camera *camera,const cocos2d::Vec3 &src3D,cocos2d::Vec3 &dst3d);
	//��������2ά����ת�����ϲ��UI����
	cocos2d::Vec2    convertUICoord(const cocos2d::Vec2 &src);
	//�ṩһ�������������ߵ�Layer,����Layer�Ĵ�С�������,�ϲ�UI��Ҫ�õ������������Layer������
	cocos2d::Layer *getControlLayer();
	//�������л�ȡ����,�����������������ļ���
	void      getGroupData(GroupData &output);
	/*
	  *������ת����
	 */
	void     setRotateMatrix(const cocos2d::Mat4 &rm);
	/*
	  *����ע�ắ��,�˺�������Ҫ�������,ֻ�п�ܱ���ʹ��
	 */
	void    registerChooseDialogUICallback(std::function<void(GroupType groupType, int param, const cocos2d::Vec3   &xyz, std::function<void(const FishInfo &)> onConfirmCallback)> callback);
	/*
	  *�������fishId����ѯ�͸�fishId�������Ϣ
	 */
	const FishInfo &queryFishInfo(int fishId)const;
	/*
	  *�˺�����Ӧ�������е���,ֻ���������ʹ��
	 */
	void   registerQueryFishInfoCallback(std::function<const FishInfo & (int fishId)> callback);
};
///////////////////////////////////���Ƶ�///////////////////////////////
class ControlPoint :public cocos2d::Node
{
private:
	//3dģ��,Ϊ�˷�����3d�ռ��ж�Զ��������ֱ�۵��Ӿ�����
	cocos2d::Sprite3D    *_modelSprite;
	//�ڵ��˳��,���������߽ڵ��˳��ͬ������γɵ�����·��Ҳ��ͬ
	cocos2d::Label          *_sequence;
	//ͼ��
	cocos2d::Sprite         *_iconSprite;
	//�ڿ��Ƶ��ϻ���������
	//cocos2d::DrawNode3D *_drawNode3D;
	int                                _index;
private:
	ControlPoint();
	void      initControlPoint(int index);
public:
	~ControlPoint();
	static ControlPoint   *createControlPoint(int index);
	/*
	*�޸Ŀ��Ƶ�Ĵ���
	*/
	void   changeSequence(int index);
	/*
	*��Ҫ�ֹ������ú���
	*/
	void     drawAxis();//��������

	float _speedCoef;
};
#endif