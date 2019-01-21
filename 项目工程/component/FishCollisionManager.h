/*
  *2d捕鱼碰撞检测实现
  *2017年12月28日
  *@author:xiaoxiong
 */
#ifndef __FISH_COLLISION_MANAGER_H__
#define __FISH_COLLISION_MANAGER_H__
#include "cocos2d.h"
 //用户数据中相应位置的数据的用途
#define _FISH2D_USER_DATA_POSITION_COS_                        0
#define _FISH2D_USER_DATA_POSITION_SIN_                         1
#define _FISH2D_USER_DATA_POSITION_OFFSET_X_           2
#define _FISH2D_USER_DATA_POSITION_OFFSET_Y_           3
#define _FISH2D_USER_DATA_POSITION_COUNT_                 4
//从_FISH2D_USER_DATA_POSITION_COUNT_位置开始,以后的四个可以根据自己的需要而自由设置
#define NS_FISH2D_BEGIN   namespace fish2d{
#define NS_FISH2D_END        }
//区间划分
#define SPACE_STEP_X   7
#define SPACE_STEP_Y   5
/*
  *关于碰撞检测中的碰撞区域对象
 */
NS_FISH2D_BEGIN
//实体类型
enum  EntityType
{
	EntityType_Fish = 1,//鱼
	EntityType_Bullet = 2,//子弹
};
//碰撞掩码
enum CollisionMask
{
	CollisionMask_Invalide   = 0,//无效的掩码
	CollisionMask_Enabled   = 1,//碰撞被启用,此标志暂时没有使用
	CollisionMask_Removed = 4,//碰撞实体将要从队列中被删除
	CollisionMask_Destroy   = 8,//碰撞实体将要从队列中销毁
	CollisionMask_Away       = 16,//对象已经脱离了队列
	CollisionMask_Target     =32,//碰撞检测的时候指定了目标
};
//碰撞包围盒
struct Boundingbox
{
	float						catchRadius;//捕获半径
	cocos2d::Vec2		offsetCenter;//包围盒的偏移中心
};
//碰撞区域
struct CollisionArea
{
	int												id;//碰撞对象的唯一标识符
	std::vector<Boundingbox>   	    boundingBoxVec;//包围盒序列
};
class CollisionManager;
//最终待参与碰撞计算的对象
class CollisionEntity
{
	friend   class CollisionManager;
	//碰撞对象的主体
	cocos2d::Node    *_mainEntity;
	//
	EntityType   _entityType;
	int                  _entityId;
	//关于碰撞属性的掩码,目前暂时没有使用
	int       _mask;
	//对于子弹来说,这个值标志着所定时的目标id,鱼的恒为0
	int       _target;
	//
	//碰撞是否已经启用了
	bool    _enabled;
	//碰撞对象持有的碰撞区域,此区域将会从CollisionManager中查找获得
	CollisionArea   *_collisionArea;
	//最大捕获半径
	float                      _maxRadius;
	//提供给Node使用
	float                      _userData[8];
private:
	CollisionEntity(EntityType entityType,int id,cocos2d::Node *mainEntity,CollisionArea *collisionArea);
	CollisionEntity(const CollisionEntity &);
public:
	static CollisionEntity *create(EntityType entityType,int id, cocos2d::Node *mainEntity, CollisionArea *collisionArea);
	//设置碰撞的主体
	//inline void   setEntity(cocos2d::Node *entity) { _mainEntity = entity; };
	inline EntityType getType()const { return _entityType; };
	//启用碰撞实体
	inline void   setEnabled(bool b) { _enabled = b; };
	inline bool   isEnabled()const { return _enabled; };
	inline void   setMaxRadius(float r) { _maxRadius = r; };
	inline void   setTarget(int target) { _target = target; };
	inline void   setEntityId(int id) { _entityId = id; };
	//inline void   setCollisionArea(CollisionArea *collisionArea) { _collisionArea = collisionArea; };
	inline const CollisionArea *getCollisionArea()const { return _collisionArea; };
};
//碰撞管理器
class CollisionManager
{
	//所有碰撞对象的集合
	std::unordered_map<int, CollisionArea>    _collisionMap;
	//最大捕获半径映射集合,数据将会使用上面的map导出
	std::unordered_map<int, float>                       _maxCatchMap;
	//当前参与计算的鱼碰撞管理对象
	std::list<CollisionEntity *>                                 _collisionFishList;
	//记录待删除的碰撞管理对象
	//std::list<CollisionEntity *>                                 _removedFishList;
	//当前参与计算的子弹的碰撞对象
	std::list<CollisionEntity*>                                 _collisionBulletList;
	//当前待删除的子弹的碰撞对象                        
	//std::list<CollisionEntity*>                                 _removedBulletList;
	//待释放的碰撞实体对象
	//std::list<CollisionEntity*>                                 _releasedEntityList;
	int                                                                             _luaScriptFunc;//lua回调函数
	//屏幕空间划分,将屏幕划分为 6x4
	std::vector<CollisionEntity*>                            _spacePartionFish[SPACE_STEP_X][SPACE_STEP_Y];
	std::vector<CollisionEntity*>                            _spacePartionBullet[SPACE_STEP_X][SPACE_STEP_Y];
	float                                                                          _xStepSpace,_yStepSpace;
	//lua_State
	lua_State                                                                 *_luaState;
private:
	CollisionManager();
	CollisionManager(const CollisionManager&);
public:
	~CollisionManager();
	static CollisionManager *getInstance();
	//设置屏幕分辨率
	static void setScreenSize(float width,float height);
	//注册lua回调函数
	inline void    registerLuaScriptFunc(int luaScriptHandler) { _luaScriptFunc = luaScriptHandler; };
	//向碰撞管理器中注册碰撞区域对象
	void    registerCollisionArea(int id,const std::vector<Boundingbox> &boundingBoxVec);
	//向碰撞管理器申请碰撞区域对象
	CollisionArea   *requireCollisionArea(int id);
	//将自身添加到鱼的碰撞列表中
	void    pushFishEntity(CollisionEntity	*entity);
	//将自身添加到子弹实体列表中
	void    pushBulletEntity(CollisionEntity  *entity);
	//添加到碰撞列表中
	void    pushEntity(CollisionEntity *entity);
	//将自身添加到待删除的鱼的列表中,只是从列表中删除,但是并不会释放
	void    removeFishEntity(CollisionEntity *entity);
	void    removeBulletEntity(CollisionEntity *entity);
	//
	void    removeEntity(CollisionEntity *entity);
	//清理所有的无效的碰撞实体
	void    removeAllInValideEntity(int cleanFlag);
	//释放碰撞实体对象
	void    releaseCollisionEntity(CollisionEntity *entity);
	//计算碰撞
	void    onUpdate(float dt);
	//计算目标子弹和目标鱼是否发生了碰撞
	//bool    checkCollision(CollisionEntity *bullet,CollisionEntity *fish);
	//计算碰撞,使用网格划分
	void    onUpdateSpacePartion(float dt);
	//屏幕空间划分
	void    spacePartion();
	//检测某个划分区间的碰撞
	void    checkSpaceCollision(std::vector<CollisionEntity*> &fishEntityVec,std::vector<CollisionEntity*> &bulletEntityVec);
};
NS_FISH2D_END;
#endif