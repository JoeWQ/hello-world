/*
  *2d碰撞检测实现
  *2017年12月28日
  *@author:xiaoxiong
 */
#include "FishCollisionManager.h"
#include "scripting/lua-bindings/manual/CCLuaEngine.h"
USING_NS_CC;
NS_FISH2D_BEGIN
static CollisionManager *static_collisionManager = nullptr;
static float static_collision_width = 1334;
static float static_collision_height = 750;
////////////////////////CollisionEntity////////////////////
CollisionEntity::CollisionEntity(EntityType entityType,int id, cocos2d::Node *mainEntity, CollisionArea *collisionArea):
	_entityType(entityType)
	,_mainEntity(mainEntity)
	,_entityId(id)
	,_mask(0)
	, _target(0)
	,_enabled(false)
	,_collisionArea(collisionArea)
	,_maxRadius(0)
{
	//将对象内部的数据与Node绑定到一起,这样就不用再为管理额外的内存而编写代码
	mainEntity->setUserData(_userData);
}
CollisionEntity *CollisionEntity::create(EntityType entityType, int id,cocos2d::Node *mainEntity, CollisionArea *collisionArea)
{

	CollisionEntity *entity = new CollisionEntity(entityType,id,mainEntity,collisionArea);
	return entity;
}
///////////////////////CollisionManager////////////////////////
CollisionManager::CollisionManager():
	_luaScriptFunc(0)
	,_xStepSpace(static_collision_width / SPACE_STEP_X)
	,_yStepSpace(static_collision_height/ SPACE_STEP_Y)
{
	static_collisionManager = this;
	//保留区间
	for (int i = 0; i < SPACE_STEP_X; ++i)
		for (int k = 0; k < SPACE_STEP_Y; ++k)
		{
			_spacePartionFish[i][k].reserve(64);
			_spacePartionBullet[i][k].reserve(16);
		}
	_luaState = LuaEngine::getInstance()->getLuaStack()->getLuaState();
}
CollisionManager::~CollisionManager()
{
	for (auto it = _collisionFishList.begin(); it != _collisionFishList.end(); ++it)
		delete *it;
	_collisionFishList.clear();
	//
	for (auto it = _collisionBulletList.begin(); it != _collisionBulletList.end(); ++it)
		delete *it;
	_collisionBulletList.clear();
	if (_luaScriptFunc != 0)
		LuaEngine::getInstance()->removeScriptHandler(_luaScriptFunc);
	_luaScriptFunc = 0;
	static_collisionManager = nullptr;
}

CollisionManager *CollisionManager::getInstance()
{
	if (!static_collisionManager)
		static_collisionManager=new CollisionManager();
	return static_collisionManager;
}

void CollisionManager::setScreenSize(float width, float height)
{
	static_collision_width = width;
	static_collision_height = height;
}

void CollisionManager::registerCollisionArea(int id, const std::vector<Boundingbox> &boundingBoxVec)
{
	auto it =_collisionMap.find(id);
	CCASSERT(it ==_collisionMap.end(),"Repeated Collision Area " );
	CollisionArea  collisionArea;
	collisionArea.id = id;
	collisionArea.boundingBoxVec = boundingBoxVec;
	_collisionMap[id] = collisionArea;
	//计算最大半径
	float radius = 0;
	for (auto &boundingbox : boundingBoxVec)
	{
		float r = boundingbox.offsetCenter.length() + boundingbox.catchRadius;
		if (r > radius)
			radius = r;
	}
	_maxCatchMap[id] = radius;
}

CollisionArea *CollisionManager::requireCollisionArea(int id)
{
	auto it = _collisionMap.find(id);
	CCASSERT(it != _collisionMap.end(),"Could not find CollsionArea.");
	return &it->second;
}

void CollisionManager::pushFishEntity(CollisionEntity *entity)
{
	CCASSERT(entity->_entityType == EntityType::EntityType_Fish,"Could not add bullet to fish collision set.");
	//检测以下是否出现了重复
	//auto it = std::find(_collisionFishList.begin(), _collisionFishList.end(),entity);
	//char buffer[256];
	//sprintf(buffer, "Could not push same fish CollisionEntity in two times..%s", entity->_mask & CollisionMask::CollisionMask_Removed?"but it is put removed flag":"but it is normal.");
	//CCASSERT(it== _collisionFishList.end(), buffer);
	//如果时新创建的/或者从回收而来但是却已经离开了队列
	if(!(entity->_mask & CollisionMask::CollisionMask_Removed)||(entity->_mask & CollisionMask::CollisionMask_Away))
		_collisionFishList.push_back(entity);
	//检测是否有重复的
#if CC_TARGET_PLATFORM!= CC_PLATFORM_ANDROID &&  COCOS2D_DEBUG >= 1
	int count = 0;
	for (CollisionEntity *otherEntity : _collisionFishList)
	{
		if (entity == otherEntity)
			++count;
	}
	CCASSERT(count==1,"Put repeat Fish into same Collision Queue.");
#endif
	entity->_enabled = true;
}

