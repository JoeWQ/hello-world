/*
  *@aim:表达式
  *@date:2015/10/6
  */
  package    inter;
  import    tool.FileManager;
  import    lexer.Token;
  import    lexer.Type;
 
  public    class    Expr   extends   Node
 {
 //参与表达式的运算符和运算分量的类型,或者是最终产生的值的类型
               Token           tok;
               Type             type;
//
               public    Expr(Token   _tok,Type   _type)
              {
                            this.tok=_tok;
                            this.type=_type;
               }
//产生三地址代码,因为在本表达式的假设中,运算符和运算分量是原子的,所以只需要返回对象本身就可以
               public      Expr        gen()
              {
                            return    this;
               }
//规约,用在将表达式规约成单一的运算分量,或者为常数，或者为临时变量或者为一个标识符
               public     Expr         reduce()
              {
                            return     this;
               }
//转换为常量,用于编译时计算,子类可以选择性实现该方法,注意此函数不能再计算期间产生任何的输出
               public    Expr          reduceConstant()
              {
                           return    this;
               }
//发行跳转代码
//true_port:表达式的真值出口
//false_port:表达式的假值出口
//0表示平滑过渡
//test:判断条件
               public     void       jumping(int    true_port,int   false_port)
              {
                             emit_jump(toString(),true_port,false_port);
               }
               public     void       emit_jump(String  test,int    true_port,int    false_port)
              {
                           if( true_port!=0 && false_port!=0 )
                          {
                                         emit("if \t"+test+"\tL"+true_port);
                                         emit("jmp  L"+false_port);
                           }
                           else if( true_port !=0 )
                                         emit("if\t"+test+"\t jmp L"+true_port);
                           else if(false_port !=0)
                                         emit("iffalse\t"+test+"\t jmp L"+false_port);
//否则什么也不生成
               }
               public      String    toString()
              {
                           return       tok.toString();
               }
  }