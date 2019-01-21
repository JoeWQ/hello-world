/*
  *@aim:�﷨���������,�Ǳ��ʽ������ڵ������
  *@date:2015/10/6
  */
  package    inter;
  import     tool.FileManager;
  import     lexer.Lexer;
  import     lexer.Func;
  import     lexer.Type;
  import     java.util.ArrayList;
  public    class    Node
 {
//��ǰ�ڵ���Դ�����ļ����������к�
              int             line;
              static        int          labels=0;
//��¼��������Ŀ��һ���ļ���
              private      static     int         func_count=0;
              public       Node()
             {
                           line=Lexer.lines;
              }
//��ӡ������Ϣ���˳�
             public     void     error(String   err)
            {
                          throw    new    Error("Error  near line "+this.line+" caused by "+err);
             }
//�������
             public      int          new_label()
            {
                          return     ++labels;
             }
//���б�ǩ
             public  void    emit_label(int   label)
            {
                         FileManager.output.print("L"+label+":");
             }
//�����ַ���
             public   static  void   emit(String   s)
            {
                         FileManager.output.println("\t\t\t\t"+s);
             }
//����ȫ�ֱ�����ֵ����
             public    static     void    emit_globle(String    s)
            {
                        FileManager.output.println("\t"+s);
             }
//��������
//paramName�βε�����
             public    static    void    emit(Func    func,ArrayList<String>   paramName)
            {
                           ArrayList<Type>       paramList=func.paramList;
                           StringBuilder  build;
                           if(func_count>0)
                                   build=new    StringBuilder("\n\n\t"); 
                           else
                                   build=new   StringBuilder();
//��������
                           build.append("\t");
                           build.append(func.toString()).append("");
                           if(paramName!=null )
                          {
                                                    build.append(":\t");
                                                    int     i=0;
                                                    for(  ;i<paramList.size();++i)
                                                                 build.append(paramList.get(i)).append("\t").append(paramName.get(i)).append(",");
//ɾ�����Ķ���
                                                    build.deleteCharAt(build.length()-1);
                            }
                            FileManager.output.println(build.toString());
                            ++Node.func_count;
             }
  }