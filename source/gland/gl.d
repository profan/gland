module gl;

import glad.gl.enums;
import glad.gl.types;
import glad.gl.funcs;

template typeToGL(T) {

	import std.format : format;

	static if (is (T == float)) {
		enum TypeToGLenum = GL_FLOAT;
	} else static if (is (T == double)) {
		enum TypeToGLenum = GL_DOUBLE;
	} else static if (is (T == int)) {
		enum TypeToGLenum = GL_INT;
	} else static if (is (T == uint)) {
		enum TypeToGLenum = GL_UNSIGNED_INT;
	} else static if (is (T == short)) {
		enum TypeToGLenum = GL_SHORT;
	} else static if (is (T == ushort)) {
		enum TypeToGLenum = GL_UNSIGNED_SHORT;
	} else static if (is (T == byte)) {
		enum TypeToGLenum = GL_BYTE;
	} else static if (is (T == ubyte) || is(T == void)) {
		enum TypeToGLenum = GL_UNSIGNED_BYTE;
	} else {
		static assert (0, format("No type conversion found for: %s to OpenGL equivalent", T.stringof));
	}

} //typeToGL

// corresponds to usage pattern for given data
enum DrawType {

	StaticDraw = GL_STATIC_DRAW,
	StaticRead = GL_STATIC_READ,

	DynamicDraw = GL_DYNAMIC_DRAW,
	DynamicRead = GL_DYNAMIC_READ,

	StreamDraw = GL_STREAM_DRAW,
	StreamRead = GL_STREAM_READ

} //DrawType

// corresponds to OpenGL primitives
enum DrawPrimitive {

	Points = GL_POINTS,

	Lines = GL_LINES,
	LineStrip = GL_LINE_STRIP,
	LineLoop = GL_LINE_LOOP,

	Triangles = GL_TRIANGLES,
	TriangleStrip = GL_TRIANGLE_STRIP,
	TriangleFan = GL_TRIANGLE_FAN

} //DrawPrimitive

// corresponds to glBlendEquation
enum BlendEquation {

	Add = GL_FUNC_ADD,
	Sub = GL_FUNC_SUBTRACT,
	ReverseSub = GL_FUNC_REVERSE_SUBTRACT,
	Min = GL_MIN,
	Max = GL_MAX

} // BlendEquation

// corresponds to glBlendFunc
enum BlendFunc {

	Zero = GL_ZERO,
	One = GL_ONE,

	SrcColour = GL_SRC_COLOR,
	OneMinusSrcColour = GL_ONE_MINUS_SRC_COLOR,

	DstColour = GL_DST_COLOR,
	OneMinusDstColour = GL_ONE_MINUS_DST_COLOR,

	SrcAlpha = GL_SRC_ALPHA,
	OneMinusSrcAlpha = GL_ONE_MINUS_SRC_ALPHA,

	DstAlpha = GL_DST_ALPHA,
	OneMinusDstAlpha = GL_ONE_MINUS_DST_ALPHA,

	ConstantColour = GL_CONSTANT_COLOR,
	OneMinusConstantColour = GL_ONE_MINUS_CONSTANT_COLOR,

	ConstantAlpha = GL_CONSTANT_ALPHA,
	OneMinusConstantAlpha = GL_ONE_MINUS_CONSTANT_ALPHA

} // BlendFunc

// DrawParams state, is sent with every "draw" command in order to *never* have any manual state modification.
struct DrawParams {

	BlendEquation blend_eq;

	BlendFunc blend_func;

} // DrawParams

/* 
 * Possible alternative to DrawParams, would be template on what would be passed 
 *  and then we could only pass what would be necssary for the given call, 
 *  reducing overhead both in memory and run-time checking.
*/
struct TDrawParams {

} //TDrawParams

struct Shader {

} //Shader

struct Vertex {

} //Vertex

struct VertexArray {

} //VertexArray

struct Renderer {
static:

	//GL_ARRAY_BUFER_BINDING
	GLuint array_buffer_binding;

	//GL_ELEMENT_ARRAY_BUFFER_BINDING
	GLuint element_array_buffer_binding;

	//GL_VERTEX_ARRAY_BUFFER_BINDING
	GLuint vertex_array_buffer_binding;

	//GL_TEXTURE_2D
	bool texture_2d;

	//GL_TEXTURE_BINDING_2D
	GLuint texture_binding_2d;

	//GL_SCISSOR_TEST
	bool scissor_test;

	//GL_SCISSOR_BOX
	GLint[4] scissor_box;

	//GL_ALPHA_TEST
	bool alpha_test;

	//GL_ALPHA_TEST_FUNC
	GLenum alpha_test_func;

	//GL_STENCIL_TEST
	bool stencil_test;

	//GL_STENCIL_FUNC
	GLenum stencil_test_func;

	//GL_DEPTH_TEST
	bool depth_test;

	//GL_DEPTH_FUNC
	GLenum depth_test_func;

	//GL_BLEND
	bool blend_test;

	//GL_BLEND_SRC
	GLenum blend_src;

	//GL_BLEND_DST
	GLenum blend_dst;

	/* 
	 * Framebuffer Control
	*/

	//GL_DRAW_BUFFER
	//TODO: ...

	/*
	 * Functions, this is the public API
	*/

	/*
	 * Internal Helpers, not public API.
	*/

private:

	bool bindVertexArray(GLuint id) {

		if (vertex_array_buffer_binding == id) {
			return false;
		}
			
		glBindVertexArray(id);

		return true;

	} //bindVertexArray

	bool bindBuffer(GLenum type, GLuint id) {

		if (type == GL_ARRAY_BUFFER) {

			if (array_buffer_binding == id) {
				return false;
			}
				
			array_buffer_binding = id;

		} else if (type == GL_ELEMENT_ARRAY_BUFFER) {

			if (element_array_buffer_binding == id) {
				return false;
			}

			element_array_buffer_binding = id;

		}

		glBindBuffer(type, id);

		return true;

	} //bindBuffer

	bool bufferData(GLenum target, GLsizeiptr size, const GLvoid* data, GLenum usage) {

	} //bufferData

} // Renderer
