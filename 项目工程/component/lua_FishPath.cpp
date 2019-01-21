/*
  *路径导出函数
  *以及一些其他的变形
  *碰撞检测
  *@Version:2.0
  *@author:xiaoxiong
 */
#include "lua_FishPath.h"
#include "FishPath.h"
#include "FishCollisionManager.h"
#include "scripting/lua-bindings/manual/LuaBasicConversions.h"
//针对贝塞尔曲线位置的用途
#define _FISH2D_USER_DATA_BEZIER_POSITION_SPEED_SCALE_  4
#define _FISH2D_USER_DATA_BEZIER_POSITION_DISTANCE_          5
//针对沿着线段行走
#define _FISH2D_USER_DATA_DIRECTION_STARTPOINT_X                4
#define _FISH2D_USER_DATA_DIRECTION_TARTPOINT_Y_                5
USING_NS_CC;
//游戏的屏幕尺寸
static float static_fish2d_screen_width = 0;
static float static_fish2d_screen_height = 0;
//服务端使用的游戏屏幕边界
static float static_fish2d_server_width = 0;
static float static_fish2d_server_height = 0;
//计算游戏屏幕的宽高与服务端的宽高之间的比例
static float static_fish2d_game_server_width_scale = 1.0f;
static float static_fish2d_game_server_height_scale = 1.0f;
//设置游戏的边界
static Rect  static_fish2d_boundary;
//创建路径,给定控制点
static int lua_fishpath_createBezier(lua_State *L)
{
	std::vector<Vec2>  controlPoints;
	float   distance = lua_tonumber(L,1);
	size_t number = lua_objlen(L, 2);
	controlPoints.resize(number);
	CCASSERT(number>2,"lua_fishpath_create,Control Points must greater than 2.");
	for (int i = 0; i < number; i++)
	{
		lua_pushnumber(L, i + 1);
		lua_gettable(L, 2);

		lua_getfield(L, -1, "x");
		lua_getfield(L, -2, "y");

		controlPoints[i].x = lua_tonumber(L, -2);
		controlPoints[i].y = lua_tonumber(L, -1);

		lua_pop(L, 3);
	}
	FishPath *path = new FishPath(distance);
	path->initWithControlPoint(controlPoints,static_fish2d_game_server_width_scale,static_fish2d_game_server_height_scale);
	lua_pushlightuserdata(L, path);
	return 1;
}
//释放路径对象
static int lua_fishpath_releaseBezier(lua_State *L)
{
	FishPath *path = (FishPath*)lua_touserdata(L,1);
	delete path;
	path = nullptr;
	lua_settop(L,0);
	return 0;
}
//从曲线中提取出数据
static int lua_fishpath_extractBezier(lua_State *L)
{
	Vec2 position;
	FishPath *path = (FishPath*)lua_touserdata(L, 1);
	Node *entity = nullptr;
	luaval_to_object<Node>(L, 2, "cc.Node", &entity, "lua_fishpath_extract");
	float *userData = (float*)entity->getUserData();
	float  dt = lua_tonumber(L,3);
	float  speed = lua_tonumber(L,4);
	//计算速度的缩放值
	float subDistance = speed *userData[_FISH2D_USER_DATA_BEZIER_POSITION_SPEED_SCALE_] *dt;
	userData[_FISH2D_USER_DATA_BEZIER_POSITION_DISTANCE_] += subDistance;
	Vec4 dSpeedScaledxdy;
	path->extract(userData[_FISH2D_USER_DATA_BEZIER_POSITION_DISTANCE_],position, dSpeedScaledxdy);
	entity->setPosition(position.x + userData[_FISH2D_USER_DATA_POSITION_OFFSET_X_], position.y + userData[_FISH2D_USER_DATA_POSITION_OFFSET_Y_]);
	entity->setRotation(dSpeedScaledxdy.x);
	userData[_FISH2D_USER_DATA_BEZIER_POSITION_SPEED_SCALE_] = dSpeedScaledxdy.y;
	lua_pushboolean(L,userData[_FISH2D_USER_DATA_BEZIER_POSITION_DISTANCE_]>=path->getCurveDistance());
	return 1;
}
//调用贝塞尔路径函数之前,需要做的数据预处理
int lua_fishpath_initBezier(lua_State *L)
{
	FishPath *pathTracker =(FishPath*) lua_touserdata(L, 1);
	Node *mainEntity = nullptr;
	luaval_to_object<Node>(L,2,"cc.Node",&mainEntity,"lua_fishpath_initBezier");
	float *userData = (float*)mainEntity->getUserData();
	//偏移量
	lua_pushstring(L,"x");
	lua_gettable(L,3);
	float offsetX = lua_tonumber(L ,-1);
	lua_pop(L,1);

	lua_pushstring(L,"y");
	lua_gettable(L, 3);
	float offsetY = lua_tonumber(L,-1);
	lua_pop(L,1);
	//速度
	Vec2 position;
	Vec4 dspeedScaledxdy;
	pathTracker->extract(0,position, dspeedScaledxdy);
	//写入到私有数据中
	userData[_FISH2D_USER_DATA_POSITION_COS_] = dspeedScaledxdy.z;
	userData[_FISH2D_USER_DATA_POSITION_SIN_] = dspeedScaledxdy.w;
	//Offset
	userData[_FISH2D_USER_DATA_POSITION_OFFSET_X_] = offsetX;
	userData[_FISH2D_USER_DATA_POSITION_OFFSET_Y_] = offsetY;
	//速度缩放值
	userData[_FISH2D_USER_DATA_BEZIER_POSITION_SPEED_SCALE_] = dspeedScaledxdy.y;
	userData[_FISH2D_USER_DATA_BEZIER_POSITION_DISTANCE_] = 0;//已经行走的路程
	//
	mainEntity->setRotation(dspeedScaledxdy.x);
	mainEntity->setPosition(position);
	lua_settop(L,0);
	return 0;
}
//子弹可以不遵从数据的位置使用规则
int lua_fishpath_init_bullet_direction(lua_State *L)
{
	Node *mainEntity = nullptr;
	luaval_to_object<Node>(L,1,"cc.Node",&mainEntity,"lua_fishpath_init_bullet_direction");
	//position
	lua_pushstring(L,"x");
	lua_gettable(L,2);
	float x = lua_tonumber(L,-1);
	lua_pop(L,1);

	lua_pushstring(L,"y");
	lua_gettable(L, 2);
	float y = lua_tonumber(L,-1);
	lua_pop(L,1);
	//direction
	float direction = lua_tonumber(L,3);
	//speed
	float speed = lua_tonumber(L,4);
	//
	float *userData = (float*)mainEntity->getUserData();
	userData[0] = cosf(direction);
	userData[1] = sinf(direction);
	userData[2] = direction;
	userData[3] = speed;
	//
	mainEntity->setPosition(x,y);
	mainEntity->setRotation(-CC_RADIANS_TO_DEGREES(direction));
	lua_settop(L, 0);
	return 0;
}
//沿直线行走,此函数为子弹的行走路径
int lua_fishpath_bullet_direction(lua_State	*L)
{
	Node *entity = nullptr;
	luaval_to_object<Node>(L, 1, "cc.Node", &entity, "lua_fishpath_bullet_direction");
	float    dt = lua_tonumber(L,2);
	
	Vec2 position = entity->getPosition();
	float *userData = (float*)entity->getUserData();
	bool xChanged=false, yChanged=false;
	float speedTime = userData[3] *dt;
	position.x += speedTime*userData[0];
	position.y += speedTime*userData[1];
	if (position.x < 0)
	{
		position.x = -position.x;
		userData[2] = M_PI - userData[2];
		userData[0] = -userData[0];
		xChanged = true;
	}
	else if (position.x>static_fish2d_screen_width)
	{
		position.x =  2*static_fish2d_screen_width - position.x;
		userData[2] = M_PI - userData[2];
		userData[0] = -userData[0];
		xChanged = true;
	}
	//
	if (position.y < 0)
	{
		position.y = -position.y;
		userData[2] = -userData[2];
		userData[1] = -userData[1];
		yChanged = true;
	}
	else if (position.y > static_fish2d_screen_height)
	{
		position.y = 2*static_fish2d_screen_height- position.y;
		userData[2] = -userData[2];
		userData[1] = -userData[1];
		yChanged = true;
	}
	entity->setPosition(position);
	if (xChanged | yChanged)
		entity->setRotation(-CC_RADIANS_TO_DEGREES(userData[2]));
	//clean
	lua_settop(L,0);
	return 0;
}
//修改子弹的方向,因为所定时子弹的方向会发生变化
int lua_fishpath_setBulletDirection(lua_State *L)
{
	Node *mainEntity = nullptr;
	Node *targetEntity = nullptr;
	luaval_to_object<Node>(L,1,"cc.Node",&mainEntity,"lua_fishpath_setBulletDirection");
	luaval_to_object<Node>(L,2,"cc.Node",&targetEntity,"lua_fishpath_setBulletDirection");
	float *userdata = (float*)mainEntity->getUserData();
	auto &originPosition = mainEntity->getPosition();
	auto &targetPosition = targetEntity->getPosition();
	//求目前的角度
	float dx = targetPosition.x - originPosition.x;
	float dy = targetPosition.y - originPosition.y;
	float direction = atan2f(dy,dx);
	//
	mainEntity->setRotation(-CC_RADIANS_TO_DEGREES(direction));
	float d = sqrtf(dx*dx+dy*dy);
	//
	userdata[0] = dx / d;
	userdata[1] = dy / d;
	userdata[2] = direction;
	lua_settop(L,0);
	return 0;
}
int lua_fishpath_initVector(lua_State *L)
{
	Node *mainEntity = nullptr;
	luaval_to_object<Node>(L,1,"cc.Node",&mainEntity,"lua_fishpath_initVector");
	//position
	lua_pushstring(L,"x");
	lua_gettable(L, 2);
	float x = lua_tonumber(L,-1);
	lua_pop(L,1);

	lua_pushstring(L,"y");
	lua_gettable(L,2);
	float y = lua_tonumber(L,-1);
	lua_pop(L,1);

	float   direction = lua_tonumber(L,3);
	float *userData = (float *)mainEntity->getUserData();
	userData[_FISH2D_USER_DATA_POSITION_COS_] = cosf(direction);
	userData[_FISH2D_USER_DATA_POSITION_SIN_] = sinf(direction);
	//
	mainEntity->setPosition(x,y);
	mainEntity->setRotation(-CC_RADIANS_TO_DEGREES(direction));
	//
	lua_settop(L,0);
	return 0;
}
//沿着向量行走算法,并附带边界检测
int lua_fishpath_calculate_vector(lua_State *L)
{
	//获取表数据
	Node *entity = nullptr;// (Node*)lua_touserdata(L, 1);
	luaval_to_object<Node>(L,1,"cc.Node",&entity,"lua_fishpath_calculate_vector");
	float    speed = lua_tonumber(L, 2);
	float    dt = lua_tonumber(L,3);
	Vec2 position = entity->getPosition();
	//
	float *userData = (float *)entity->getUserData();
	float speedTime = speed*dt;
	position.x += speedTime *userData[_FISH2D_USER_DATA_POSITION_COS_];
	position.y += speedTime * userData[_FISH2D_USER_DATA_POSITION_SIN_];
	entity->setPosition(position);
	//检测是否超出了边界,返回true表示已经到达了尽头
	bool b = position .x>=static_fish2d_boundary.origin.x  &&
		position.x<= static_fish2d_boundary.size.width &&
		position.y>= static_fish2d_boundary.origin.y &&
		position.y<= static_fish2d_boundary.size.height;
	lua_pushboolean(L, !b);
	return 1;
}
//将沿着某两个端点行走的Node对象初始化
int lua_fishpath_init_direction(lua_State *L)
{
	Node *mainEntity = nullptr;
	luaval_to_object<Node>(L, 1, "cc.Node", &mainEntity, "lua_fishpath_init_direction");
	//第二个是初始端点
	Vec2 startPoint, finalPoint,offset;
	//startPoint
	lua_pushstring(L,"x");
	lua_gettable(L, 2);
	startPoint.x = lua_tonumber(L, -1);
	lua_pop(L,1);
	lua_pushstring(L,"y");
	lua_gettable(L,2);
	startPoint.y = lua_tonumber(L,-1);
	lua_pop(L,1);
	//finalPoint
	lua_pushstring(L,"x");
	lua_gettable(L,3);
	finalPoint.x = lua_tonumber(L ,-1);
	lua_pop(L,1);
	lua_pushstring(L,"y");
	lua_gettable(L,3);
	finalPoint.y = lua_tonumber(L,-1);
	lua_pop(L,1);
	//offset
	lua_pushstring(L, "x");
	lua_gettable(L,4);
	offset.x = lua_tonumber(L,-1);
	lua_pop(L,1);
	lua_pushstring(L,"y");
	lua_gettable(L,4);
	offset.y = lua_tonumber(L,-1);
	lua_pop(L,1);
	//写入到Node的私有数据中
	float *userData = (float*)mainEntity->getUserData();
	float dx = finalPoint.x - startPoint.x;
	float dy = finalPoint.y - startPoint.y;
	float direction = atan2f(dy,dx);
	userData[_FISH2D_USER_DATA_POSITION_COS_] = cosf(direction);
	userData[_FISH2D_USER_DATA_POSITION_SIN_] = sinf(direction);
	userData[_FISH2D_USER_DATA_POSITION_OFFSET_X_] = offset.x + startPoint.x;
	userData[_FISH2D_USER_DATA_POSITION_OFFSET_Y_] = offset.y + startPoint.y;
	//
	userData[_FISH2D_USER_DATA_POSITION_COUNT_+0] = dx;
	userData[_FISH2D_USER_DATA_POSITION_COUNT_ + 1] = dy;
	mainEntity->setPosition(userData[_FISH2D_USER_DATA_POSITION_OFFSET_X_], userData[_FISH2D_USER_DATA_POSITION_OFFSET_Y_]);
	mainEntity->setRotation(-CC_RADIANS_TO_DEGREES(direction));
	lua_settop(L,0);
	return 0;
}
//沿着某两个端点决定的直线行走
int lua_fishpath_calculate_direction(lua_State *L)
{
	Node *mainEntity = nullptr;// static_cast<Node*>(lua_touserdata(L, 1));
	luaval_to_object<Node>(L,1,"cc.Node",&mainEntity,"mainEntity");
	float timeRate = lua_tonumber(L,2);
	float *userData = (float*)mainEntity->getUserData();
	//
	mainEntity->setPosition(userData[_FISH2D_USER_DATA_POSITION_OFFSET_X_] + userData[_FISH2D_USER_DATA_POSITION_COUNT_ + 0] *timeRate,
													userData[_FISH2D_USER_DATA_POSITION_OFFSET_Y_] + userData[_FISH2D_USER_DATA_POSITION_COUNT_ + 1] *timeRate);
	lua_settop(L,0);
	return 0;
}
//设置屏幕/服务端屏幕的宽高
int lua_fishpath_setScreenSize(lua_State *L)
{
	static_fish2d_screen_width = lua_tonumber(L,1);
	static_fish2d_screen_height = lua_tonumber(L, 2);
	static_fish2d_server_width = lua_tonumber(L, 3);
	static_fish2d_server_height = lua_tonumber(L, 4);
	static_fish2d_game_server_width_scale = static_fish2d_screen_width / static_fish2d_server_width;
	static_fish2d_game_server_height_scale = static_fish2d_screen_height/ static_fish2d_server_height;
	//
	lua_settop(L,0);
	return 0;
}
//游戏的边界
int lua_fishpath_setGameBoundary(lua_State *L)
{
	static_fish2d_boundary.origin.x = lua_tonumber(L,1);
	static_fish2d_boundary.origin.y = lua_tonumber(L,2);
	static_fish2d_boundary.size.width = lua_tonumber(L,3) ;
	static_fish2d_boundary.size.height = lua_tonumber(L,4) ;
	return 0;
}
//版本
int lua_fishpath_getVersion(lua_State *L)
{
	//版本1实现了贝塞尔路径算法
	//版本2实现了碰撞算法
	//版本3改进了直线路径算法,直接放到了C++中
	lua_pushnumber(L,2);
	return 1;
}
//lua本身自带的math.atan2的使用方法与数学上的定义有着相反的差别
int lua_fishpah_atan2f(lua_State *L)
{
	float ty = lua_tonumber(L,1);
	float tx = lua_tonumber(L,2);
	lua_pushnumber(L,atan2f(ty,tx));
	return 1;
}
//计算手势位置与炮台之间的角度,并且如果角度超过了某一个值,则会截断
int lua_fishpath_calculateRadians(lua_State *L)
{
	//炮台的位置
	lua_pushstring(L,"x");
	lua_gettable(L,1);
	float startPointX = lua_tonumber(L,-1);
	lua_pop(L,1);

	lua_pushstring(L,"y");
	lua_gettable(L,1);
	float startPointY = lua_tonumber(L,-1);
	lua_pop(L,1);

	//目标手势的位置
	lua_pushstring(L,"x");
	lua_gettable(L,2);
	float finalPointX = lua_tonumber(L,-1);
	lua_pop(L,1);

	lua_pushstring(L,"y");
	lua_gettable(L, 2);
	float finalPointY = lua_tonumber(L,-1);
	lua_pop(L,1);
	//是否启用截断角度
	bool wrapPolicy = lua_toboolean(L, 3);
	//计算向量之间的角度
	float dx = finalPointX - startPointX;
	float dy = finalPointY - startPointY;
	float radians = atan2f(dy,dx);
	//是否需要截断
	if (wrapPolicy)
	{
		if (dx > 0)
		{
			if (dy < 0)
				radians = 0;
		}
		else
		{
			if (dy < 0)
				radians = M_PI;
		}
	}
	lua_pushnumber(L,radians);
	return 1;
}
///////////////////碰撞管理器//////////////////////////////////////////////
int lua_fishpath_createCollisionManager(lua_State *L)
{
	fish2d::CollisionManager *collisionManager = fish2d::CollisionManager::getInstance();
	lua_pushlightuserdata(L, collisionManager);
	return 1;
}
//销毁碰撞管理对象
int lua_fishpath_destroyCollisionManager(lua_State *L)
{
	fish2d::CollisionManager *manager = (fish2d::CollisionManager*)lua_touserdata(L, 1);
	delete manager;
	manager = nullptr;
	lua_settop(L,0);
	return 0;
}
//向碰撞管理器中注册包围盒对象
int lua_fishpath_registerCollisionArea(lua_State *L)
{
	int id = lua_tointeger(L, 1);
	//获取包围盒数据
	size_t objectNumber = lua_objlen(L,2);
	std::vector<fish2d::Boundingbox>  boundingboxes;
	boundingboxes.reserve(objectNumber);
	for (int i = 0; i < objectNumber; ++i)
	{
		lua_pushnumber(L,i+1);
		lua_gettable(L,2);

		lua_getfield(L, -1,"Radio");
		lua_getfield(L,-2,"OffsetX");
		lua_getfield(L,-3,"OffsetY");

		fish2d::Boundingbox box;
		box.catchRadius = lua_tonumber(L,-3);
		box.offsetCenter.x = lua_tonumber(L,-2);
		box.offsetCenter.y = lua_tonumber(L, -1);
		boundingboxes.push_back(box);

		lua_pop(L,4);
	}
	lua_settop(L,0);
	//
	fish2d::CollisionManager::getInstance()->registerCollisionArea(id, boundingboxes);
	return 0;
}
//创建碰撞实体对象
int lua_fishpath_createCollisionEntity(lua_State *L)
{
	//类型
	fish2d::EntityType type = (fish2d::EntityType)lua_tointeger(L, 1);
	int   id = lua_tointeger(L, 2);
	//包围盒的主体
	Node *mainEntity = nullptr;
	luaval_to_object<Node>(L, 3, "cc.Node",&mainEntity, "lua_fishpath_createCollisionEntity");
	//包围盒集合的id
	int boundingboxId = lua_tointeger(L,4);
	fish2d::CollisionManager *manager = fish2d::CollisionManager::getInstance();
	fish2d::CollisionArea *area = manager->requireCollisionArea(boundingboxId);
	fish2d::CollisionEntity *entity = fish2d::CollisionEntity::create(type,id,mainEntity, area);
	//
	lua_pushlightuserdata(L, entity);
	return 1;
}
//设置子弹的最大碰撞半径,此函数只能被子弹实体对象调用
int lua_fishpath_setEntityRadius(lua_State *L)
{
	fish2d::CollisionEntity *entity = (fish2d::CollisionEntity*)lua_touserdata(L, 1);
	CCASSERT(entity->getType() == fish2d::EntityType::EntityType_Bullet,"Only Bullet entity can set  radius.");
	float r = lua_tonumber(L,2);
	entity->setMaxRadius(r);
	lua_settop(L,0);
	return 0;
}
//设置实体的id
int lua_fishpath_setEntityId(lua_State *L)
{
	fish2d::CollisionEntity *entity = (fish2d::CollisionEntity*)lua_touserdata(L, 1);
	int id = lua_tointeger(L,2);
	entity->setEntityId(id);
	lua_settop(L,0);
	return 0;
}
//将碰撞实体加入到碰撞管理器中
int lua_fishpath_pushEntity(lua_State *L)
{
	fish2d::CollisionEntity *entity = (fish2d::CollisionEntity*)lua_touserdata(L, 1);
	fish2d::CollisionManager::getInstance()->pushEntity(entity);
	lua_settop(L,0);
	return 0;
}
//从碰撞管理器中移除
int lua_fishpath_removeEntity(lua_State *L)
{
	fish2d::CollisionEntity *entity = (fish2d::CollisionEntity	*)lua_touserdata(L, 1);
	fish2d::CollisionManager::getInstance()->removeEntity(entity);
	lua_settop(L,0);
	return 0;
}
//销毁实体对象
int lua_fishpath_destroyEntity(lua_State *L)
{
	fish2d::CollisionEntity *entity = (fish2d::CollisionEntity	*)lua_touserdata(L, 1);
	fish2d::CollisionManager::getInstance()->releaseCollisionEntity(entity);
	lua_settop(L,0);
	return 0;
}
//设置实体对象参与碰撞计算的标志,正常情况下,该函数不应被手工调用
int lua_fishpath_setEntityEnabled(lua_State *L)
{
	fish2d::CollisionEntity *entity = (fish2d::CollisionEntity*)lua_touserdata(L, 1);
	bool b = lua_toboolean(L, 2);
	entity->setEnabled(b);
	lua_settop(L,0);
	return 0;
}
//获取碰撞实体对象的标志
int lua_fishpath_isEntityEnabled(lua_State *L)
{
	fish2d::CollisionEntity *entity = (fish2d::CollisionEntity*)lua_touserdata(L, 1);
	lua_pushboolean(L, entity->isEnabled());
	return 1;
}
//设置子弹的目标id
int lua_fishpath_setEntityTarget(lua_State *L)
{
	fish2d::CollisionEntity *entity = (fish2d::CollisionEntity*)lua_touserdata(L, 1);
	CCASSERT(entity->getType()==fish2d::EntityType::EntityType_Bullet,"Could not set target to fish entity.");
	int target = lua_tonumber(L,2);
	entity->setTarget(target);
	lua_settop(L,0);
	return 0;
}
//清理所有的无效的碰撞实体
int lua_fishpath_clearAllInvalideEntity(lua_State *L)
{
	int cleanFlag = lua_tointeger(L, 1);
	fish2d::CollisionManager::getInstance()->removeAllInValideEntity(cleanFlag);
	lua_settop(L,0);
	return 0;
}
//注册碰撞后的lua回调函数
int lua_fishpath_registerCollisionScriptFunc(lua_State *L)
{
	int handler = toluafix_ref_function(L,1,0);
	fish2d::CollisionManager::getInstance()->registerLuaScriptFunc(handler);
	lua_settop(L,0);
	return 0;
}
//实时调用碰撞检测
int lua_fishpath_updateCollision(lua_State *L)
{
	lua_Number dt = lua_tonumber(L,1);
	fish2d::CollisionManager::getInstance()->onUpdate(dt);
	lua_settop(L,0);
	return 0;
}
//
int lua_fishpath_updateSpacePartion(lua_State *L)
{
	float dt = lua_tonumber(L, 1);
	fish2d::CollisionManager::getInstance()->onUpdateSpacePartion(dt);
	return 0;
}
int lua_fishpath_setCollisionScreenSize(lua_State *L)
{
	float width = lua_tonumber(L,1);
	float height = lua_tonumber(L,2);
	fish2d::CollisionManager::setScreenSize(width, height);
	lua_settop(L,0);
	return 0;
}
//性能测试函数
int lua_fishpath_checkPerformance(lua_State *L)
{
	float r = lua_tonumber(L,1);
	float speed = lua_tonumber(L,2);
	//
	int count = lua_tonumber(L,3);
	float x=0, y=0;
	struct timeval tm1,tm2,tm3;
	gettimeofday(&tm1,nullptr);
	for (int i = 0; i < count; ++i)
	{
		x += cosf(r)*speed;
		y += sinf(r)*speed;
	}
	gettimeofday(&tm2,nullptr);
	lua_pushnumber(L, (tm2.tv_sec-tm1.tv_sec)*1000 +(tm2.tv_usec-tm1.tv_usec)/1000.0f);
	x = 0, y = 0;
	for (int i = 0; i < count; ++i)
	{
		x += 1.34f*speed;
		y += 0.346f*speed;
	}
	gettimeofday(&tm3, nullptr);
	lua_pushnumber(L,(tm3.tv_sec-tm2.tv_sec)*1000+(tm3.tv_usec-tm2.tv_usec)/1000.0f);
	return 2;
}
/////////////////////////////////////////////////////////////////////////
//所有的注册函数
void register_lua_fish_path(lua_State* tolua_S)
{
	luaL_Reg  fishPath[] = {
		//与路径相关的函数
		{"createBezier",lua_fishpath_createBezier},
		{"releaseBezier",lua_fishpath_releaseBezier},
		{"initBezier",lua_fishpath_initBezier},
		{"setScreenSize",lua_fishpath_setScreenSize},
		{"setScreenBoundary",lua_fishpath_setGameBoundary},
		{"extractBezier",lua_fishpath_extractBezier },
		//
		{"initBulletDirection",lua_fishpath_init_bullet_direction },
		{"calculateBulletDirection",lua_fishpath_bullet_direction},
		{"setBulletDirection",lua_fishpath_setBulletDirection},
		//
		{"initVector",lua_fishpath_initVector},
		{"calculateVector",lua_fishpath_calculate_vector },
		//
		{"initDirection",lua_fishpath_init_direction},
		{"calculateDirection",lua_fishpath_calculate_direction},
		//
		{"atan2f",lua_fishpah_atan2f},
		{"calculateRadians",lua_fishpath_calculateRadians },
		//版本
		{"getVersion",lua_fishpath_getVersion},
		//与碰撞相关的函数
		{"createCollisionManager",lua_fishpath_createCollisionManager },
		{"destroyCollisionManager",lua_fishpath_destroyCollisionManager },
		{"registerCollisionArea",lua_fishpath_registerCollisionArea },
		{"createCollisionEntity",lua_fishpath_createCollisionEntity },
		{"setEntityRadius",lua_fishpath_setEntityRadius},
		{"pushEntity",lua_fishpath_pushEntity },
		{"removeEntity",lua_fishpath_removeEntity },
		{"destroyEntity",lua_fishpath_destroyEntity },
		{"setEntityEnabled",lua_fishpath_setEntityEnabled },
		{"isEntityEnabled",lua_fishpath_isEntityEnabled },
		{"setEntityTarget",lua_fishpath_setEntityTarget },
		{"setEntityId",lua_fishpath_setEntityId},
		{"clearAllInvalideEntity",lua_fishpath_clearAllInvalideEntity},
		{"registerCollisionScriptFunc",lua_fishpath_registerCollisionScriptFunc },
		{"updateCollision",lua_fishpath_updateCollision},
		{"updateSpacePartion",lua_fishpath_updateSpacePartion},
		{"setCollisionScreenSize",lua_fishpath_setCollisionScreenSize },
		//
		{"testPerformance",lua_fishpath_checkPerformance},
		{nullptr,nullptr},
	};
	luaL_openlib(tolua_S, "fish2d", fishPath, 0);
}