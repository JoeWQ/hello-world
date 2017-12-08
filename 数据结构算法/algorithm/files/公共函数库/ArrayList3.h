//管理类,参数化模板
#ifndef    __ARRAY_LIST_H
#define   __ARRAY_LIST_H
// 这个类的特点是，遍历的 次数要远远多于 删除，添加 操作
//知识点，平摊分析
//2013年12月27日
//2014年3月8日
/*
  *修改的地方，每次扩张的规模不再是 原来的2倍
  */
  template<typename   Key>
  class    ArrayList
  {
  private:
//  real size
	       int          ssize;
// total size
		   int          total_size;
// address of array
		   Key         **base;
		   bool        flag;
  public:
	       ArrayList();
//每次 存储数据的容量
         ArrayList(int capacity); 
		   ~ArrayList();
//返回索引  d处的 元素值
		   Key    *indexOf(int  d);
//插入元素
		   void     insert(Key    *);
//删除 索引 d 处的元素
		   Key     *removeIndexOf(int    d);
//删除元素
		   void     remove(Key   *);
//设置 删除标志，0 表示忽略 存入 模板中的 指针 值，1表示在西沟时，删除掉容器中的指针对象
		   void     setClearFlag(bool   flag);
//返回 容器 当前的容量
		   int       size();
//清除 容器中的所有元素
		   void     clear();

  };
#endif