void CollisionManager::pushBulletEntity(CollisionEntity *entity)
{
	CCASSERT(entity->_entityType ==EntityType::EntityType_Bullet,"Could not add fish to bullet collision set.");
	//auto it = std::find(_collisionBulletList.begin(),_collisionBulletList.end(),entity);
	//char buffer[256];
	//sprintf(buffer, "Could not push same fish CollisionEntity in two times..%s", entity->_mask & CollisionMask::CollisionMask_Removed ? "but it is put removed flag" : "but it is normal.");
	//CCASSERT(it == _collisionBulletList.end(), buffer);
	//对于待进入碰撞队列的子弹来说,有两种可能的来源,新创建的,从旧的资源里面回收的.
	//如果是回收的,需要重新做上标志
	if (!(entity->_mask & CollisionMask::CollisionMask_Removed) || (entity->_mask & CollisionMask::CollisionMask_Away))
		_collisionBulletList.push_back(entity);
#if CC_TARGET_PLATFORM!= CC_PLATFORM_ANDROID && COCOS2D_DEBUG >= 1
	int count = 0;
	for (CollisionEntity *otherEntity : _collisionBulletList)
	{
		if (entity == otherEntity)
			++count;
	}
	CCASSERT(count==1,"Could not put bullet into same Collision Queue.");
#endif
	entity->_enabled = true;
}

void CollisionManager::pushEntity(CollisionEntity *entity)
{
	if (entity->_entityType == EntityType::EntityType_Fish)
		pushFishEntity(entity);
	else
		pushBulletEntity(entity);
	//重置掩码,因为对象可能会被复用
	entity->_mask = 0;
	//将最大捕获范围写入放到数据中
	entity->_maxRadius = _maxCatchMap[entity->_collisionArea->id];
}

void CollisionManager::removeBulletEntity(CollisionEntity *entity)
{
	CCASSERT(entity->_entityType == EntityType::EntityType_Bullet, "Could not remove fish from bullet set.");
	//auto it = std::find(_removedBulletList.begin(), _removedBulletList.end(), entity);
	//if (it == _removedBulletList.end())
	//	_removedBulletList.push_back(entity);
	//_collisionBulletList.remove(entity);
	//entity->_enabled = false;
	//entity->_mask |= CollisionMask::CollisionMask_Away;
}

void CollisionManager::removeFishEntity(CollisionEntity *entity)
{
	CCASSERT(entity->_entityType == EntityType::EntityType_Fish, "Could not remove bullet from fish set.");
	//auto it = std::find(_removedFishList.begin(), _removedFishList.end(), entity);
	//if (it == _removedFishList.end())
	//	_removedFishList.push_back(entity);
	//_collisionFishList.remove(entity);
	//entity->_enabled = false;
	//entity->_mask |= CollisionMask::CollisionMask_Away;
}

void CollisionManager::removeEntity(CollisionEntity *entity)
{
	//if (entity->_entityType == EntityType::EntityType_Fish)
	//	removeFishEntity(entity);
	//else
	//	removeBulletEntity(entity);
	//做上标记,禁止碰撞检测,并且从队列中移除掉
	entity->_enabled = false;
	entity->_mask |= CollisionMask::CollisionMask_Removed;
}

