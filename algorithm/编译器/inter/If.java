/*
  *@aim:If���
  *@date:2015/10/7
  */
  package    inter;
  import     lexer.Type;
  public     class    If   extends     Stamt
 {
//if�����������ʽ,������
              private       Expr       expr;
              private       Stamt     stamt;
              
              public    If(Expr    _expr,Stamt   _stamt)
             {
                             this.expr=_expr;
                             this.stamt=_stamt;
//�����ʽ����
                             if(_expr.type != Type.Bool)
                                        error("syntax error in statment 'if' ,caused by no boolean express.");
              }
//���ɴ���
              public    void     gen(int    _after,int   _before)
             {
                             this.expr.jumping(0,_after);
                             int     label=new_label();
//���Ŀ�ʼ
                             emit_label(label);  
                             this.stamt.gen(_after,label);
              }
  }