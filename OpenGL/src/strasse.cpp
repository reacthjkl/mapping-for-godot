const char shader[] =
 "#version 120\n"
 "uniform mat4 mvp;                 // Standard: ModelViewProjection-Matrix\n"
 "\n"
 "attribute vec4 vertex_position;   // Standard: the vertex position\n"
 "varying vec4 frag_position;       // Pass position to fragment shader\n"
 "\n"
 "void main()\n"
 "{\n"
 "    gl_Position = mvp * vertex_position;\n"
 "    frag_position = vertex_position;\n"
 "}\n"
 "\n"
 "---\n"
 "\n"
 " #version 120\n"
 "varying vec4 frag_position;\n"
 "\n"
 "void main()\n"
 "{\n"
 "    // Create a chessboard pattern\n"
 "    float size = 0.5; // Size of each square\n"
 "    int num_squares = 10; // Number of squares along one axis\n"
 "    vec3 color = vec3(1.0, 1.0, 1.0); // Default color (white)\n"
 "\n"
 "    for (int i = 0; i < num_squares; ++i)\n"
 "    {\n"
 "        for (int j = 0; j < num_squares; ++j)\n"
 "        {\n"
 "            float x = frag_position.x + i * size;\n"
 "            float y = frag_position.y + j * size;\n"
 "            if (mod(floor(x / size) + floor(y / size), 2.0) == 0.0)\n"
 "            {\n"
 "                color = vec3(0.0, 0.0, 0.0); // Black square\n"
 "            }\n"
 "            else\n"
 "            {\n"
 "                color = vec3(1.0, 1.0, 1.0); // White square\n"
 "            }\n"
 "        }\n"
 "    }\n"
 "\n"
 "    gl_FragColor = vec4(color, 1.0);\n"
 "}\n";

#include <glvertex_qt_glui.h>


GLuint prog_id;

class Qt_GLWindow: public lgl_Qt_GLUI
{
public:
    lglVBO *pillar =lglLoadObj("pillar.obj");
    lglVBO *gate =lglLoadObj("wall.obj");

    Qt_GLWindow() : lgl_Qt_GLUI()
    {

    }

protected:

    void initializeOpenGL()
    {
        // put OpenGL initializations here (OpenGL context hase been created):
        prog_id = lglCompileGLSLProgram(shader);
        create_lgl_Qt_ShaderEditor("shader", &prog_id);
        glEnable(GL_DEPTH_TEST);
        glClearColor(0.56, 0.93, 0.56, 0.1);

    }
 // OpenGL rendering commands here:
    void renderOpenGL(double dt)
    {
        lglUseProgram(prog_id, false);
        // clear frame buffer
     glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        mat4 M_manip = lglGetManip(); // manipulation matrix

        mat4 M = mat4::translate(-10, 0, 0); //
        mat4 V = mat4::lookat(vec4(0, 0, 20), vec3(0, -2 , 0), vec3(0, 1, 0))* M_manip; //eye, look at, up
        mat4 P = mat4::perspective(90, (float)width()/height(), 1, 100);

        lglProjection(P);


        //gate
        mat4 Mgate = mat4::translate(20,-8,0)* mat4::rotate(90,0,1,0) ;
        lglModelView(V*Mgate);
        lglRender(gate);

        //first pillar
        mat4 M1 = mat4::translate(10, 0, 0);
        lglModelView(V * M1);
        lglRender(pillar);

        //2nd pillar
        mat4 M2 = mat4::translate(5, 0, 0);
        lglModelView(V * M2);
        lglRender(pillar);
        //3rd pillar
        mat4 M3 = mat4::translate(0, 0, 0);
        lglModelView(V * M3);
        lglRender(pillar);
        //4th pillar
        mat4 M4 = mat4::translate(-5, 0, 0);
        lglModelView(V * M4);
        lglRender(pillar);
        //5th pillar
        mat4 M5 = mat4::translate(-10, 0, 0);
        lglModelView(V * M5);
        lglRender(pillar);


        // floor
        mat4 MFloor = mat4::translate(0,-8,0);
        lglModelView(V * MFloor);
        lglColor(0.60f, 0.60f, 0.60f);
        lglBegin(LGL_QUADS);
        lglVertex(-15,0,-15);
        lglVertex( 25,0,-15);
        lglVertex( 25,0, 15);
        lglVertex(-15,0, 15);
        lglEnd();




    }

    void keyPressed(char key)
    {

    }

};

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    Qt_GLWindow main;
    main.show();



    return(app.exec());
}
