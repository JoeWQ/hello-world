/*
  *@aim:有关系统信息的封装
  &2016-4-11 10:27:07
  */
#ifndef    __DIRECTOR_H__
#define   __DIRECTOR_H__
#include<glState.h>
struct  ESContext;
void     __set_globle(ESContext   *_context);
class      Director
{
private:
//screen size
	        Size          _winSize;
//IO Context
			void          *_ioContext;
private:
	        Director();
			Director(Director &);
			static         Director          _director;
public:
	        ~Director();
			static       Director      *getInstance();
			Size         getWinSize(){ return    _winSize;};
			float        getWinHeight(){return   _winSize.height;};
			float        getWinWidth(){return   _winSize.width;};
//io Context
			void         *getIOContext(){return    _ioContext;};
		    friend      void     __set_globle(ESContext   *_context);
};
#endif