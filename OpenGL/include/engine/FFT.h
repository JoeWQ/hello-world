/* 
  *FFT±ä»»
  *2016-12-12 09:06:21
  *Author:Ð¡»¨ÐÜ
*/
#ifndef __FFT_H__
#define __FFT_H__
struct Complex
{
	float real;
	float imag;
};
#define NY 64
int	FFT(int, int, double *, double *);
int	FFT2D(Complex[][NY], int, int, int);
int	DFT(int, int, double *, double *);

#endif