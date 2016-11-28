/*
  *@aim:标识符
  *@date:2015/10/6
  */
  package    inter;
  import      lexer.Word;
  import      lexer.Type;
  public      class     Id    extends   Expr
 {
//全局标示,变量所处的位置
               public     static      final        int         StaticArea=0;//位于静态区
//位于栈帧的上面存放形参的区域,也就是返回地址的上面
               public     static      final        int         StackTop=1;
//位于栈帧的下面,存放栈帧临时变量
               public     static      final        int         StaticBottom=2;
 //offset:相对地址
 //作为词法单元的词素和类型
               public      final       int     offset;
               public      Id(Word   word,Type   type,int   _offset)
              {
                            super(word,type);
                            this.offset=_offset;
               }
  }