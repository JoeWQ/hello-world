// gauss.cpp
// this actually calculates the gauss values.

#include <math.h>
#include <time.h>
#include <stdlib.h>

double ranf()
{
	return (double)rand()/(double)RAND_MAX;
}

//ע����� �����ֲ� �������
//http://blog.csdn.net/fall221/article/details/8805142
//���õĳ�������ɸ�˹�ֲ���������еķ�����Marsaglia��Bray��1964�����
//���ڸú����ľ��庬��,��μ� http://www.youduoshao.com/2015-03-16/201503162397.html
//http://wenku.baidu.com/link?url=gfiAF-ojpQRGJCgZfUrLpxjm-Q7jxYb7KuwpF_ksLZX0ZT0NqLcGFFUmjDaWmLRwVHhyGlqlNJTDX0q_R5oLR4X178-tJy0tKplL1ISCku_
//���߿���ֱ�Ӳο� <����������������-2>��3���������3.4�� 107ҳ
//��̬�����伫��
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
//w�Ǽ�����뾶
	w = sqrt( -2.0 * log( w )/w );
	work[0] = x1 * w;	// first gauss random
	work[1] = x2 * w;	// second gauss random
//������ֵΪE,����ΪV�Ļ�,���Լ���
//	work[0] = V*w*x1 + E;
//	work[1] = V*w*x2 + E;
}