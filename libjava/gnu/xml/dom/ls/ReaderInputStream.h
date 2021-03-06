
// DO NOT EDIT THIS FILE - it is machine generated -*- c++ -*-

#ifndef __gnu_xml_dom_ls_ReaderInputStream__
#define __gnu_xml_dom_ls_ReaderInputStream__

#pragma interface

#include <java/io/InputStream.h>
#include <gcj/array.h>

extern "Java"
{
  namespace gnu
  {
    namespace xml
    {
      namespace dom
      {
        namespace ls
        {
            class ReaderInputStream;
        }
      }
    }
  }
}

class gnu::xml::dom::ls::ReaderInputStream : public ::java::io::InputStream
{

public:
  ReaderInputStream(::java::io::Reader *);
public: // actually package-private
  virtual void setEncoding(::java::lang::String *);
public:
  virtual jint read();
  virtual jint read(JArray< jbyte > *);
  virtual jint read(JArray< jbyte > *, jint, jint);
  virtual void close();
  virtual jboolean markSupported();
  virtual void mark(jint);
  virtual void reset();
  virtual jlong skip(jlong);
  virtual jint available();
  virtual ::java::lang::String * toString();
private:
  ::java::io::Reader * __attribute__((aligned(__alignof__( ::java::io::InputStream)))) reader;
  ::java::lang::String * encoding;
  JArray< jbyte > * extra;
  jint pos;
  JArray< jbyte > * extra_marked;
  jint pos_marked;
public:
  static ::java::lang::Class class$;
};

#endif // __gnu_xml_dom_ls_ReaderInputStream__
