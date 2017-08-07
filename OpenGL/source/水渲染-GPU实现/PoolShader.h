/*
  *ˮ�ص���ΧShader
  *2017-8-3
  *@Author:xiaohuaxiong
*/
#ifndef __POOL_SHADER_H__
#define __POOL_SHADER_H__
#include "engine/Object.h"
#include "engine/Geometry.h"
#include "engine/GLProgram.h"

class PoolShader :public glk::Object
{
	glk::GLProgram		*_glProgram;
	int							_mVPMatrixLoc;
	int                           _texCubeMapLoc;
	int                           _positionLoc;
	int                           _fragCoordLoc;
private:
	PoolShader();
	PoolShader(const PoolShader &);
	void		initWithFile(const char *vsFile,const char *fsFile);
public:
	~PoolShader();
	static PoolShader *create(const char *vsFile,const char *fsFile);
	/*
	  *����MVP����
	*/
	void		setMVPMatrix(const glk::Matrix &mVPMatrix);
	/*
	  *��������ͼ
	 */
	void   setTexCubeMap(int texCubeMapId,int unit);
	/*
	  *perform
	 */
	void   perform();
	/*
	  *position
	*/
	int     getPositionLoc();
	/*
	  *frag Coord
	 */
	int     getFragCoordLoc();
};
#endif
