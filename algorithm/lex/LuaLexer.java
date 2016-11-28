/*
  *Lua词法分析器
  *2016-1-7 15:39:57
  */
  import    java.io.IOException;
  import    java.util.TreeMap;
  public     class     LuaLexer
 {
 //数字符号表
              static       boolean[]        DigitTable=new     boolean[255];
//字符号表
              static       boolean[]        CharTable=new     boolean[255];
//是否是首字符
              static       boolean[]        FirstCharTable=new       boolean[255];
//当前行
              static       int                    Lines;
              private     int                    peer;
              private     TreeMap<String,Token>      _lexMap;
//是否已经到达文件的尽头
              private     boolean           _fileEnd;
              static
             {
                         int     i;
                         for(i='0';i<='9';++i)//数字
                        {
                                     LuaLexer.DigitTable[i]=true;
                                     LuaLexer.CharTable[i]=true;
                         }
//字母表
                         for(i='A';i<='Z';++i)
                        {
                                     LuaLexer.CharTable[i]=true;
                                     LuaLexer.FirstCharTable[i]=true;
                         }
                         for(i='a';i<='z';++i)
                        {
                                     LuaLexer.CharTable[i]=true;
                                     LuaLexer.FirstCharTable[i]=true;
                         }
                         LuaLexer.CharTable['_']=true;
                         LuaLexer.FirstCharTable['_']=true;
              }
              public      LuaLexer()
             {
                           this.peer=' ';
                           _fileEnd=false;
                           _lexMap=new    TreeMap<String,Token>();
                           Lines=1;
//在符号表中加入词法常量
                           reserve(Word.index.property,Word.index);
              }
//保留字
              private        void     reserve(String   _word,Token   _tok)
             {
                           _lexMap.put(_word,_tok);
              }
              public     void      readChar()throws  IOException
             {
                           if( !_fileEnd )
                          {
                                      peer=FileManager.input.read();
                                      if(peer == -1)
                                     {
                                                   peer=0;
                                                   _fileEnd=true;
                                      }
                           }
              }
//判断下一字符读取
              public     boolean     readChar(int    _preChar)throws  IOException
             {             
                           readChar();
                           if(_preChar == peer)
                          {
                                        peer=' ';
                                        return    true;
                           }
                           return  false;
              }
//返回词法单元
              public       Token      scan()throws    IOException
             {
                            for(   ;    ;readChar())
                           {
                                         if(peer==' ' || peer=='\t' || peer=='\r')
                                                      continue;
                                         else if(peer == '\n')
                                        {
                                                      ++LuaLexer.Lines;
                                                      if(LuaLexer.Lines>9)
                                                           return   new  Token(0);
                                                      continue;
                                         }
                                         else
                                                      break;
                            }
//是否是数字
                            if( LuaLexer.DigitTable[peer]  )
                           {
                                       int      _ivalue=0;
                                       do
                                      {
                                                   _ivalue*=10;
                                                   _ivalue+=peer-'0';
                                                   readChar();
                                       }while(LuaLexer.DigitTable[peer]);
//查看下一个符号是否是.号
                                       if(peer != '.')
                                                     return    new    Num(_ivalue);
                                       readChar();
                                       float     _fvalue=0;
                                       float     _order=10;
                                       while( LuaLexer.DigitTable[peer]  )
                                      {
                                                      _fvalue+=(peer-'0')/_order;
                                                      _order*=10;
                                                      readChar();
                                        }
                                                   return    new    Float(_fvalue+_ivalue);
                               }
//如果是单词
                               if(LuaLexer.FirstCharTable[peer])
                              {
                                            StringBuilder    _build=new    StringBuilder();
                                            do
                                           {
                                                           _build.append((char)peer);
                                                           readChar();
                                            }while(LuaLexer.CharTable[peer]);
//用字符串查找保留字,如果找到了,就说明这是一个关键字,直接返回
                                            String     _key=_build.toString();
                                            Token    _tok=  _lexMap.get(_key);
                                            if(_tok !=null )
                                                        return   _tok;
                                            return    new   Word(_key,Tag.ID);
                                }
//加入对字符串的处理,暂时不支持转义字符
                               if(peer=='\"')
                              {
                                            StringBuilder   _build=new    StringBuilder();
                                            readChar();
                                            while(peer !='\"' && peer !=0)
                                           {
                                                         _build.append((char)peer);
                                                         readChar();
//如果需要加入对转义字符的处理的话,需要在下面加入几行代码
                                            }
                                            readChar();
                                            return  new     CString(_build.toString());
                               }
                               int    _peer=peer;
                               peer=' ';
                               return    new   Token(_peer);
              }
  }