void CollisionManager::releaseCollisionEntity(CollisionEntity *entity)
{
	//碰撞对象必须先被标记为不可用,
	//auto it = std::find(_releasedEntityList.begin(),_releasedEntityList.end(),entity);
	//if(it == _releasedEntityList.end())
	//	_releasedEntityList.push_back(entity);
	entity->_enabled = false;
	entity->_mask |= CollisionMask::CollisionMask_Destroy | CollisionMask::CollisionMask_Removed;
	//判断,对象是否已经离开了队列,则直接删除
	if (entity->_mask & CollisionMask::CollisionMask_Away)
		delete entity;
}
//清理所有的被移除的碰撞实体
void CollisionManager::removeAllInValideEntity(int cleanFlag)
{
	if (cleanFlag & EntityType::EntityType_Fish)
	{
		for (auto it = _collisionFishList.begin(); it != _collisionFishList.end(); )
		{
			CollisionEntity *entity = *it;
			if (entity->_mask & CollisionMask::CollisionMask_Removed)
				it = _collisionFishList.erase(it);
			else
				++it;
		}
	}
	//
	if (cleanFlag & EntityType::EntityType_Bullet)
	{
		for (auto it = _collisionBulletList.begin(); it != _collisionBulletList.end(); )
		{
			if ((*it)->_mask & CollisionMask::CollisionMask_Removed)
				it = _collisionBulletList.erase(it);
			else
				++it;
		}
	}
}
/*
	*碰撞检测
	*/
