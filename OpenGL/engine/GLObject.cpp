/*
  *@aim:引用计数实现
  *&2016-4-23
  */
#include <engine/GLObject.h>
#include<assert.h>
  GLObject::GLObject()
 {
           _referenceCount=1;
  }
  GLObject::~GLObject()
  {
           assert(!_referenceCount);
  }
//
 void          GLObject::retain()
{
             ++_referenceCount;
 }
//ref count
  int            GLObject::getReferenceCount()
 {
            return     _referenceCount;
  }
//
  void         GLObject::release()
 {
            assert(_referenceCount>0);
            --_referenceCount;
            if(!  _referenceCount)
                         delete    this;
  }