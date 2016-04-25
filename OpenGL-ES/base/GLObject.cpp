/*
  *@aim:引用计数实现
  *&2016-4-23
  */
#include "GLObject.h"
#include<assert.h>
  GLObject::GLObject()
 {
           _referenceCount=0;
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