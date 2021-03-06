
// DO NOT EDIT THIS FILE - it is machine generated -*- c++ -*-

#ifndef __gnu_java_awt_font_opentype_truetype_GlyphLoader__
#define __gnu_java_awt_font_opentype_truetype_GlyphLoader__

#pragma interface

#include <java/lang/Object.h>
#include <gcj/array.h>

extern "Java"
{
  namespace gnu
  {
    namespace java
    {
      namespace awt
      {
        namespace font
        {
          namespace opentype
          {
              class Hinter;
            namespace truetype
            {
                class GlyphLoader;
                class GlyphLocator;
                class GlyphMeasurer;
                class VirtualMachine;
                class Zone;
            }
          }
        }
      }
    }
  }
  namespace java
  {
    namespace awt
    {
      namespace geom
      {
          class AffineTransform;
      }
    }
    namespace nio
    {
        class ByteBuffer;
    }
  }
}

class gnu::java::awt::font::opentype::truetype::GlyphLoader : public ::java::lang::Object
{

public: // actually package-private
  GlyphLoader(::gnu::java::awt::font::opentype::truetype::GlyphLocator *, ::gnu::java::awt::font::opentype::truetype::VirtualMachine *, jint, jint, jint, ::gnu::java::awt::font::opentype::truetype::GlyphMeasurer *);
public:
  void loadGlyph(jint, jdouble, ::java::awt::geom::AffineTransform *, jboolean, ::gnu::java::awt::font::opentype::truetype::Zone *, ::gnu::java::awt::font::opentype::Hinter *);
  void loadGlyph(jint, ::java::awt::geom::AffineTransform *, ::gnu::java::awt::font::opentype::truetype::Zone *, ::gnu::java::awt::font::opentype::Hinter *);
private:
  void loadSubGlyph(jint, jdouble, ::java::awt::geom::AffineTransform *, jboolean, ::gnu::java::awt::font::opentype::truetype::Zone *, jint, jint, ::gnu::java::awt::font::opentype::Hinter *);
  void loadSimpleGlyph(jint, jdouble, ::java::awt::geom::AffineTransform *, jboolean, jint, ::java::nio::ByteBuffer *, ::gnu::java::awt::font::opentype::truetype::Zone *, jint, jint, ::gnu::java::awt::font::opentype::Hinter *);
  void loadCompoundGlyph(jint, jdouble, ::java::awt::geom::AffineTransform *, jboolean, ::java::nio::ByteBuffer *, ::gnu::java::awt::font::opentype::truetype::Zone *, jint, jint, ::gnu::java::awt::font::opentype::Hinter *);
  jdouble getDouble214(::java::nio::ByteBuffer *);
  void loadFlags(jint, ::java::nio::ByteBuffer *);
  void loadCoordinates(jint, ::java::nio::ByteBuffer *, ::gnu::java::awt::font::opentype::truetype::Zone *);
  void setPhantomPoints(jint, jint, ::gnu::java::awt::font::opentype::truetype::Zone *);
  ::gnu::java::awt::font::opentype::truetype::GlyphLocator * __attribute__((aligned(__alignof__( ::java::lang::Object)))) glyphLocator;
  ::gnu::java::awt::font::opentype::truetype::GlyphMeasurer * glyphMeasurer;
  ::gnu::java::awt::font::opentype::truetype::VirtualMachine * vm;
  jint unitsPerEm;
  JArray< jint > * contourEndPoints;
  JArray< jbyte > * pointFlags;
  static const jshort ARGS_ARE_WORDS = 1;
  static const jshort ARGS_ARE_XY_VALUES = 2;
  static const jshort ROUND_XY_TO_GRID = 4;
  static const jshort WE_HAVE_A_SCALE = 8;
  static const jshort MORE_COMPONENTS = 32;
  static const jshort WE_HAVE_AN_X_AND_Y_SCALE = 64;
  static const jshort WE_HAVE_A_TWO_BY_TWO = 128;
  static const jshort WE_HAVE_INSTRUCTIONS = 256;
  static const jshort USE_MY_METRICS = 512;
  static const jshort OVERLAP_COMPOUND = 1024;
  static const jshort SCALED_COMPONENT_OFFSET = 2048;
  static const jshort UNSCALED_COMPONENT_OFFSET = 4096;
public:
  static ::java::lang::Class class$;
};

#endif // __gnu_java_awt_font_opentype_truetype_GlyphLoader__
