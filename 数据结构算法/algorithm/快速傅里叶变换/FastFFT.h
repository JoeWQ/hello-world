/*
  *@date:2014-9-13
  *@aim:Fast Fourier Transform
  *@author:�ҽ���
  */
#ifndef    __FAST_FFT_H__
#define    __FAST_FFT_H__
//���帴���ṹ��
/*
  *�����ĳ˷�����������λ�������������μ� �����亯���ۡ�
  */
 struct     Complex
{
//������ʵ��
        float     real;
//�������鲿
        float     img;
};
  class    FastFFT
 {
   public:
              FastFFT(float   *factor,int   size);
              ~FastFFT();
   public:
//�ڽ��ⲿ�Ķ���ʽϵ�����Ƶ� �����ṹ��ʱ����Ϊһ����ʱ���ݴ���ĵ�Ԫ
         Complex       *root;
//��ɢ�е�����,��СΪsize
          int               *hash_index;
//������
//         float         *sin;
//		 float         *cos;
//size�Ĵ�С����Ϊ2�������ݣ��������ɢ����Ҷ�任��Ҫ��ı�Ҫ����֮һ
          int               size;
//����ʽ�������
          int    			depth;
   public:
//��ɢ����Ҷ�任
             void       fastTransform();
  //����������ɢ����Ҷ�任֮��ĸ�������ʽ֮��ĳ˷�
//�����ǣ����ߵ�size��������ȵ�
//���룬��һ�� FastFFT�������ս�����洢�ڱ�������
             void        polyMultiply(FastFFT     *e);
//   private:
 //��ɢ����Ҷ�任��������
             void       reverse();
//��ȡ���ս��
             void       getResult(float    *,int   size);
 };
#endif
