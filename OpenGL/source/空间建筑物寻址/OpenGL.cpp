#include <GL/glew.h>
#include<engine/GLContext.h>
#include"SceneBuilding.h"
//ˮ�沨��
struct       UserData
{
	SceneBuilding  *_godRay;
};
//

void        Init(glk::GLContext    *_context)
{ 
	UserData	*_user = new   UserData();
	_context->userObject = _user;
	_user->_godRay = new SceneBuilding();
	_user->_godRay->loadSceneBuilding("model/scene.bin");

	glEnable(GL_DEPTH_TEST);
	glDepthFunc(GL_LEQUAL);
	glClearDepth(1.0f);
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	//glEnable(GL_POLYGON_OFFSET_FILL);
	//glPolygonOffset(4.0f, 4.0f);
	glEnable(GL_CULL_FACE);
	glCullFace(GL_BACK);
	//������ɫ����
	//glEnable(GL_BLEND);
	//glBlendFunc(GL_SRC_ALPHA, GL_ZERO);
	//glEnable(GL_POINT_SPRITE);
}
//
void         Update(glk::GLContext   *_context, float   _deltaTime)
{
	UserData    *_user = (UserData *)_context->userObject;
	_user->_godRay->update(_deltaTime);
}

void         Draw(glk::GLContext	*_context)
{
	UserData      *_user = (UserData *)_context->userObject;
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	//glEnable(GL_POLYGON_OFFSET_FILL);
	_user->_godRay->render();
}

void         ShutDown(glk::GLContext  *_context)
{
	UserData    *_user = (UserData *)_context->userObject;
	_user->_godRay->release();
	_user->_godRay = nullptr;
}
///////////////////////////don not modify below function////////////////////////////////////
