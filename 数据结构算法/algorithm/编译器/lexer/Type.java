/*
  *@aim:����
  *@date:2015/10/6
  */
  package     lexer;
  import     java.util.HashMap;
  public    class    Type   extends    Word
 {
//Ϊ�ǻ������ͷ����ʶ����
             private    static           int        nbasicTypeIdentifier=-1;
 //�̶��Ļ�������
             public     static      final      Type    Int=new        Type("int",Tag.BASIC,4,4);
             public     static      final      Type    Float=new    Type("float",Tag.BASIC,4,4);
             public     static      final      Type    Char=new    Type("char",Tag.BASIC,1,1);
//�ִ�������
             public     static      final      Type    Bool=new     Type("bool",Tag.BASIC,4,4);
             public     static      final      Type    Struct=new    Type("struct",Tag.STRUCT,4,4);
//ָ������,�����ڹ�������
//������������void,���������� ����������ռ�ռ�����������ʵ���в���ʹ��
             public     static      final      Type    Void=new    Type("void",Tag.VOID,4,4);
//�û����������ڴ�����ռ�ݵ��ֽ���,ע��ֻ��Type������ſ����ڹ��캯���в����������,
//�����κεط��������� 
             public         int       width;
//ʹ��һ��ӳ����ѯ�����������͵�ת�����̵����ȼ�,���ص�����Խ�߱�ʾ�������Խ��
//�������ֵ���ͷ��صļ�ֵ���Ǵ���0�ģ�����ΪС�ڵ���0���������ӳ�����Ϊ�˼򻯲��ӿ캯���ĵ�����
//�����ļ������ж�
             public     static      final          HashMap<Type,Integer>     priority;
//��Ч�����ȼ�
             public     static      final         int              InvalidePriority=-1;
//ȫ�����ͷ��ű�,ÿ������һ�������;ͻὫ����ӽ�ȥ,����ȫ����ʹ����һ������
            private      static     final           HashMap<String,Struct>      globleType;
             static
            {
                              priority=new    HashMap<Type,Integer>();
                              globleType=new    HashMap<String,Struct>();
//������������ӽ�ȥ
//                              globleType.put(Type.Int.lexeme,Type.Int);
//                              globleType.put(Type.Float.lexeme,Type.Float);
//                              globleType.put(Type.Char.lexeme,Type.Char);
//                              globleType.put(Type.Bool.lexeme,Type.Bool);
//���Ժ�İ汾�����ǻ�������µı����е���������,����double
                              priority.put(Type.Float,new  Integer(16));
                              priority.put(Type.Int,new  Integer(15));
                              priority.put(Type.Char,new  Integer(14));
//�Ժ󻹻������µ���������
                              priority.put(Type.Bool,new  Integer(0));
             }
//�����ͷ��ű�������µ�����,�����ش���������,�������ֻ��������ṹ������
             public     static      Type        put(String    _name,Struct   _type)
            {
                             Struct      rtype=Type.globleType.get(_name);
                             if( rtype == null  )
                            {
                                           Type.globleType.put(_name,_type);
//�����µ����ȼ�
                           //                Type.priority.put(_type,Type.alloc());
                                           rtype=_type;
                             }
                             return   rtype;
             }
//��������������Ѿ�������
//����һ������,������Ӧ������
             public     static       Struct           get_type(String   _name)
            {
                           return     Type.globleType.get(_name);
             }
//����һ������,������ص����͵����ȼ�,���û�и�����,����Type.InvalidePriority
             public     static      int               get_priority(String   _name)
            {
                          Type     _type=Type.globleType.get(_name);
                          if( _type !=null )
                                   return    Type.priority.get(_type).intValue();
                          return   Type.InvalidePriority;
             }
//����һ�����Ͳ������ȼ�
             public     static     int              get_priority(Type   _type)
            {
                         Integer    a=Type.priority.get(_type);
                         if( a != null )
                                   return   a.intValue();
                         return   Type.InvalidePriority;
             }
//�ڴ���������,ע��,�������Ͷ������ڹ��캯���п��ԶԸ����ݽ��в���,�������ĵط�Ӧ�ý�ֹ����������
             public     int      alignWidth;
             public     Type(String    _lex,int    property,int   _width,int  _align)
            {
                           super(_lex,property);
                           this.width=_width;
                           this.alignWidth=_align;
             }
//�ж����������Ƿ�ȼ�
//����������Ϊ���Ƶȼ�
             public    boolean       equalWith(Type    _type)
            {
                          return    this.toString().equals(_type.toString());
             }
//Ϊ�ǻ������ͷ����������ȼ�,ע������Ҳ��һ�ַǻ�������
             public     static     int           alloc()
            {
                           return         --Type.nbasicTypeIdentifier;
             }
//�������������Ͳ����������ʱ�������е���������ж�
 //�Ƿ��ǿ��Խ�����ѧ���������
             public     static     boolean     isNumber(Type    _type)
            {
                           return  _type==Type.Int || _type==Type.Float || _type==Type.Char;
             }
             public     static     Type            maxType(Type   x,Type   y)
            {
//����ѧ���Ͳ��ܲ���Ƚ�
                           if( !Type.isNumber(x) ||  !Type.isNumber(y)  )
                                        return    null;
                           if(x==Type.Float || y==Type.Float)
                                        return    Type.Float;
                           else if(x==Type.Int || y==Type.Int )
                                        return    Type.Int;
                           return     Type.Char;
             }
  }