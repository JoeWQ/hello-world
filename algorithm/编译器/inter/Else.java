/*
  *@aim:if-else语句
  *@date:2015-10-07 10:54:21
  */
  package    inter;
  import    lexer.Type;
  import    lexer.Word;
  
  public    class    Else    extends   Stamt
 {
//if - else语句的表达式和语句
              private    Expr       expr;
              private    Stamt     stamt1;
              private    Stamt     stamt2;
              
              public    Else(Expr   _expr,Stamt  _stamt1,Stamt   _stamt2)
             {
                            this.expr=_expr;
                            this.stamt1=_stamt1;
                            this.stamt2=_stamt2;
                            if(_expr.type != Type.Bool )
                                       error("syntax error in else statment,caused by no matched express type,required bool,but "+_expr.type);
              }
//生成三地址代码
              public    void     gen(int    _after,int   _before)
             {
                             int    label=new_label();//stamt1语句的开头
                             int    label2=new_label();//else语句的开头
                             expr.jumping(0,label2);
                             emit_label(label);
                             stamt1.gen(_after,label);
                             emit("jmp  L"+_after);
                             
                             emit_label(label2);
                             stamt2.gen(_after,label2);
              }
  }