/*
  *鱼游动的贝塞尔曲线路径函数到处,并在使用的时候做了一些变形
  *date:2017年12月24日
  *@author:xiaohuaxiong
 */
#ifndef __LUA_FISH_PATH_H__
#define __LUA_FISH_PATH_H__
#include"cocos2d.h"
#ifdef __cplusplus
extern "C" {
#endif
#include "tolua++.h"
#ifdef __cplusplus
}
#endif

void register_lua_fish_path(lua_State* tolua_S);

#endif