# qmake common build settings
# copyright by Stefan Roettger
# contact: snroettg at gmail

unix: INSTALL_PATH = /usr/local
win32: INSTALL_PATH = C:\

ENV_PATH = $$(GLVERTEX_PATH)
!isEmpty(ENV_PATH): INSTALL_PATH = $$ENV_PATH

unix: BULLET_INSTALL_PATH = /usr
win32: BULLET_INSTALL_PATH = C:\

QT += core opengl

message(QT_VERSION = $$QT_VERSION)
greaterThan(QT_MAJOR_VERSION, 4) {
   QT += widgets
}
greaterThan(QT_MAJOR_VERSION, 5) {
   QT += openglwidgets core5compat
}

CONFIG += c++11 warn_off
INCLUDEPATH += . .. ../glvertex ../../glvertex $$INSTALL_PATH/glvertex $$INSTALL_PATH/include
mac: CONFIG -= app_bundle

BULLET_INCLUDE_PATH = $$BULLET_INSTALL_PATH/include/bullet/
BULLET_LIBRARY_PATH = $$BULLET_INSTALL_PATH/lib

defineTest(bullet) {
   bullet_header = $$BULLET_INCLUDE_PATH/btBulletDynamicsCommon.h
   !exists($$bullet_header) {
      return(false)
   }
   return(true)
}

unix:!android:bullet(): {
   message(bullet physics found)
   DEFINES += HAVE_BULLET_PHYSICS=1
   INCLUDEPATH += $$BULLET_INCLUDE_PATH
   LIBDIR += $$BULLET_LIBRARY_PATH
   LIBS += -lBulletDynamics -lBulletCollision -lLinearMath
}

CONFIG(release, debug|release) {
  QMAKE_CFLAGS_RELEASE += -O
  QMAKE_CXXFLAGS_RELEASE += -O
}

win32: LIBS += -lopengl32

# android: LIBS += -lGLESv3

defineTest(dotdotglvertexh) {
   !exists(../glvertex.h) {
      return(false)
   }
   return(true)
}

defineTest(dotdotglvertexglvertexh) {
   !exists(../glvertex/glvertex.h) {
      return(false)
   }
   return(true)
}

defineTest(installpathglvertexglvertexh) {
   !exists($$INSTALL_PATH/glvertex/glvertex.h) {
      return(false)
   }
   return(true)
}

defineTest(installpathglvertexh) {
   !exists($$INSTALL_PATH/include/glvertex.h) {
      return(false)
   }
   return(true)
}

dotdotglvertexh(): {
   HEADERS += $$files(../glslmath*.h)
   HEADERS += $$files(../glvertex*.h)
} else {
dotdotglvertexglvertexh(): {
   HEADERS += $$files(../glvertex/glslmath*.h)
   HEADERS += $$files(../glvertex/glvertex*.h)
} else {
installpathglvertexglvertexh(): {
   HEADERS += $$files($$INSTALL_PATH/glvertex/glslmath*.h)
   HEADERS += $$files($$INSTALL_PATH/glvertex/glvertex*.h)
} else {
installpathglvertexh(): {
   HEADERS += $$files($$INSTALL_PATH/include/glslmath*.h)
   HEADERS += $$files($$INSTALL_PATH/include/glvertex*.h)
} else {
   error(unable to locate glVertex library)
}}}}

DESTDIR = $$PWD
QMAKE_PROJECT_DEPTH = 0 # force absolute paths

FILE = $$basename(_PRO_FILE_)
SOURCES += $$replace(FILE, "\\.pro", ".cpp")
