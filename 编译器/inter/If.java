/*
  *@aim:If语句
  *@date:2015/10/7
  */
  package    inter;
  import     lexer.Type;
  public     class    If   extends     Stamt
 {
//if语句的条件表达式,和语句块
              private       Expr       expr;
              private       Stamt     stamt;
              
              public    If(Expr    _expr,Stamt   _stamt)
             {
                             this.expr=_expr;
                             this.stamt=_stamt;
//检测表达式类型
                             if(_expr.type != Type.Bool)
                                        error("syntax error in statment 'if' ,caused by no boolean express.");
              }
//生成代码
              public    void     gen(int    _after,int   _before)
             {
                             this.expr.jumping(0,_after);
                             int     label=new_label();
//语句的开始
                             emit_label(label);  
                             this.stamt.gen(_after,label);
              }
  }