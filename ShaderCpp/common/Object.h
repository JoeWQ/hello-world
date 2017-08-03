/*
  *���й����ж���ĸ���
  *@2017-8-2
  *@Author:xiaohuaxiong
 */
#ifndef __OBJECT_H__
#define __OBJECT_H__

class Object
{
	int      _refCount;
private:
	Object(const Object &);
protected:
	Object();
public:
	inline  int getRefCount()const { return _refCount; };

	void    retain();

	void    release();
};
#endif