void CollisionManager::onUpdate(float dt)
{
	//目前每一条鱼的包围盒不会超过3个
	Vec2           centerPoints[8];
	LuaStack   *luaStack = LuaEngine::getInstance()->getLuaStack();
	lua_State *L = luaStack->getLuaState();
	//遍历每一个子弹以及鱼
	for (auto it = _collisionFishList.begin();it != _collisionFishList.end();++it)
	{
		CollisionEntity *fish = *it;
		//销毁被标记的对象,优先判断对象的销毁标志
		if (fish->_mask & CollisionMask::CollisionMask_Destroy)
		{
			it = _collisionFishList.erase(it);
			delete fish;
			//次过此时已经到达尽头,直接跳过
			if (it == _collisionFishList.end())
				break;
			fish = *it;
		}
		else 	if (fish->_mask & CollisionMask::CollisionMask_Removed)
		{
			it = _collisionFishList.erase(it);
			//标记对象已经脱离了队列
			fish->_mask |= CollisionMask::CollisionMask_Away;
			if (it == _collisionFishList.end())
				break;
			fish = *it;
		}
		//如果禁止了
		if (!fish->_enabled)
			continue;
		auto &fishPosition = fish->_mainEntity->getPosition();
		//将包围盒数据取出来
		auto &fishBoundingBoxVec = fish->_collisionArea->boundingBoxVec;
		//标志是否需要计算
		bool    needCalculated = true;
		//是否已经计算了
		for (auto ut= _collisionBulletList.begin();ut != _collisionBulletList.end();++ut)
		{
			auto bullet = *ut;
			//删除被标记的子弹碰撞对象,销毁标志优先被判断
			if (bullet->_mask & CollisionMask::CollisionMask_Destroy)
			{
				ut = _collisionBulletList.erase(ut);
				delete bullet;
				//bullet = nullptr;
				if (ut == _collisionBulletList.end())
					break;
				bullet = *ut;
			}
			else if (bullet->_mask & CollisionMask::CollisionMask_Removed)
			{
				ut = _collisionBulletList.erase(ut);
				bullet->_mask |= CollisionMask::CollisionMask_Away;
				if (ut == _collisionBulletList.end())
					break;
				bullet = *ut;
			}
			//如果被禁止了,或者子弹的有目标不是当前检测的鱼,直接跳过
			if (!bullet->_enabled ||( bullet->_target &&  bullet->_target != fish->_entityId))
				continue;
			auto &bulletPosition = bullet->_mainEntity->getPosition();
			//先进行一个大致的判断
			float interpositionX = fishPosition.x - bulletPosition.x;
			float interpolationY = fishPosition.y - bulletPosition.y;
			float radius = fish->_maxRadius + bullet->_maxRadius;
			if (interpositionX*interpositionX + interpolationY*interpolationY > radius*radius)
				continue;
			//检测是否需要计算上面的鱼的信息
			if (needCalculated)
			{
				needCalculated = false;
				//使用离线已经计算好的数值
				float *userData = (float*)fish->_mainEntity->getUserData();
				int idx = 0;
				for(auto &boundbox: fishBoundingBoxVec)
				{
					//进行一次旋转变换
					auto &offsetPoint = boundbox.offsetCenter;
					centerPoints[idx].x = fishPosition.x + userData[0] * offsetPoint.x - userData[1] * offsetPoint.y;
					centerPoints[idx].y = fishPosition.y + userData[1] * offsetPoint.x + userData[0] * offsetPoint.y;
					++idx;
				}
			}
			//进行精细的检测
			int idx = 0;
			for (auto &boundingbox : fishBoundingBoxVec)
			{
				radius = boundingbox.catchRadius + bullet->_maxRadius;
				interpositionX = centerPoints[idx].x - bulletPosition.x;
				interpolationY = centerPoints[idx].y - bulletPosition.y;
				if (interpositionX * interpositionX + interpolationY*interpolationY <= radius*radius)
				{
					//碰撞检测成功
					bullet->_enabled = false;
					//调用lua函数
					//if (_luaScriptFunc)
					{
						//将被碰撞的子弹/鱼的id加入进去
						lua_getglobal(L,"fish2d");
						lua_getfield(L, -1, "collisionCallback");
						lua_pushinteger(L,bullet->_entityId);
						lua_pushinteger(L, fish->_entityId);
						lua_call(L, 2, 0);
						//lua_settop(L, 0);
					}
					break;
				}
				++idx;
			}
		}
	}
}
//屏幕空间划分
void CollisionManager::spacePartion()
{
	int fishVecSize = _collisionFishList.size() / 4 + 1;
	int bulletVecSize = _collisionBulletList.size() / 4 + 1;
	//遍历所有的鱼,进行空间划分
	for (auto it = _collisionFishList.begin(); it != _collisionFishList.end(); ++it)
	{
		CollisionEntity *fishEntity = *it;
		//检测是否被销毁/删除
		if (fishEntity->_mask & CollisionMask_Destroy)
		{
			it = _collisionFishList.erase(it);
			delete fishEntity;
			if (it == _collisionFishList.end())
				break;
			fishEntity = *it;
		}
		else if (fishEntity->_mask & CollisionMask_Removed)
		{
			it = _collisionFishList.erase(it);
			fishEntity->_mask |= CollisionMask_Away;
			if (it == _collisionFishList.end())
				break;
			fishEntity = *it;
		}
		if (!fishEntity->_enabled)
			continue;
		auto &position = fishEntity->_mainEntity->getPosition();
		float  startX = position.x - fishEntity->_maxRadius;
		float  startY = position.y - fishEntity->_maxRadius;
		float  endX  = position.x + fishEntity->_maxRadius;
		float  endY  = position.y + fishEntity->_maxRadius;
		//求网格区间
		int     startSpaceX = startX / _xStepSpace;
		int     finalSpaceX = endX / _xStepSpace;
		int     startSpaceY = startY / _yStepSpace;
		int     finalSpaceY = endY / _yStepSpace;
		//压入相关的堆栈
		finalSpaceX = finalSpaceX < SPACE_STEP_X ? finalSpaceX : SPACE_STEP_X-1;
		finalSpaceY = finalSpaceY < SPACE_STEP_Y ? finalSpaceY : SPACE_STEP_Y-1;
		for (int i = startSpaceX<0?0: startSpaceX; i <= finalSpaceX; ++i)
		{
			for (int k = startSpaceY<0?0: startSpaceY; k <= finalSpaceY; ++k)
			{
				_spacePartionFish[i][k].push_back(fishEntity);
			}
		}
	}
	//遍历子弹的碰撞队列,子弹的计算过程与鱼的稍有不同
	for (auto it = _collisionBulletList.begin(); it != _collisionBulletList.end(); ++it)
	{
		CollisionEntity *bulletEntity = *it;
		if (bulletEntity->_mask & CollisionMask_Destroy)
		{
			it = _collisionBulletList.erase(it);
			delete bulletEntity;
			if (it == _collisionBulletList.end())
				break;
			bulletEntity = *it;
		}
		else if (bulletEntity->_mask & CollisionMask_Removed)
		{
			it = _collisionBulletList.erase(it);
			bulletEntity->_mask |= CollisionMask_Away;
			if (it == _collisionBulletList.end())
				break;
			bulletEntity = *it;
		}
		if (!bulletEntity->_enabled)
			continue;
		//
		auto &position = bulletEntity->_mainEntity->getPosition();
		float  startX = position.x - bulletEntity->_maxRadius;
		float  finalX = position.x + bulletEntity->_maxRadius;
		float  startY = position.y - bulletEntity->_maxRadius;
		float finalY = position.y + bulletEntity->_maxRadius;
		//
		int   startSpaceX = startX / _xStepSpace;
		int   finalSpaceX = finalX / _xStepSpace;
		int   startSpaceY = startY / _yStepSpace;
		int   finalSpaceY = finalY / _yStepSpace;
		//
		finalSpaceX = finalSpaceX < SPACE_STEP_X ? finalSpaceX : SPACE_STEP_X-1;
		finalSpaceY = finalSpaceY < SPACE_STEP_Y ? finalSpaceY : SPACE_STEP_Y - 1;
		for (int i = startSpaceX<0?0:startSpaceX; i <= finalSpaceX; ++i)
		{
			for (int k = startSpaceY<0?0:startSpaceY; k <= finalSpaceY; ++k)
			{
				_spacePartionBullet[i][k].push_back(bulletEntity);
			}
		}
	}
}
//以空间划分的算法形式检测碰撞
void CollisionManager::onUpdateSpacePartion(float dt)
{
	//分区
	spacePartion();
	//对于每一个分区检测碰撞
	for (int i = 0; i < SPACE_STEP_X; ++i)
	{
		for (int k = 0; k < SPACE_STEP_Y; ++k)
		{
			//如果区间不为空
			auto &fishEntityVec = _spacePartionFish[i][k];
			auto &bulletEntityVec = _spacePartionBullet[i][k];
			//
			if(fishEntityVec.size() && bulletEntityVec.size())
				checkSpaceCollision(fishEntityVec, bulletEntityVec);
			//做一下清理
			fishEntityVec.clear();
			bulletEntityVec.clear();
		}
	}
}

