/*
  *@aim:逻辑与运算
  *@date:2015/10/7
  */
  package    inter;
  import      lexer.Word;
  import      lexer.Type;
  import      lexer.Token;
  
  public    class    And     extends    Logic
 {
              public     And(Token   tok,Expr    _left,Expr    _right)
             {
                          super(tok,_left,_right);
//                          System.out.println("And    left expr:  "+_left +"  right expr: "+_right);
              }
//跳转指令,注意其在do-while语句中的表现,特别是调用jumping(n,0);n>0中语句的表现
//如果true_port!=0 && false_port!=0程序不会有二义性
              public    void      jumping(int    true_port,int    false_port)
             {
                            int   label=false_port!=0?false_port:new_label();
//如果第一个表达式为假,剩下的语句就不用再计算可以直接跳过,但是如果false_port为0就表示调用者希望平滑过渡
//所以只需要跳过下一个判断语句即可,如果false_port不为0可以放心跳转
                            this.left.jumping(0,label);
                            this.right.jumping(true_port,false_port);
                            if(false_port==0)
                                      emit_label(label);
              }
  }