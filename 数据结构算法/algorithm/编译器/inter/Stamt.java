/*
  *@aim:���
  *@date:2015/10/7
  */
  package    inter;
  
  public    class    Stamt    extends    Node
 {
//������һ��Ŀ��ָ����
              public      int         after;
//���Ŀ�ʼ�����
              public      int         before;
//���ʽ
              private     Expr         expr;
              public      Stamt()
             {
              }
//�˹��캯��ֻ��һ����װ��,Ϊ�˰�װ��ֵ���,�������һ����ֵ���,�ᱨ�﷨����
//���ʽ��Ҫ��,��Ҫ��ÿһ�б��ʽ���ܲ���������
              public      Stamt(Expr     _expr)
             {
                           this.expr=_expr;
                           if(!(_expr   instanceof  Assign) && !(_expr instanceof  AssignArray) && !(_expr  instanceof AssignStruct))
                                       error("syntax error:'"+_expr+"' is not an  expression.");
              }
//����������,after�������֮��ĵ�һ��ָ��ĵ�ַ
//before�������ĵ�һ��ָ��ĵ�ַ
              public     void      gen(int    _after,int    _before)
             {
                          if(expr !=null  )
                                  expr.gen();
              }
              public     static     Stamt     Null=new    Stamt();
//����break�����
              public     static     Stamt     Enclosing=Stamt.Null;
  }