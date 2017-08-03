/*
  *���ж���ĸ���
  *@Author:xiaohuaxiong
  *2017-8-2
 */
#include "Object.h"
#include<assert.h>
Object::Object() :
	_refCount(1)
{

}

void Object::retain()
{
	++_refCount;
}

void Object::release()
{
	assert(_refCount>0);
	--_refCount;
	if (!_refCount)
		delete this;
}