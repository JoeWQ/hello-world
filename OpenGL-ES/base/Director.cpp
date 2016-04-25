#include"Director.h"
#include"esUtil.h"
//是否已经初始化Director了
static           int         __director_init__=0;
Director		Director::_director;
void           __set_globle(ESContext   *_context)
{
	         if(!__director_init__)
			 {
				          __director_init__=1;
						  Director     *_direct=Director::getInstance();
						  _direct->_winSize.width=_context->width;
						  _direct->_winSize.height=_context->height;
						  _direct->_ioContext=_context->platformData;
			 }
}
Director::Director()
{
	         _winSize.width=0.0f;
			 _winSize.height=0.0f;
			 _ioContext=NULL;
}
Director      *Director::getInstance()
{
	          return       &_director;
}
Director::~Director()
{
	          
}