/*
  *@aim:类型
  *@date:2015/10/6
  */
  package     lexer;
  import     java.util.HashMap;
  public    class    Type   extends    Word
 {
//为非基本类型分配标识数字
             private    static           int        nbasicTypeIdentifier=-1;
 //固定的基本类型
             public     static      final      Type    Int=new        Type("int",Tag.BASIC,4,4);
             public     static      final      Type    Float=new    Type("float",Tag.BASIC,4,4);
             public     static      final      Type    Char=new    Type("char",Tag.BASIC,1,1);
//字串符类型
             public     static      final      Type    Bool=new     Type("bool",Tag.BASIC,4,4);
             public     static      final      Type    Struct=new    Type("struct",Tag.STRUCT,4,4);
//指针类型,其属于构造类型
//函数返回类型void,这里设置了 对齐数和所占空间数，但是在实际中并不使用
             public     static      final      Type    Void=new    Type("void",Tag.VOID,4,4);
//该基本类型在内存中所占据的字节数,注意只有Type的子类才可以在构造函数中操作这个数据,
//其他任何地方都不可以 
             public         int       width;
//使用一个映射表查询两个基本类型的转换过程的优先级,返回的整数越高表示其兼容性越大
//如果是数值类型返回的键值都是大于0的，否则为小于等于0，建立这个映射表是为了简化并加快函数的调用中
//参数的兼容性判断
             public     static      final          HashMap<Type,Integer>     priority;
//无效的优先级
             public     static      final         int              InvalidePriority=-1;
//全局类型符号表,每次遇到一个新类型就会将其添加进去,并在全剧中使用这一个类型
            private      static     final           HashMap<String,Struct>      globleType;
             static
            {
                              priority=new    HashMap<Type,Integer>();
                              globleType=new    HashMap<String,Struct>();
//将基本类型添加进去
//                              globleType.put(Type.Int.lexeme,Type.Int);
//                              globleType.put(Type.Float.lexeme,Type.Float);
//                              globleType.put(Type.Char.lexeme,Type.Char);
//                              globleType.put(Type.Bool.lexeme,Type.Bool);
//在以后的版本中我们还会加入新的必须有的数据类型,例如double
                              priority.put(Type.Float,new  Integer(16));
                              priority.put(Type.Int,new  Integer(15));
                              priority.put(Type.Char,new  Integer(14));
//以后还会增加新的数据类型
                              priority.put(Type.Bool,new  Integer(0));
             }
//向类型符号表中添加新的类型,并返回处理后的类型,这个函数只用来保存结构体类型
             public     static      Type        put(String    _name,Struct   _type)
            {
                             Struct      rtype=Type.globleType.get(_name);
                             if( rtype == null  )
                            {
                                           Type.globleType.put(_name,_type);
//分配新的优先级
                           //                Type.priority.put(_type,Type.alloc());
                                           rtype=_type;
                             }
                             return   rtype;
             }
//下面的三个方法已经废弃了
//给定一个名字,返回相应的类型
             public     static       Struct           get_type(String   _name)
            {
                           return     Type.globleType.get(_name);
             }
//给定一个名字,返回相关的类型的优先级,如果没有该类型,返回Type.InvalidePriority
             public     static      int               get_priority(String   _name)
            {
                          Type     _type=Type.globleType.get(_name);
                          if( _type !=null )
                                   return    Type.priority.get(_type).intValue();
                          return   Type.InvalidePriority;
             }
//给定一个类型查找优先级
             public     static     int              get_priority(Type   _type)
            {
                         Integer    a=Type.priority.get(_type);
                         if( a != null )
                                   return   a.intValue();
                         return   Type.InvalidePriority;
             }
//内存对齐的粒度,注意,除了类型对象本身在构造函数中可以对该数据进行操作,在其他的地方应该禁止操作该数据
             public     int      alignWidth;
             public     Type(String    _lex,int    property,int   _width,int  _align)
            {
                           super(_lex,property);
                           this.width=_width;
                           this.alignWidth=_align;
             }
//判断两个类型是否等价
//我们这里归结为名称等价
             public    boolean       equalWith(Type    _type)
            {
                          return    this.toString().equals(_type.toString());
             }
//为非基本类型分配类型优先级,注意数组也是一种非基本类型
             public     static     int           alloc()
            {
                           return         --Type.nbasicTypeIdentifier;
             }
//当两个基本类型参与混合运算的时候所进行的最大类型判断
 //是否是可以进行数学运算的类型
             public     static     boolean     isNumber(Type    _type)
            {
                           return  _type==Type.Int || _type==Type.Float || _type==Type.Char;
             }
             public     static     Type            maxType(Type   x,Type   y)
            {
//非数学类型不能参与比较
                           if( !Type.isNumber(x) ||  !Type.isNumber(y)  )
                                        return    null;
                           if(x==Type.Float || y==Type.Float)
                                        return    Type.Float;
                           else if(x==Type.Int || y==Type.Int )
                                        return    Type.Int;
                           return     Type.Char;
             }
  }