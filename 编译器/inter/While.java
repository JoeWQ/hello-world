/*
  *@aim:ѭ�����
  *@date:2015/10/7
  */
  package    inter;
  import      lexer.Type;
  import      lexer.Word;
  //�ڱ����У����ǲ��Ὣwhile���ת��Ϊdo-while��䣬������ܽ�������һ���汾ʵ��
  public    class    While    extends    Stamt
 {
              private      Expr       expr;
              private      Stamt     stamt;
              
              public    While()
             {
              }
              public    void    init(Expr    _expr,Stamt   _stamt)
             {
                            this.expr=_expr;
                            this.stamt=_stamt;
                            if(_expr.type != Type.Bool)
                                      error("syntax error in  while express caused by no matched component,require boolean,but "+_expr.type);
              }
//���ɴ���,��whileѭ��ת����do-whileѭ��
              public    void     gen(int   _after,int   _before)
             {
//��¼�����ĺ�̺�ǰ��,ע�����ɵ�ǰ��
                             int    label=new_label();
                             int    label2=new_label();
                             this.after=_after;
                             this.before=label2;
//��ת��ĩβ
                             expr.jumping(0,_after);
//���Ŀ�ʼ
                             emit_label(label);
                             stamt.gen(label2,label);
                             emit_label(label2);
                             expr.jumping(label,0);
               }
  }