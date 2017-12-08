// gauss.cpp
// this actually calculates the gauss values.

#include <math.h>
#include <time.h>
#include <stdlib.h>

double ranf()
{
	return (double)rand()/(double)RAND_MAX;
}

//注意其和 瑞利分布 的相关性
//http://blog.csdn.net/fall221/article/details/8805142
//常用的成熟的生成高斯分布随机数序列的方法由Marsaglia和Bray在1964年提出
//关于该函数的具体含义,请参见 http://www.youduoshao.com/2015-03-16/201503162397.html
//http://wenku.baidu.com/link?url=gfiAF-ojpQRGJCgZfUrLpxjm-Q7jxYb7KuwpF_ksLZX0ZT0NqLcGFFUmjDaWmLRwVHhyGlqlNJTDX0q_R5oLR4X178-tJy0tKplL1ISCku_
//或者可以直接参考 <计算机程序设计艺术-2>第3章随机数的3.4节 107页
//正态离差的配极法
//https://zh.wikipedia.org/wiki/%E6%AD%A3%E6%80%81%E5%88%86%E5%B8%83
void gauss(double work[2])
{
	// Algorithm by Dr. Everett (Skip) Carter, Jr.

	double x1, x2, w;

	do {
		x1 = 2.0 * ranf() - 1.0;
		x2 = 2.0 * ranf() - 1.0;
		w = x1 * x1 + x2 * x2; 
	} while ( w >= 1.0 );
//w是极坐标半径
	w = sqrt( -2.0 * log( w )/w );
	work[0] = x1 * w;	// first gauss random
	work[1] = x2 * w;	// second gauss random
//若期望值为E,方差为V的话,可以加上
//	work[0] = V*w*x1 + E;
//	work[1] = V*w*x2 + E;
}