/*
  *@aim:do-whileѭ��
  *@date:2015-10-07 11:12:36
  */
  package    inter;
  import    lexer.Type;
  
  public    class    Do   extends    Stamt
 {
             private       Expr      expr;
             private       Stamt    stamt;
             
             public     Do()
            {
             }
             public     void   init(Expr    _expr,Stamt   _stamt)
            {
                          this.expr=_expr;
                          this.stamt=_stamt;
                          if(_expr.type != Type.Bool)
                                   error("syntax error in 'do' ,caused by no matched express type.");
 //                         System.out.println("_exp:"+_expr);
             }
//���ɴ���
            public    void    gen(int  _after,int  _before)
           {
//ע�����ɵ�ǰ������
                          this.after=_after;

                          int    label=new_label();
                          this.before=label;//continue�����Ҫ��ת���������ʽ���㴦����������ѭ����Ŀ�ʼ

                          stamt.gen(label,_before);
                          emit_label(label);
                          
                          expr.jumping(_before,0);
            }   
  }