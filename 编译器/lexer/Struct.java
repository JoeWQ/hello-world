/*
  *@aim:�ṹ������,�ṹ��ĳߴ���СΪ4,�������û���κε�����
  *@date:2015��10��24��18:58:48
  *@author:�ҽ���
  */
  package     lexer;
  import    java.util.ArrayList;
  import   java.util.TreeMap;
  
  //�����ǵ���һ�汾�в��Ὣ�ṹ��ĳ�Ա��������,�����ǵ��Ժ�汾�н�������������
  //��Ȼ�������������������֮��,���ǵ���������ܵ�ʵ����Ҫ�õ���̬�滮,������ǽ�Ҫ������
  //�ǳ���ϸ���ĵ�ȥ��������㷨��ԭ��
  public    class    Struct   extends    Type
 {
//�ṹ�屻�������ڵ���
             public        final        int                                  define_line;
//�ṹ�������
             public        final        String                            struct_name;
//��ʶ����
             private       final       TreeMap<String,Member>       table;
//�ṹ����ֶ���������,�ӵ�һ��˳�����һ��
             private       final       ArrayList<String>                       mem_name;
//�Խṹ����м���(��ʽ��)
             private       int                                                 offset;
             private       int                                                 mem_count;
//��������ӳ�Ա,���ư���,
//@1:��Ա��������
//@2:��Ա�����Ͳ����������Ľṹ������,�Է�ֹ���ݵĵݹ鶨��
             public        Struct(String   _name)
            {
//�ȼ���ṹ��Ķ�������4,��С4
                           super("struct "+_name,Tag.STRUCT,4,4);
                           this.struct_name=_name;
                           this.table=new    TreeMap<String,Member>();
                           this.mem_name=new   ArrayList<String>();
                           this.define_line=Lexer.lines;
             }
//��ṹ����ӳ�Ա
            public      void       addMember(String    _name,Type    _type)
           {
//����Ƿ��ڳ�Ա�ڲ��ض�����
                          if(table.get(_name) !=null  )
                                     error("syntax error:struct "+struct_name+" has same declaration of variable "+_name);
//����Ƿ��ǵݹ�����
                          if(_type == this)
                                     error("syntax error:recurisive defination of struct "+struct_name);
//��ӳ�Ա
                          if(offset%_type.alignWidth!=0)        
                                      offset+=_type.alignWidth-offset%_type.alignWidth;
//                          System.out.println("struct member "+_name+" offset:"+offset);
                          Member    _mem=new    Member(_name,_type,offset,mem_count);
//���¼���ƫ��
                         offset+=_type.width;
//��ӵ��ṹ���˽�з��ű���
                         this.mem_name.add(_name);
                         table.put(_name,_mem);
//���¼���ṹ��Ķ������Ⱥ���ռ�ݵĿռ�
                         if(mem_count==0)//��������Ϊ��һ����Ա�Ķ�������
                                   this.alignWidth=_type.alignWidth;
                         this.width=offset;
                         ++mem_count;
            }
//����һ������,�ڽṹ���в��Ҷ�Ӧ�ĳ�Ա
            public       Member          getMember(String    _mem_name)
           {
                          return      table.get(_mem_name);
            }
//
             public      String     toString()
            {
                          return     "struct@"+struct_name;
             }
             public     void         error(String    s)
           {
                         throw   new    Error("error caused by:"+s+" in  line "+define_line);
            }
  }