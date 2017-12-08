/*
  *@aim:结构体的成员对象
  *@date:2015年10月27日16:52:34
  *@author:
  */
  package     lexer;
  
  public      class     Member
 {
//成员名字
              public     final       String      name;
//成员的类型,成员的对其粒度隐含在Type字段中
              public     final       Type        type;
//成员在结构体内部的偏移
              public     final       int          offset;
//成员在结构体中的顺序,从0开始计数
              public     final       int          seq;
//
              public     Member(String   _name,Type   _type,int   _offset,int    _seq)
             {
                              this.name=  _name;
                              this.type  =  _type;
                              this.offset=  _offset;
                              this.seq   =  _seq;
              }
  }