void CollisionManager::checkSpaceCollision(std::vector<CollisionEntity *> &fishEntityVec, std::vector<CollisionEntity *> &bulletEntityVec)
{
	//对每一条鱼与每一个子弹计算碰撞
	Vec2           centerPoints[4];
	//遍历每一个子弹以及鱼
	for (auto it = fishEntityVec.begin(); it != fishEntityVec.end(); ++it)
	{
		CollisionEntity *fish = *it;
		if (!fish->_enabled)
			continue;
		auto &fishPosition = fish->_mainEntity->getPosition();
		//将包围盒数据取出来
		auto &fishBoundingBoxVec = fish->_collisionArea->boundingBoxVec;
		//标志是否需要计算
		bool    needCalculated = true;
		//是否已经计算了
		for (auto ut = bulletEntityVec.begin(); ut != bulletEntityVec.end(); ++ut)
		{
			auto bullet = *ut;
			//如果被禁止了,或者子弹的有目标不是当前检测的鱼,直接跳过
			if (!bullet->_enabled || (bullet->_target &&  bullet->_target != fish->_entityId))
				continue;
			auto &bulletPosition = bullet->_mainEntity->getPosition();
			//先进行一个大致的判断
			float interpositionX = fishPosition.x - bulletPosition.x;
			float interpolationY = fishPosition.y - bulletPosition.y;
			float radius = fish->_maxRadius + bullet->_maxRadius;
			if (interpositionX*interpositionX + interpolationY*interpolationY > radius*radius)
				continue;
			//检测是否需要计算上面的鱼的信息
			if (needCalculated)
			{
				needCalculated = false;
				//使用离线已经计算好的数值
				float *userData = (float*)fish->_mainEntity->getUserData();
				int idx = 0;
				for (auto &boundbox : fishBoundingBoxVec)
				{
					//进行一次旋转变换
					auto &offsetPoint = boundbox.offsetCenter;
					centerPoints[idx].x = fishPosition.x + userData[0] * offsetPoint.x - userData[1] * offsetPoint.y;
					centerPoints[idx].y = fishPosition.y + userData[1] * offsetPoint.x + userData[0] * offsetPoint.y;
					++idx;
				}
			}
			//进行精细的检测
			int idx = 0;
			for (auto &boundingbox : fishBoundingBoxVec)
			{
				radius = boundingbox.catchRadius + bullet->_maxRadius;
				interpositionX = centerPoints[idx].x - bulletPosition.x;
				interpolationY = centerPoints[idx].y - bulletPosition.y;
				if (interpositionX * interpositionX + interpolationY*interpolationY <= radius*radius)
				{
					//碰撞检测成功
					bullet->_enabled = false;
					//调用lua函数
					//if (_luaScriptFunc)
					{
						//将被碰撞的子弹/鱼的id加入进去
						lua_getglobal(_luaState, "fish2d"); 
						lua_getfield(_luaState, -1, "collisionCallback");
						lua_pushinteger(_luaState, bullet->_entityId);
						lua_pushinteger(_luaState, fish->_entityId);
						lua_call(_luaState, 2, 0);
					}
					break;
				}
				++idx;
			}
		}
	}
}
NS_FISH2D_END
