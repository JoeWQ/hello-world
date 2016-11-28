/*
  *@aim:������ʵ��,���Ƕ���ĺ���������Ƕ��,����������ʱ��֧�ַ��غ�������,
  *@date:2015-10-19 09:55:43
  *@author:�ҽ���
  */
  package     lexer;
  import      java.util.ArrayList;
  public     class        Func     extends        Word
 {
//�����Ķ�����Դ�ļ�����
              private       final         int                            line;
//�����ķ�������
               public        final         Type                          returnType;
//�Ƿ��з���������
               public        boolean                                     hasReturnStamt;
//�������β����Ͳ����б�,ע�����ǲ��Ὣ�βε�����д����,
//���ڼ���βε������Ƿ��ظ������﷨�����׶�����֤
               public        final          ArrayList<Type>    paramList;
//�����ֶΣ����������β��б�Ϊ�յ�ʱ�򣬿���ֱ��ʹ������ֶΣ��������ٴ�������
               public        static       final        ArrayList<Type>    globalParamList=new   ArrayList<Type>();
//���캯����,_paramList���Բ�����Ϊ��,���ǳ��ȿ���Ϊ0
               public       Func(Type   _returnType,String    funcName,ArrayList<Type>    _paramList)
              {
//���ϴ��غ������ͱ�ʶ��Tag.FUNC
                              super(funcName,Tag.FUNC);
                              this.returnType=_returnType;
                              this.paramList=_paramList;
                              this.line=Lexer.lines;
//��������,�����б��е��β����Ͳ���Ϊvoid����,���Լ����Ҫ�������Լ���֤
                              for(int  i=0;i<_paramList.size();++i)
                             {
                                              if(_paramList.get(i)==Type.Void)
                                                         error("Syntax error:formal paramater of function  defination   can not be type 'void' ");
                              }
               }
//���ڴ���ȫ�ֱ�ʶ�����ϣ�����������������������
               private      Func()
              {
                          super("",Tag.FUNC);
                          this.line=Lexer.lines;
                          this.returnType=Type.Void;
                          this.paramList=Func.globalParamList;
               }
               public     void      error(String    s)
              {
                              throw   new     Error(s+this.line);
               }
               public    String     toString()
              {
                              return    returnType+"   "+lexeme;
               }
//������,����return�����
              public         static      final             Func       Null=new   Func();
//return������Χ����
              public         static      Func             Enclosing=Func.Null;
  }