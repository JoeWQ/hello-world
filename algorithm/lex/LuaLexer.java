/*
  *Lua�ʷ�������
  *2016-1-7 15:39:57
  */
  import    java.io.IOException;
  import    java.util.TreeMap;
  public     class     LuaLexer
 {
 //���ַ��ű�
              static       boolean[]        DigitTable=new     boolean[255];
//�ַ��ű�
              static       boolean[]        CharTable=new     boolean[255];
//�Ƿ������ַ�
              static       boolean[]        FirstCharTable=new       boolean[255];
//��ǰ��
              static       int                    Lines;
              private     int                    peer;
              private     TreeMap<String,Token>      _lexMap;
//�Ƿ��Ѿ������ļ��ľ�ͷ
              private     boolean           _fileEnd;
              static
             {
                         int     i;
                         for(i='0';i<='9';++i)//����
                        {
                                     LuaLexer.DigitTable[i]=true;
                                     LuaLexer.CharTable[i]=true;
                         }
//��ĸ��
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
//�ڷ��ű��м���ʷ�����
                           reserve(Word.index.property,Word.index);
              }
//������
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
//�ж���һ�ַ���ȡ
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
//���شʷ���Ԫ
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
//�Ƿ�������
                            if( LuaLexer.DigitTable[peer]  )
                           {
                                       int      _ivalue=0;
                                       do
                                      {
                                                   _ivalue*=10;
                                                   _ivalue+=peer-'0';
                                                   readChar();
                                       }while(LuaLexer.DigitTable[peer]);
//�鿴��һ�������Ƿ���.��
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
//����ǵ���
                               if(LuaLexer.FirstCharTable[peer])
                              {
                                            StringBuilder    _build=new    StringBuilder();
                                            do
                                           {
                                                           _build.append((char)peer);
                                                           readChar();
                                            }while(LuaLexer.CharTable[peer]);
//���ַ������ұ�����,����ҵ���,��˵������һ���ؼ���,ֱ�ӷ���
                                            String     _key=_build.toString();
                                            Token    _tok=  _lexMap.get(_key);
                                            if(_tok !=null )
                                                        return   _tok;
                                            return    new   Word(_key,Tag.ID);
                                }
//������ַ����Ĵ���,��ʱ��֧��ת���ַ�
                               if(peer=='\"')
                              {
                                            StringBuilder   _build=new    StringBuilder();
                                            readChar();
                                            while(peer !='\"' && peer !=0)
                                           {
                                                         _build.append((char)peer);
                                                         readChar();
//�����Ҫ�����ת���ַ��Ĵ���Ļ�,��Ҫ��������뼸�д���
                                            }
                                            readChar();
                                            return  new     CString(_build.toString());
                               }
                               int    _peer=peer;
                               peer=' ';
                               return    new   Token(_peer);
              }
  }