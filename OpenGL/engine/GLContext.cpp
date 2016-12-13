/*
  *OpenGL上下文实现
  &2016-4-30
  */
#include<engine/GLContext.h>
#include<stdlib.h>
#include<time.h>
#ifdef  _WIN32
#include<windows.h>
#else
  #include<sys/time.h>
#endif
//#include<GL/freeglut.h>
#include<engine/GLCacheManager.h>
GLContext          GLContext::_singleGLContext;
static       unsigned       _static_last_seed = 0;
 GLContext          *GLContext::getInstance()
{
          return    &_singleGLContext;
 }
 //
 GLContext::GLContext()
{
           this->userObject=NULL;
           this->update=NULL;
           this->draw=NULL;
           this->init=NULL;
           this->finalize=NULL;
#ifdef  _WIN32
		   lastTickCount=GetTickCount();
#else
           struct     timeval      tv;
           gettimeofday(&tv,NULL);
		   baseTickCount=tv.tv_sec;
		   lastTickCount = 0;
#endif
           winSize.width=640;
           winSize.height=480;
 //          displayMode=GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH | GLUT_STENCIL;
           winTitle="OpenGL-Sprite";
		   _rand_seed=time(NULL);
		   srand(_rand_seed);
		   _static_last_seed = _rand_seed;
 }
//
  void    GLContext::registerUpdateFunc(void  (*_update)(GLContext *,float ))
 {
           this->update=_update;
  }
//
  void    GLContext::registerDrawFunc(void (*_draw)(GLContext *))
 {
           this->draw=_draw;
  }
//
  void    GLContext::registerInitFunc(void  (*_init)(GLContext *))
 {
           this->init=_init;
  }
//
  void   GLContext::registerShutDownFunc(void  (*_finalize)(GLContext *))
 {
          this->finalize=_finalize;
  }
//
  void    GLContext::setWinSize(Size  &_size)
 {
          this->winSize=_size;
  }
 //
  void    GLContext::setWinPosition(GLVector2 &_position)
  {
	      this->winPosition = _position;
  }
 //
   Size     &GLContext::getWinSize()
  {
          return   this->winSize;
   }
 //
   void       GLContext::setDisplayMode(int  flag)
  {
           this->displayMode=flag;
   }
//
   int          GLContext::getDisplayMode()
  {
            return     this->displayMode;
   }
 //
   void       GLContext::setWindowTitle(char  *_title)
  {
            this->winTitle=_title;
   }
//
   char       *GLContext::getWindowTitle()
   {
	        return  this->winTitle;
   }

   void          GLContext::setNearFarPlane(GLVector2 &near_far)
   {
	   _near_far_plane = near_far;
   }

   GLVector2     &GLContext::getNearFarPlane()
   {
	   return _near_far_plane;
   }

   void        GLContext::setProjMatrix(Matrix   &projMatrix)
   {
	   _projMatrix = projMatrix;
   }

   Matrix        &GLContext::getProjMatrix()
   {
	   return _projMatrix;
   }
   float          GLContext::randomValue()
   {
//unsigned之内的所有的素数    
	   static       unsigned       _prim_table_index = 0;
	   const       unsigned        _prim_table_size = 17;
	   const       unsigned        _max_unsigned_value = 0xFFFF;
	   static       unsigned       _prim_table_[_prim_table_size] = { 344209, 353767, 1738621, 1747289, 1938863, 2145547, 2238571, 2360173, 2414947, 2512249, 
		                                                                                                      9983977, 9999397, 9998179, 9359281, 9363533, 9369557, 9375791 };
	   //unsigned        _src_index1 = (_prim_table_index + 1) % _prim_table_size;
	   //unsigned        _src_index2 = (_prim_table_index + 4) % _prim_table_size;
	   //unsigned        _src_index3 = (_prim_table_index+7) % _prim_table_size;
	   //unsigned        _src_index4 = (_prim_table_index+9) % _prim_table_size;
	   unsigned         _new_seed =  //_rand_seed * _rand_seed * _rand_seed  
		   //   + _prim_table_[_src_index2] 
		   9363533 * _rand_seed*_rand_seed
		   //	+ _prim_table_[_src_index3] * 
		   + _rand_seed * 1738621 + 2145547;// +_prim_table_[_src_index4];
	   //if (_new_seed == _static_last_seed)
	   //{
		  // _new_seed += 9979859;//类加上一个素数
		  // _static_last_seed = _new_seed;
		  // _prim_table_index = (_prim_table_index + 1) % _prim_table_size;
	   //}
	   _rand_seed = _new_seed;
	   return       _new_seed%_max_unsigned_value / ((float)_max_unsigned_value);
   }

   unsigned    GLContext::loadBufferIdentity()
   {
	   return  GLCacheManager::getInstance()->loadBufferIdentity();
   }

   void         GLContext::gauss(float work[2])
   {
	   float      x, y;
	   float     w;
	   const	int			__maxValue = 0x7FFF;
	   do 
	   {
		   x = rand() / (float)RAND_MAX;// this->randomValue();
		   y = rand() / (float)RAND_MAX;
		   x = 2.0f* x - 1.0f;
		   y = 2.0f * y - 1.0f;
		   w = x*x + y*y;
	   } while (w>=1.0f);
	   w = sqrt( -2.0f * log(w) /w );
	   work[0] = w * x;
	   work[1] = w*y;
	   //若期望值为E,方差为V的话,可以加上
	   //	work[0] = V*w*x1 + E;
	   //	work[1] = V*w*x2 + E;
   }
//a是一个固定的系数,名称为Phillips系数
//一般取 0.0081
//   float       GLContext::phillips(const float a, const float k[2], const float wind[2])
//   {
//	   float		K2 = k[0] * k[0] + k[1] * k[1];
//	   if (K2 == 0.0f)		return 0.0f;
//
//	   float		V2 = wind[0] * wind[0] + wind[1] * wind[1];
//
//	   float		EL = V2 / __GRAVITY_CONSTANT;
////点乘
//	   float		dotValue = k[0] * wind[0] + k[1] * wind[1];
////返回的值必须是正数,因为后面需要用它作为平方因子
//	   const float		expValue = exp(-1.0f/(K2 * EL *EL));
//	   const float		unitValue = dotValue * dotValue/(K2 * V2);
//	   return  a*expValue / (K2*K2) *unitValue * exp(- sqrt(K2));
//   }

 //  double phillips(double a, double k[2], double wind[2])
	float       GLContext::phillips(const float a, const float k[2], const float wind[2])
   {
	   float k2 = k[0] * k[0] + k[1] * k[1];
	   if (k2 == 0)
		   return 0;
	   float v2 = wind[0] * wind[0] + wind[1] * wind[1];//风的方向
	   float EL = v2 / __GRAVITY_CONSTANT;//重力加速度
	   // the factor *exp(-sqrt(k2)*1.0) can get rid of small waves by increasing 1.0
	   float    w = k[0] * wind[0] + k[1] * wind[1];
	   //具体的公式,请参见simulating-ocean-water-01.pdf Page 9
	   float ret = a*(exp(-1.0 / (k2*EL*EL)) / (k2*k2))*
		   (w*w / (k2*v2))*exp(-sqrt(k2)*1.0);
	   // this value must be positive since we take the square root later
	   return ret;
   }
