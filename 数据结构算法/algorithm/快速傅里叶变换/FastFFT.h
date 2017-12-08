/*
  *@date:2014-9-13
  *@aim:Fast Fourier Transform
  *@author:狄建彬
  */
#ifndef    __FAST_FFT_H__
#define    __FAST_FFT_H__
//定义复数结构，
/*
  *复数的乘法，除法，单位根的验算规则，请参见 《复变函数论》
  */
 struct     Complex
{
//复数的实部
        float     real;
//复数的虚部
        float     img;
};
  class    FastFFT
 {
   public:
              FastFFT(float   *factor,int   size);
              ~FastFFT();
   public:
//在将外部的多项式系数复制到 复数结构的时候，作为一般临时数据处理的单元
         Complex       *root;
//被散列的索引,大小为size
          int               *hash_index;
//正余弦
//         float         *sin;
//		 float         *cos;
//size的大小必须为2的整次幂，这个是离散傅里叶变换所要求的必要条件之一
          int               size;
//多项式树的深度
          int    			depth;
   public:
//离散傅里叶变换
             void       fastTransform();
  //两个经过离散傅里叶变换之后的复数多项式之间的乘法
//条件是，两者的size必须是相等的
//输入，另一个 FastFFT对象，最终结果将存储在本对象中
             void        polyMultiply(FastFFT     *e);
//   private:
 //离散傅里叶变换的逆运算
             void       reverse();
//获取最终结果
             void       getResult(float    *,int   size);
 };
#endif
