module gland.gl;

import core.stdc.stdio : printf;
import std.typecons : tuple, Tuple;

import glad.gl.enums;
import glad.gl.types;
import glad.gl.funcs;

/**
 * Misc Types
*/

alias GLColour = float[4];

/**
 * Public Helper Functions
*/

/**
 * Converts an integer representing a colour, for example 0x428bca into a 4 element
 * int array for passing to OpenGL.
*/

nothrow pure @nogc
GLfloat[4] to(T : GLfloat[4])(int colour, ubyte alpha = 255) {

	GLfloat[4] gl_colour = [ //mask out r, g, b components from int
		cast(float)cast(ubyte)(colour>>16)/255,
		cast(float)cast(ubyte)(colour>>8)/255,
		cast(float)cast(ubyte)(colour)/255,
		cast(float)cast(ubyte)(alpha)/255
	];

	return gl_colour;

} //to!GLfloat[4]

/**
 * Converts a GLenum representation of a value to a c string representation,
 * for use with debug printing of OpenGL info, from debug callbacks for example.
*/

nothrow pure @nogc
const (char*) to(T : char*)(GLenum value) {

    switch (value) {

        // sources
        case GL_DEBUG_SOURCE_API: return "API";
        case GL_DEBUG_SOURCE_WINDOW_SYSTEM: return "Window System";
        case GL_DEBUG_SOURCE_SHADER_COMPILER: return "Shader Compiler";
        case GL_DEBUG_SOURCE_THIRD_PARTY: return "Third Party";
        case GL_DEBUG_SOURCE_APPLICATION: return "Application";
        case GL_DEBUG_SOURCE_OTHER: return "Other";

        // error types
        case GL_DEBUG_TYPE_ERROR: return "Error";
        case GL_DEBUG_TYPE_DEPRECATED_BEHAVIOR: return "Deprecated Behaviour";
        case GL_DEBUG_TYPE_UNDEFINED_BEHAVIOR: return "Undefined Behaviour";
        case GL_DEBUG_TYPE_PORTABILITY: return "Portability";
        case GL_DEBUG_TYPE_PERFORMANCE: return "Performance";
        case GL_DEBUG_TYPE_MARKER: return "Marker";
        case GL_DEBUG_TYPE_PUSH_GROUP: return "Push Group";
        case GL_DEBUG_TYPE_POP_GROUP: return "Pop Group";
        case GL_DEBUG_TYPE_OTHER: return "Other";

        // severity markers
        case GL_DEBUG_SEVERITY_HIGH: return "High";
        case GL_DEBUG_SEVERITY_MEDIUM: return "Medium";
        case GL_DEBUG_SEVERITY_LOW: return "Low";
        case GL_DEBUG_SEVERITY_NOTIFICATION: return "Notification";

        default: return "(undefined)";

    }

} //to!(const (char*))(GLenum)

/**
 * UDA's for defining properties in vertex structures.
*/

struct VertexAttribDivisor_ {
	GLuint divisor;
} // VertexAttribDivisor

@property VertexAttribDivisor(GLuint divisor) { // @suppress(dscanner.style.phobos_naming_convention)
	return VertexAttribDivisor_(divisor);
} // VertexAttribDivisor

// attribute normalization in structures
struct Normalized_ {

	bool is_normalized;

} // Normalized

@property Normalized() { // @suppress(dscanner.style.phobos_naming_convention)
	return Normalized_();
} // normalized

template TypeToGL(T) {

	import std.format : format;

	static if (is (T == float)) {
		enum TypeToGL = GL_FLOAT;

	} else static if (is (T == double)) {
		enum TypeToGL = GL_DOUBLE;

	} else static if (is (T == int)) {
		enum TypeToGL = GL_INT;

	} else static if (is (T == uint)) {
		enum TypeToGL = GL_UNSIGNED_INT;

	} else static if (is (T == short)) {
		enum TypeToGL = GL_SHORT;

	} else static if (is (T == ushort)) {
		enum TypeToGL = GL_UNSIGNED_SHORT;

	} else static if (is (T == byte)) {
		enum TypeToGL = GL_BYTE;

	} else static if (is (T == ubyte) || is(T == void)) {
		enum TypeToGL = GL_UNSIGNED_BYTE;

	} else {
		static assert (0, format("No type conversion found for: %s to OpenGL equivalent.", T.stringof));
	}

} // TypeToGL

// corresponds to targets to which OpenGL buffer objects are bound
enum BufferTarget {

	ArrayBuffer = GL_ARRAY_BUFFER,
	CopyReadBuffer = GL_COPY_READ_BUFFER,
	CopyWriteBuffer = GL_COPY_WRITE_BUFFER,
	ElementArrayBuffer = GL_ELEMENT_ARRAY_BUFFER,
	PixelPackBuffer = GL_PIXEL_PACK_BUFFER,
	PixelUnpackBuffer = GL_PIXEL_UNPACK_BUFFER,
	TextureBuffer = GL_TEXTURE_BUFFER,
	TransformFeedbackBuffer = GL_TRANSFORM_FEEDBACK_BUFFER,
	UniformBuffer = GL_UNIFORM_BUFFER

} // BufferTarget

enum ShaderType {

	VertexShader = GL_VERTEX_SHADER,
	FragmentShader = GL_FRAGMENT_SHADER,
	GeometryShader = GL_GEOMETRY_SHADER

} // ShaderType

// corresponds to usage pattern for given data
enum DrawHint {

	StaticDraw = GL_STATIC_DRAW,
	StaticRead = GL_STATIC_READ,

	DynamicDraw = GL_DYNAMIC_DRAW,
	DynamicRead = GL_DYNAMIC_READ,

	StreamDraw = GL_STREAM_DRAW,
	StreamRead = GL_STREAM_READ

} // DrawHint

// corresponds to OpenGL primitives
enum DrawPrimitive {

	Points = GL_POINTS,

	Lines = GL_LINES,
	LineStrip = GL_LINE_STRIP,
	LineLoop = GL_LINE_LOOP,

	Triangles = GL_TRIANGLES,
	TriangleStrip = GL_TRIANGLE_STRIP,
	TriangleFan = GL_TRIANGLE_FAN

} // DrawPrimitive

// corresponds to glBlendEquation
enum BlendEquation {

	Add = GL_FUNC_ADD,
	Subtract = GL_FUNC_SUBTRACT,
	ReverseSubtract = GL_FUNC_REVERSE_SUBTRACT,
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

enum ShadingType {

	Smooth = GL_SMOOTH,
	Flat = GL_FLAT

} // ShadingType

// DrawParams state, is sent with every "draw" command in order to *never* have any manual state modification.
struct DrawParams {

	// corresponds to GL_BLEND_TEST, GL_CULL_FACE, etc..
	RendererState state;

	// GL_BLEND_TEST
	BlendFunc blend_src, blend_dst;
	BlendEquation blend_eq;

} // DrawParams

/**
 * Possible alternative to DrawParams, would be template on what would be passed 
 *  and then we could only pass what would be necssary for the given call, 
 *  reducing overhead both in memory and run-time checking.
*/
struct TDrawParams {

} // TDrawParams

struct ClearParams {

	float[4] colour;
	bool stencil;
	bool depth;

} // ClearParams

nothrow @nogc
bool checkShaderError(GLuint shader, GLuint flag, bool is_program) {

	GLint result;

	(is_program) ? glGetProgramiv(shader, flag, &result)
				: glGetShaderiv(shader, flag, &result);

	if (result == GL_FALSE) {

		GLchar[256] log; //FIXME this is potentially fatal
		(is_program) ? glGetProgramInfoLog(shader, log.sizeof, null, log.ptr)
			: glGetShaderInfoLog(shader, log.sizeof, null, log.ptr);

		printf("[OpenGL] Error %s\n", log.ptr);
		return false;

	}

	return true;

} // checkShaderError

nothrow @nogc
GLuint compileShader(const(GLchar*)* shader_source, ShaderType shader_type) {

	GLuint new_shader = glCreateShader(shader_type);
	if (new_shader == 0) { return 0; } // FAILED, TODO: return proper error

	glShaderSource(new_shader, 1, shader_source, null);
	glCompileShader(new_shader);

	bool result = checkShaderError(new_shader, GL_COMPILE_STATUS, false);

	if (!result) {
		glDeleteShader(new_shader);
		return 0;
	}

	return new_shader;

} // compileShader

nothrow @nogc
GLuint createShaderProgram(in GLuint[] shader_ids, in AttribTuple[] attribs) {

	GLuint program = glCreateProgram();

	foreach(i, shader; shader_ids) {
		glAttachShader(program, shader);
	}

	foreach (ref attr; attribs) {
		glBindAttribLocation(program, attr.offset, attr.identifier.ptr);
	}

	glLinkProgram(program);
	if (!checkShaderError(program, GL_LINK_STATUS, true)) {
		glDeleteShader(program);
		return 0;
	}

	glValidateProgram(program);
	if (!checkShaderError(program, GL_VALIDATE_STATUS, true)) {
		glDeleteShader(program);
		return 0;
	}

	return program;

} // createShaderProgram

alias AttribTuple = Tuple!(string, "identifier", int, "offset");
struct Shader(immutable ShaderType[] shader_types, immutable AttribTuple[] attributes, UniformStructType...) {

	import std.string : format;
	static assert(UniformStructType.length == 0 || UniformStructType.length == 1, "expected either no uniform struct, or a single struct.");

	static if (UniformStructType.length == 1) {
		alias UniformStruct = UniformStructType[0];
		mixin(q{GLint[%d] uniforms_;}.format(PODMembers!UniformStructType.length));
	}

	GLuint program_;
	@disable this(this);
	@disable ref Shader opAssign(ref Shader);
	
	enum Error {
	
		Success = "Shader successfully compiled!"
	
	} // Error

	static string createFunction(immutable ShaderType[] shaders) {

		import std.algorithm : map, joiner;
		import std.range : enumerate;
		import std.array : appender;

		auto buffer = appender!string();

		buffer ~= q{nothrow static Error compile(ref Shader new_shader, %s) {
			%s
		}}.format(shaders.enumerate.map!(e => q{const (char*)* source_%d}.format(e.index)).joiner(","), createCompiler(shaders));

		return buffer.data();

	} // createFunction

	static string createCompiler(immutable ShaderType[] shaders) {

		import std.algorithm : map, joiner;
		import std.range : enumerate;
		import std.array : appender;
		import std.string : format;

		auto buffer = appender!string();

		foreach (i, shader; shaders) {
		buffer ~= q{
			GLuint shader_%d = compileShader(source_%d, ShaderType.%s);}.format(i, i, shader);
		}

		buffer ~= q{
			GLuint[%d] shader_ids = [%s];}.format(shaders.length, map!(e => "shader_%d".format(e.index))(shaders.enumerate).joiner(","));

		// resolve uniform locations
		buffer ~= q{
			new_shader.program_ = createShaderProgram(shader_ids, attributes);

			static if (UniformStructType.length == 1) {
				foreach (i, m; PODMembers!UniformStruct) {

					GLint res = glGetUniformLocation(new_shader.program_, m);

					enum error = format("failed to get uniform location for: %s (maybe it was optimized out?)", m);
					if (res == -1) {
						assert(0, error);
					}

					new_shader.uniforms_[i] = res;

				}
			}

		};

		// linked into program now, delete for now.
		foreach (i, shader; shaders) {
			buffer ~= q{
			glDetachShader(new_shader.program_, shader_%d);}.format(i);
		}

		foreach (i, shader; shaders) {
			buffer ~= q{
			glDeleteShader(shader_%d);}.format(i);
		}

		buffer ~= q{
			return Error.Success;
		};

		return buffer.data();

	} // createCompiler

	/* generator */
	mixin(createFunction(shader_types));

	@nogc
	nothrow
	~this() {

		glDeleteProgram(program_);

	} // ~this

	@nogc
	nothrow
	@property {

		GLuint handle() {
			return program_;
		} // handle

	}

} // Shader

struct ComputeShader {

	private {

		GLuint handle_;

	}

	auto compute(Args...)(Args args) {

	} // compute

	@property
	ref GLuint handle() {
		return handle_;
	} // handle

} // ComputeShader

enum InternalTextureFormat {

	/* RGBA */

	RGBA = GL_RGBA,
	RGBA8 = GL_RGBA8,
	RGBA8UI = GL_RGBA8UI,
	RGBA8_SNORM = GL_RGBA8_SNORM,

	RGBA16 = GL_RGBA16,
	RGBA16F = GL_RGBA16F,
	RGBA16I = GL_RGBA16I,
	RGBA16UI = GL_RGBA16UI,
	RGBA16_SNORM = GL_RGBA16_SNORM,

	RGBA32F = GL_RGBA32F,
	RGBA32I = GL_RGBA32I,
	RGBA32UI = GL_RGBA32UI,

	/* RGB */

	RGB = GL_RGB,
	RGB8 = GL_RGB8,
	RGB8UI = GL_RGB8UI,
	RGB8_SNORM = GL_RGB8_SNORM,

	RGB16 = GL_RGB16,
	RGB16F = GL_RGB16F,
	RGB16I = GL_RGB16I,
	RGB16UI = GL_RGB16UI,
	RGB16_SNORM = GL_RGB16_SNORM,

	RGB32F = GL_RGB32F,
	RGB32I = GL_RGB32I,
	RGB32UI = GL_RGB32UI,

	/* RG */

	RG8 = GL_RG8,
	RG8I = GL_RG8I,
	RG8UI = GL_RG8UI,
	RG8_SNORM = GL_RG8_SNORM,

	RG16 = GL_RG16,
	RG16F = GL_RG16F,
	RG16I = GL_RG16I,
	RG16UI = GL_RG16UI,
	RG16_SNORM = GL_RG16_SNORM,

	RG32F = GL_RG32F,
	RG32I = GL_RG32I,
	RG32UI = GL_RG32UI,

	/* R */

	R8 = GL_R8,
	R8I = GL_R8I,
	R8UI = GL_R8UI,

	R16F = GL_R16F,
	R16I = GL_R16I,
	R16UI = GL_R16UI,
	R16_SNORM = GL_R16_SNORM,

	R32F = GL_R32F,
	R32I = GL_R32I,
	R32UI = GL_R32UI,

	/* ESO */

	SRGB8 = GL_SRGB8,
	SRGB8_ALPHA8 = GL_SRGB8_ALPHA8,

	RGB9_E5 = GL_RGB9_E5,
	RGB10_A2 = GL_RGB10_A2,
	RGB10_A2UI = GL_RGB10_A2UI,
	R11F_G11F_B10F = GL_R11F_G11F_B10F,

	COMPRESSED_RG_RGTC2 = GL_COMPRESSED_RG_RGTC2,
	COMPRESSED_SIGNED_RG_RGTC2 = GL_COMPRESSED_SIGNED_RG_RGTC2,

	COMPRESSED_RED_RGTC1 = GL_COMPRESSED_RED_RGTC1,
	COMPRESSED_SIGNED_RED_RGTC1 = GL_COMPRESSED_SIGNED_RED_RGTC1,

	/* DEPTH */

	DEPTH_COMPONENT32F = GL_DEPTH_COMPONENT32F,
	DEPTH_COMPONENT24 = GL_DEPTH_COMPONENT24,
	DEPTH_COMPONENT16 = GL_DEPTH_COMPONENT16,
	DEPTH32F_STENCIL8 = GL_DEPTH32F_STENCIL8,
	DEPTH24_STENCIL8 = GL_DEPTH24_STENCIL8

} // InternalTextureFormat

enum PixelFormat {

	Red = GL_RED,
	RG = GL_RG,
	RGB = GL_RGB,
	BGR = GL_BGR,
	RGBA = GL_RGBA,
	BGRA = GL_BGRA,

	DepthComponent = GL_DEPTH_COMPONENT,
	DepthStencil = GL_DEPTH_STENCIL

} // PixelFormat

enum TextureFiltering {

	Nearest = GL_NEAREST,
	Linear = GL_LINEAR

} // TextureFiltering

enum TextureWrapping {

	ClampToEdge = GL_CLAMP_TO_EDGE,
	MirroredRepeat = GL_MIRRORED_REPEAT,
	Repeat = GL_REPEAT

} // TextureWrapping

enum TextureType {

	Texture1D = GL_TEXTURE_1D,
	Texture2D = GL_TEXTURE_2D,
	Texture3D = GL_TEXTURE_3D,

	Texture1DArray = GL_TEXTURE_1D_ARRAY,
	Texture2DArray = GL_TEXTURE_2D_ARRAY

} // TextureType

enum PixelPack {

	One = 1,
	Two = 2,
	Four = 4,
	Eight = 8

} // PixelPack

struct TextureParams {

	InternalTextureFormat internal_format;
	PixelFormat pixel_format;

	/* optional parameters, defaults specified */
	TextureFiltering filtering = TextureFiltering.Nearest;
	TextureWrapping wrapping = TextureWrapping.ClampToEdge;

	/* word alignment by default */
	PixelPack pack_alignment = PixelPack.Four;
	PixelPack unpack_alignment = PixelPack.Four;

	/* level of detail */
	int min_lod, max_lod;

	/* mipmapping level */
	int mipmap_base_level, mipmap_max_level;

} // TextureParams

struct TextureUnit_ {
	uint unit;
} // TextureUnit_

@property TextureUnit(uint unit) { // @suppress(dscanner.style.phobos_naming_convention)
	return TextureUnit_(unit);
} // TextureUnit

struct Texture {

	private {

		GLuint handle_;
		TextureType texture_type_;
		InternalTextureFormat internal_format_;
		PixelFormat pixel_format_;

	}

	@disable this(this);
	@disable ref typeof(this) opAssign(ref typeof(this));

	@property
	const @nogc nothrow {
		GLuint handle() { return handle_; }
		TextureType type() { return texture_type_; }
	}

	enum Error {
		Success = "Succesfully created Texture!"
	} // Error

	nothrow @nogc
	private static Error create(T, DataType)(ref T texture, in DataType* texture_data, ref TextureParams params) {

		enum TType = T.Type;

		texture.texture_type_ = TType;
		texture.internal_format_ = params.internal_format;
		texture.pixel_format_ = params.pixel_format;

		// begin creation
		glGenTextures(1, &texture.handle_);
		Renderer.bindTexture(texture.handle, texture.texture_type_, 0);

		// set texture parameters in currently bound texture, controls texture wrapping (or GL_CLAMP?)
		glTexParameteri(texture.texture_type_, GL_TEXTURE_WRAP_S, params.wrapping);
		glTexParameteri(texture.texture_type_, GL_TEXTURE_WRAP_T, params.wrapping);

		// linearly interpolate between pixels, MIN if texture is too small for drawing area, MAG if drawing area is smaller than texture
		glTexParameterf(texture.texture_type_, GL_TEXTURE_MIN_FILTER, params.filtering);
		glTexParameterf(texture.texture_type_, GL_TEXTURE_MAG_FILTER, params.filtering);

		// mipmapping levels
		glTexParameteri(texture.texture_type_, GL_TEXTURE_BASE_LEVEL, params.mipmap_base_level);
		glTexParameteri(texture.texture_type_, GL_TEXTURE_MAX_LEVEL, params.mipmap_max_level);

		// level of detail
		glTexParameteri(texture.texture_type_, GL_TEXTURE_MIN_LOD, params.min_lod);
		glTexParameteri(texture.texture_type_, GL_TEXTURE_MAX_LOD, params.max_lod);

		// pixel pack and unpack alignment
		glPixelStorei(GL_PACK_ALIGNMENT, params.pack_alignment);
		glPixelStorei(GL_UNPACK_ALIGNMENT, params.unpack_alignment);

		auto data_type = TypeToGL!DataType;

		static if (TType == TextureType.Texture1D) {

			glTexImage1D(
				texture.texture_type_,
				0, // level
				texture.internal_format_,
				texture.width_,
				0, // border
				texture.pixel_format_,
				data_type,
				cast(void*)texture_data
			);

		} else static if (TType == TextureType.Texture2D || TType == TextureType.Texture1DArray) {

			glTexImage2D(
				texture.texture_type_,
				0, // level
				texture.internal_format_,
				texture.width_, texture.height_,
				0, // border
				texture.pixel_format_,
				data_type,
				cast(void*)texture_data
			);

		} else static if (TType == TextureType.Texture3D || TType == TextureType.Texture2DArray) {

			glTexImage3D(
				texture.texture_type_,
				0, // level
				texture.internal_format_,
				texture.width_, texture.height_, texture.depth_,
				0, // border
				texture.pixel_format_,
				data_type,
				cast(void*)texture_data
			);

		} else {

			import std.string : format;
			static assert(0, format("unhandled texture type: %s", TType));

		}

		return Error.Success;

	} // create

	@nogc nothrow
	static OpaqueTexture fromId(GLuint id, TextureType type) {

		return OpaqueTexture(id, type);

	} // fromId

} // Texture

struct Texture1D {

	enum Type = TextureType.Texture1D;

	private {

		Texture texture_;

		uint width_;

	}

	alias texture_ this;

	@property
	nothrow @nogc const {

		uint width() { return width_; }
		GLuint handle() { return texture_.handle; }

	}

	@disable this(this);
	@disable ref typeof(this) opAssign(ref typeof(this));

	nothrow @nogc
	static auto create(DataType)(ref Texture1D texture, in DataType* texture_data, int width, ref TextureParams params) {

		return Texture.create(texture, texture_data, params);

	} // create

} // Texture1D

struct Texture2D {

	enum Type = TextureType.Texture2D;

	private {

		Texture texture_;
		
		uint width_;
		uint height_;

	}

	alias texture_ this;

	@property
	nothrow @nogc const {

		uint width() { return width_; }
		uint height() { return height_; }
		GLuint handle() { return texture_.handle; }

	}

	@disable this(this);
	@disable ref typeof(this) opAssign(ref typeof(this));

	nothrow @nogc
	static auto create(DataType)(ref Texture2D texture, int width, int height, ref TextureParams params) {

		return Texture2D.create(texture, cast(DataType*)null, width, height, params);

	} // create

	nothrow @nogc
	static auto create(DataType)(ref Texture2D texture, in DataType[] texture_data, int width, int height, ref TextureParams params) {

		return Texture2D.create(texture, texture_data.ptr, width, height, params);

	} // create

	nothrow @nogc
	static auto create(DataType)(ref Texture2D texture, in DataType* texture_data, int width, int height, ref TextureParams params) {

		texture.width_ = width;
		texture.height_ = height;

		return Texture.create(texture, texture_data, params);

	} // create

	nothrow @nogc
	void update(int x_offset, int y_offset, int width, int height, in ubyte* bytes) {

		Renderer.bindTexture(texture_.handle_, Type, 0);
		glTexSubImage2D(texture_.texture_type_, 0, x_offset, y_offset, width, height, texture_.pixel_format_, TypeToGL!ubyte, bytes);

	} // update

	nothrow @nogc
	SimpleFramebuffer.Error asSurface(ref SimpleFramebuffer buffer, bool with_depth_buffer) {

		return SimpleFramebuffer.create(buffer, this, with_depth_buffer);

	} // asSurface

} // Texture2D

struct Texture3D {

	enum Type = TextureType.Texture3D;

	private {

		Texture texture_;

		uint width_;
		uint height_;

	}

	alias texture_ this;

	@property
	nothrow @nogc const {

		uint width() { return width_; }
		uint height() { return height_; }
		GLuint handle() { return texture_.handle; }

	}

	@disable this(this);
	@disable ref typeof(this) opAssign(ref typeof(this));

	static auto create(DataType)(ref Texture3D texture, in DataType[] texture_data, int width, int height, int depth, ref TextureParams params) {

		texture.width_ = width;
		texture.height_ = height;
		texture.depth_ = depth;

		return Texture.create(texture, texture_data.ptr, params);

	} // create

	nothrow @nogc
	void update(int x_offset, int y_offset, int z_offset, int width, int height, int depth, in ubyte* bytes) {

		Renderer.bindTexture(texture_.handle_, Type, 0);
		glTexSubImage3D(texture_.texture_type_, 0, x_offset, y_offset, z_offset, width, height, depth, texture_.pixel_format_, TypeToGL!ubyte, bytes);

	} // update

} // Texture3D

struct Texture1DArray {

	enum Type = TextureType.Texture1DArray;

	private {

		Texture texture_;

		uint width_;
		uint height_;

	}

	alias texture_ this;

	@property
	nothrow @nogc const {

		uint width() { return width_; }
		uint height() { return height_; }
		GLuint handle() { return texture_.handle; }

	}

	@disable this(this);
	@disable ref typeof(this) opAssign(ref typeof(this));

	nothrow @nogc
	void update(int x_offset, int y_offset, int z_offset, int width, int height, int depth, in ubyte* bytes) {

		Renderer.bindTexture(texture_.handle_, Type, 0);
		glTexSubImage2D(texture_.texture_type_, 0, x_offset, y_offset, width, height, texture_.pixel_format_, TypeToGL!ubyte, bytes);

	} // update

} // Texture1DArray

struct Texture2DArray {

	enum Type = TextureType.Texture2DArray;

	private {

		Texture texture_;

		uint width_;
		uint height_;
		uint depth_;

	}

	alias texture_ this;

	@property
	nothrow @nogc const {

		uint width() { return width_; }
		uint height() { return height_; }
		uint depth() { return depth_; }
		GLuint handle() { return texture_.handle; }

	}

	@disable this(this);
	@disable ref typeof(this) opAssign(ref typeof(this));

	nothrow @nogc
	void update(int x_offset, int y_offset, int z_offset, int width, int height, int depth, in ubyte* bytes) {

		Renderer.bindTexture(texture_.handle_, Type, 0);
		glTexSubImage3D(texture_.texture_type_, 0, x_offset, y_offset, z_offset, width, height, depth, texture_.pixel_format_, TypeToGL!ubyte, bytes);

	} // update

} // Texture2DArray

struct OpaqueTexture {

	private {
		GLuint handle_;
		TextureType texture_type_;
	}

	@nogc nothrow
	GLuint handle() {
		return handle_;
	} // handle

} // OpaqueTexture

struct SimpleFramebuffer {

	private {

		GLuint fbo_;
		GLuint depth_;

		// cached, from texture
		int width_;
		int height_;

	}

	@property nothrow @nogc {

		int width() { return width_; }
		int height() { return height_; }

	}

	@disable this(this);
	@disable ref typeof(this) opAssign(ref typeof(this));

	enum Error {
		Success = "SimpleFrameBuffer successfully created!"
	} // Error

	nothrow @nogc
	static Error create(ref SimpleFramebuffer buffer, ref Texture2D texture, bool with_depth_buffer) {

		// from texture
		buffer.width_ = texture.width;
		buffer.height_ = texture.height;

		// now set up frame buffers

		glGenFramebuffers(1, &buffer.fbo_);
		glBindFramebuffer(GL_FRAMEBUFFER, buffer.fbo_);

		if (with_depth_buffer) {
			glGenRenderbuffers(1, &buffer.depth_);
			glBindRenderbuffer(GL_RENDERBUFFER, buffer.depth_);
			glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT, texture.width, texture.height);
			glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, buffer.depth_);
		}

		glFramebufferTexture(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, texture.handle, 0);

		GLenum[1] draw_buffers = [GL_COLOR_ATTACHMENT0];
		glDrawBuffers(1, draw_buffers.ptr);

		return Error.Success;

	} // create

	@nogc
	nothrow
	~this() {

		glDeleteRenderbuffers(1, &depth_);
		glDeleteFramebuffers(1, &fbo_);

	} // ~this

	@property
	nothrow @nogc
	GLuint handle() {
		return fbo_;
	} // handle

} // SimpleFramebuffer

enum WithDepthBuffer : bool {
	Yes = true,
	No = false
} // WithDepthbuffer

struct Framebuffer(WithDepthBuffer wdb = WithDepthBuffer.No) {

	private {

		GLuint fbo_;

		static if (wdb) {
			GLuint depth_;
		}

		// texture
		Texture texture_;

	}

	@property
	nothrow @nogc {

		int width() { return width_; }
		int height() { return height_; }

	}

	@disable this(this);
	@disable ref typeof(this) opAssign(ref typeof(this));

	enum Error {
		FailedCreatingFramebufferTexture = "Failed Creating Framebuffer Texture!",
		Success = "FrameBuffer successfully created!"
	} // Error

	nothrow @nogc
	static Error create(FrameBufferType)(ref FrameBufferType buffer, int w, int h) {

		// from texture
		auto texture_result = Texture.create(buffer.texture_, null, w, h); 
		if (texture_result != Texture.Error.Success) {
			return Error.FailedCreatingFramebufferTexture;
		}

		// now set up frame buffer
		glGenFramebuffers(1, &buffer.fbo_);
		glBindFramebuffer(GL_FRAMEBUFFER, buffer.fbo_);

		static if (with_depth_buffer) {
			glGenRenderbuffers(1, &buffer.depth_);
			glBindRenderbuffer(GL_RENDERBUFFER, buffer.depth_);
			glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT, buffer.texture_.width, buffer.texture_.height);
			glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, buffer.depth_);
		}

		glFramebufferTexture(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, texture.handle, 0);

		GLenum[1] draw_buffers = [GL_COLOR_ATTACHMENT0];
		glDrawBuffers(1, draw_buffers.ptr);

		return Error.Success;

	} // create

	~this() {

		static if (with_depth_buffer) {
			glDeleteRenderbuffers(1, &depth_);
		}

		glDeleteFramebuffers(1, &fbo_);

	} // ~this

	void resize(int w, int h) {

		texture_.resize(w, h);

		static if (with_depth_buffer) {
			glBindFramebuffer(GL_FRAMEBUFFER, fbo_);
			glBindRenderbuffer(GL_RENDERBUFFER, depth_);
			glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT, width_, height_);
		}

	} // resize

	@property
	nothrow @nogc
	GLuint handle() {
		return fbo_;
	} // handle

} // Framebuffer

struct PixelBuffer {

} // PixelBuffer

struct VertexCountProvider_ {
} // VertexCountProvider

@property
auto VertexCountProvider() { // @suppress(dscanner.style.phobos_naming_convention)
	return VertexCountProvider_();
} // VertexCountProvider

struct InstanceCountProvider_ {
} // InstanceCountProvider_

@property
auto InstanceCountProvider() { // @suppress(dscanner.style.phobos_naming_convention)
	return InstanceCountProvider_();
} // InstanceCountProvider

struct OffsetProvider_ {
} // OffsetProvider

@property
auto OffsetProvider() { // @suppress(dscanner.style.phobos_naming_convention)
	return OffsetProvider_();
} // OffsetProvider

struct TypeProvider_ {
} // TypeProvider_

@property
auto ManualCountProvider() { // @suppress(dscanner.style.phobos_naming_convention)
	return ManualCountProvider_();
} // ManualCountProvider

struct ManualCountProvider_ {
} // ManualCountProvider_

@property
auto TypeProvider() { // @suppress(dscanner.style.phobos_naming_convention)
	return TypeProvider_();
} // TypeProvider

struct BufferSizeFrom_(alias M) {
	enum From = M.stringof;
} // BufferSizeFrom_

@property
auto BufferSizeFrom(alias M)() { // @suppress(dscanner.style.phobos_naming_convention)
	return BufferSizeFrom_!M();
} // BufferSizeFrom

template MembersByUDA(T, alias attribute) {

	import std.meta : Filter;
	import std.traits : hasUDA;

	template HasSpecificUDA(string field) {
		static if (field == "this") {
			enum HasSpecificUDA = false;
		} else {
			enum HasSpecificUDA = hasUDA!(__traits(getMember, T, field), attribute);
		}
	}

	alias MembersByUDA = Filter!(HasSpecificUDA, __traits(allMembers, T));

} // MembersByUDA

template CollectEnumMembers(T, ET) {

	import std.meta : staticMap;
	import std.traits : EnumMembers;

	template GetMembers(alias EM) {
		alias GetMembers = MembersByUDA!(T, EM);
	} // GetMember

	alias CollectEnumMembers = staticMap!(GetMembers, EnumMembers!ET);

} // CollectEnumMembers

struct VertexArrayT(VDataType) {

	import std.meta : AliasSeq;
	import std.traits : isInstanceOf, getUDAs, hasUDA;

	// HACK: this is getting around the fact that i can't just get all members with a certain UDA for enum types, the concrete value
	//  was in this case required, so it iterates over the enum's members and concatenates the results.
	// One major problem with this approach is ordering of data, because the order of members matters.
	alias All = CollectEnumMembers!(VDataType, DrawHint);
	enum VboCount = All.length;

	alias StructUDAs = getUDAs!(VDataType, DrawType);
	static assert(StructUDAs.length == 1, "expected @DrawType annotation on struct!");
	static if (StructUDAs.length == 1) alias DrawFunction = StructUDAs[0];

	enum isInstancedDrawing = (DrawFunction == DrawType.DrawArraysInstanced || DrawFunction == DrawType.DrawElementsInstanced);
	enum isManuallyDrawn = hasUDA!(VDataType, ManualCountProvider_);
	
	private {

		GLuint handle_;
		GLuint[VboCount] vbos_;
		DrawPrimitive type_;
		uint numVertices_;

		static if (isInstancedDrawing) {
			uint numInstances_;
		}

		GLenum drawType_;

	}

	@disable this(this);
	@disable ref typeof(this) opAssign(ref typeof(this));

	alias UdaTuple = Tuple!(DrawHint, "draw_hint", BufferTarget, "buffer_target", bool, "normalized", string, "size_from");

	static UdaTuple CollectUDAs(alias m)() { // @suppress(dscanner.style.phobos_naming_convention)

		UdaTuple udaTuple;

		foreach (uda; __traits(getAttributes, m)) {
			static if (is(typeof(uda) == DrawHint)) {
				udaTuple.draw_hint = uda;
			} else static if (is(typeof(uda) == BufferTarget)) {
				udaTuple.buffer_target = uda;
			} else static if (isInstanceOf!(BufferSizeFrom_, typeof(uda))) {
				udaTuple.size_from = typeof(uda).From;
			}
		}

		return udaTuple;

	} // CollectUDAs

	nothrow @nogc
	private static auto uploadData(bool is_new)(ref typeof(this) vao, ref VDataType data, DrawPrimitive type) {

		import std.traits : isArray, isCallable, hasUDA, FieldNameTuple, getSymbolsByUDA, getUDAs;
		
		uint currentAttribIndex = 0;

		foreach (v_i, VS; All) {

			alias VT = typeof(__traits(getMember, VDataType, VS));
			enum udaTuple = CollectUDAs!(__traits(getMember, VDataType, VS))();

			static if (isArray!VT) {

				alias VertexType = typeof(__traits(getMember, VDataType, VS)[0]);

				static if (udaTuple.size_from != "") {
					alias MemberType = typeof(__traits(getMember, VDataType, udaTuple.size_from));
					auto newBufferSize = MemberType.sizeof * __traits(getMember, data, udaTuple.size_from).length;
				} else {
					auto newBufferSize = VertexType.sizeof * __traits(getMember, data, VS).length;
				}

				Renderer.bindBuffer(udaTuple.buffer_target, vao.vbos_[v_i]);
				glBufferData(udaTuple.buffer_target,
					newBufferSize,
					__traits(getMember, data, VS).ptr,
					udaTuple.draw_hint
				);

				static if (!is_new) {

					continue;

				} else static if (udaTuple.buffer_target == BufferTarget.ArrayBuffer) {

					alias VertexAttribUDAs = getUDAs!(__traits(getMember, VDataType, VS), VertexAttribDivisor_);
					static if (VertexAttribUDAs.length > 0) {
						pragma(msg, "WAH");
						enum hasDivisor = true;
						enum attribDivisor = VertexAttribUDAs[0].divisor;
					} else {
						enum hasDivisor = false;
					}

					static if (isArray!VertexType) {
					
						// handles primitive arrays

						static if (isArray!(typeof(__traits(getMember, VDataType, VS)[0]))) {
						
							uint i = currentAttribIndex;
							alias ElementType = typeof(__traits(getMember, VDataType, VS)[0][0]);
							enum IsNormalized = hasUDA!(__traits(getMember, VDataType, VS), Normalized_);
							enum ArrLen = VertexType.length;

							glEnableVertexAttribArray(i);
							glVertexAttribPointer(i,
								VertexType.sizeof / ElementType.sizeof,
								TypeToGL!ElementType,
								IsNormalized, // TODO: test this normalization
								VertexType.sizeof, // stride to jump
								cast(const(void)*)0
							);
							
							static if (hasDivisor) {
								pragma(msg, "WAGH");
								glVertexAttribDivisor(currentAttribIndex, attribDivisor);
							}

							currentAttribIndex += 1;

						}

					} else static if (!is (VertexType == struct) && __traits(isPOD, VertexType)) {

						uint i = currentAttribIndex;
						alias ElementType = VertexType;
						enum IsNormalized = hasUDA!(__traits(getMember, VDataType, VertexType), Normalized_);

						glEnableVertexAttribArray(i);
						glVertexAttribPointer(i,
							VertexType.sizeof,
							TypeToGL!ElementType,
							IsNormalized, // TODO: test this normalization too
							VertexType.sizeof,
							cast(const(void*))0
						);

						static if (hasDivisor) {
							glVertexAttribDivisor(currentAttribIndex, attribDivisor);
						}

						currentAttribIndex += 1;

					} else {
					
						// handles structures

						foreach (m; PODMembers!VertexType) {

							uint i = currentAttribIndex;
							alias MemberType = typeof(__traits(getMember, VertexType, m));
							enum MemberOffset = __traits(getMember, VertexType, m).offsetof;
							enum IsNormalized = hasUDA!(__traits(getMember, VertexType, m), Normalized_);

							static if (isArray!MemberType) {
								alias ElementType =  typeof(__traits(getMember, VertexType, m)[0]);
							} else {
								alias ElementType = MemberType;
							}

							glEnableVertexAttribArray(i);
							glVertexAttribPointer(i,
								MemberType.sizeof / ElementType.sizeof,
								TypeToGL!ElementType,
								IsNormalized, // normalization
								VertexType.sizeof, // stride to jump
								cast(const(void)*)MemberOffset
							);
							
							static if (hasDivisor) {
								glVertexAttribDivisor(currentAttribIndex, attribDivisor);
							}

							currentAttribIndex += 1;

						}

					}
				}

			}

		}



		static if (!isManuallyDrawn) {

			// only do if actually supposed to be done automatically
			static if (isInstancedDrawing) {
				alias MembersWithInstanceCountProvider = MembersByUDA!(VDataType, InstanceCountProvider_);
				static assert(MembersWithInstanceCountProvider.length == 1, "struct needs exactly one @InstanceCountProvider!");
				vao.numInstances_ = cast(uint)__traits(getMember, data, MembersWithInstanceCountProvider[0]).length;
			}

			alias MembersWithCountProvider = MembersByUDA!(VDataType, VertexCountProvider_);
			static assert(MembersWithCountProvider.length == 1, "struct needs exactly one @VertexCountProvider, attached to a function or an array!");

			enum Provider = MembersWithCountProvider[0];
			static if (isArray!(typeof(__traits(getMember, VDataType, Provider)))) {
				vao.numVertices_ = cast(uint)__traits(getMember, data, Provider).length;
			} else static if (isCallable!(__traits(getMember, VDataType, Provider))) {
				vao.numVertices_ = __traits(getMember, data, Provider)();
			}

		}

		static if (DrawFunction == DrawType.DrawElements || DrawFunction == DrawType.DrawElementsInstanced) {
			alias MembersWithTypeProvider = MembersByUDA!(VDataType, TypeProvider_);
			static assert(MembersWithTypeProvider.length == 1, "struct needs exactly one @TypeProvider (decides what primitive to pass to draw call)");
			vao.drawType_ = TypeToGL!(typeof(__traits(getMember, data, MembersWithTypeProvider[0])[0]));
		}

		// set ze draw primitive
		vao.type_ = type;

	} // uploadData

	nothrow @nogc
	static auto update(ref typeof(this) vao, ref VDataType data, DrawPrimitive type) {

		Renderer.bindVertexArray(vao);
		uploadData!false(vao, data, type);

	} // update

	nothrow @nogc
	static auto upload(ref VDataType data, DrawPrimitive type) {

		typeof(this) vao;

		glGenVertexArrays(1, vao.handle);
		Renderer.bindVertexArray(vao);

		// GENERATE ALL THE VBOS
		glGenBuffers(VboCount, vao.vbos_.ptr);

		// do ze uploadsings
		uploadData!true(vao, data, type);

		return vao;

	} // upload

	~this() {

		glDeleteVertexArrays(1, &handle_);

	} // ~this

	@property
	GLuint* handle() {
		return &handle_;
	} // handle

} // VertexArrayT

struct VertexBuffer(VT) {

	private {

		GLuint id;

		uint numVertices_;
		DrawPrimitive primType_;

	}

	@disable this(this);
	@disable ref typeof(this) opAssign(ref typeof(this));

	@property
	GLuint* handle() {
		return &id;
	} // handle

} // VertexBuffer

template PODMembers(T) {

	import std.meta : Filter;
	import std.traits : FieldNameTuple;

	template isFieldPOD(string field) {
		enum isFieldPOD = __traits(isPOD, typeof(__traits(getMember, T, field)));
	}

	alias PODMembers = Filter!(isFieldPOD, FieldNameTuple!T);

} // PODMembers

/**
 * UFCS functions for drawing, uploading data, etc.
*/

enum DrawType {

	DrawArrays,
	DrawArraysInstanced,

	DrawElements,
	DrawElementsInstanced

} // DrawType

alias ScissorBox = Tuple!(int, "x", int, "y", uint, "w", uint, "h");

mixin template RendererStateVars() {

	//GL_SCISSOR_TEST
	bool scissor_test;

	//GL_SCISSOR_BOX
	ScissorBox scissor_box;

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

	//GL_BLEND_EQUATION
	BlendEquation blend_eq;

	//GL_BLEND_SRC
	BlendFunc blend_src;

	//GL_BLEND_DST
	BlendFunc blend_dst;

	//GL_CULL_FACE
	bool cull_face;

	//GL_DITHER
	bool dither;

	//GL_LINE_SMOOTH
	bool line_smooth;

	//GL_MULTISAMPLE
	bool multisample;

	//GL_SHADE_MODEL
	ShadingType shading_type;

}

/* OpenGL state which can be set with glEnable/glDisable */
struct RendererState {

	mixin RendererStateVars;

} // RendererState

/* Functions for creating structures and such. */

alias DimFunction = int delegate() @nogc nothrow;
alias SwapFunction = void delegate() @nogc nothrow;

struct Device {
@nogc nothrow:

	// get device height/width
	DimFunction width_fn_;
	DimFunction height_fn_;

	// swap buffers on device
	SwapFunction swap_fn_;

	@nogc
	nothrow
	@property {
		int width() { return width_fn_(); }
		int height() { return height_fn_(); }
		void present() { swap_fn_(); }
	}

} // Device

template isDevice(T) {
	enum isDevice = (is (T : Device) || is (T : SimpleFramebuffer));
} // isDevice

template isFramebuffer(T) {
	enum isFramebuffer = is (T : SimpleFramebuffer);
} //isFramebuffer

template isTexture(T) {

	template isTextureType(IT) {
		enum isTextureType = (is (IT : Texture) || is (IT : OpaqueTexture) || is (IT : Texture1DArray));
	} // isTextureType

	import std.traits : isPointer, PointerTarget;
	static if (isPointer!T) {
		alias PT = PointerTarget!T;
		enum isTexture = isTextureType!(PointerTarget!T);
	} else {
		enum isTexture = isTextureType!T;
	}

} // isTexture

struct Renderer {
static:

	static Device createDevice(DimFunction w, DimFunction h, SwapFunction s) {
		return typeof(return)(w, h, s);
	} // createDevice

	/**
	 * viewport size cache
	*/

	// cached here
	int current_viewport_width_;
	int current_viewport_height_;

	/**
	 * data bindings
	*/

	//GL_ARRAY_BUFFER_BINDING
	GLuint array_buffer_binding;

	//GL_ELEMENT_ARRAY_BUFFER_BINDING
	GLuint element_array_buffer_binding;

	//GL_VERTEX_ARRAY_BUFFER_BINDING
	GLuint vertex_array_buffer_binding;

	//GL_UNIFORM_BUFFER
	GLuint uniform_buffer_binding;

	//GL_TEXTURE_BUFFER
	GLuint texture_buffer_binding;

	// TODO: look at this later, at least 16 is the bottom, but it *can* be more
	//GL_TEXTURE_BINDING_2D
	GLuint[16] texture_binding_2d;

	//GL_CURRENT_PROGRAM
	GLint current_program_binding;

	//GL_FRAMEBUFFER_BINDING
	GLuint framebuffer_binding;

	/**
	 * misc state
	*/

	mixin RendererStateVars;

	/**
	 * Framebuffer Control
	*/

	//GL_DRAW_BUFFER
	//TODO: ...

	/**
	 * Functions, this is the public API
	*/


private:

	/**
	 * Internal Helpers, not public API.
	*/

	/**
	 * Replaces glEnable/glDisable, doesn't set state if already set.
	*/

	@nogc nothrow
	void setViewport(int w, int h) {

		if (current_viewport_width_ != w || current_viewport_height_ != h) {
			current_viewport_width_ = w;
			current_viewport_height_ = h;
			glViewport(0, 0, current_viewport_width_, current_viewport_height_);
		}

	} // setViewport

	@nogc nothrow
	void setState(GLenum state_var, bool desired_state) {

		import std.meta : AliasSeq;

		state_switch : switch (state_var) {

			alias StateSeq = AliasSeq!(
				GL_BLEND, blend_test,
				GL_CULL_FACE, cull_face,
				GL_DEPTH_TEST, depth_test,
				GL_STENCIL_TEST, stencil_test,
				GL_SCISSOR_TEST, scissor_test,
				GL_MULTISAMPLE, multisample
			);

			/**
			 * Below foreach expands to a bunch of case statements checking each state variable like such:
			 *  case GL_BLEND: {
			 *	  if (blend_test != desired_state) {
			 *      desired_state ? glEnable(GL_BLEND) : glDisable(GL_BLEND);
			 *      blend_test = desired_state;
			 *	  }
			 *    break;
			*/

			foreach (i, S; StateSeq) {
				static if (i % 2 == 0) {
					case S: {
						if (StateSeq[i + 1] != desired_state) {
							desired_state ? glEnable(S) : glDisable(S);
							StateSeq[i + 1] = desired_state;
						}
						break state_switch;
					}
				}
			}

			default:
				assert(0, "unsupported state_var!");

		}

	} // setState

	nothrow @nogc
	bool isBound(alias name)() {

		return name != 0;

	} // isBound

	nothrow @nogc
	bool isAnyBound(BufferTarget type) {

		import std.stdio : writefln;

		bool result = false;

		final switch (type) with (BufferTarget) {

			case ArrayBuffer,
				 CopyReadBuffer,
				 CopyWriteBuffer,
				 PixelPackBuffer,
				 PixelUnpackBuffer:
				result = isBound!array_buffer_binding();
				break;

			case ElementArrayBuffer:
				result = isBound!element_array_buffer_binding();
				break;

			case TextureBuffer:
				result = isBound!texture_buffer_binding();
				break;

			case TransformFeedbackBuffer:
				break;

			case UniformBuffer:
				break;

		}

		if (!result) {
			printf("gland: tried checking if non-existent buffer type bound: %d", type);
		}

		return result;

	} // isAnyBound

	nothrow @nogc
	void bindTexture(GLuint texture_handle, TextureType type, uint unit) {

		if (texture_binding_2d[unit] != texture_handle) {
			glActiveTexture(GL_TEXTURE0 + unit);
			glBindTexture(type, texture_handle);
			texture_binding_2d[unit] = texture_handle;
		}

	} // bindTexture

	nothrow @nogc
	bool bindVertexArray(VertexArrayType)(ref VertexArrayType vao) {

		if (vertex_array_buffer_binding == *vao.handle) {
			return false;
		}

		vertex_array_buffer_binding = *vao.handle;
		glBindVertexArray(*vao.handle);

		return true;

	} // bindVertexArray

	nothrow @nogc
	bool bindBuffer(BufferTarget type, GLuint id) {

		switch (type) with (BufferTarget) {

			case ArrayBuffer: {

				if (array_buffer_binding == id) {
					return false;
				}

				array_buffer_binding = id;
				break;

			}

			case ElementArrayBuffer: {

				if (element_array_buffer_binding == id) {
					return false;
				}

				element_array_buffer_binding = id;
				break;

			}

			default: {
				printf("gland: tried to bindBuffer with unknown type: %.*s", type.stringof.length, type);
				return false;
			}

		}

		glBindBuffer(type, id);

		return true;

	} // bindBuffer

	nothrow @nogc
	bool bindFramebuffer(GLuint id) {

		if (framebuffer_binding == id) {
			return false;
		}

		glBindFramebuffer(GL_FRAMEBUFFER, id);
		framebuffer_binding = id;
		return true;

	} // bindFramebuffer

	nothrow @nogc
	bool useProgram(GLuint program) {

		if (current_program_binding == program) {
			return false; // already bound
		}

		current_program_binding = program;
		glUseProgram(program);
		return true;

	} // useProgram

	nothrow @nogc
	bool bufferData(BufferTarget target, GLsizeiptr size, const GLvoid* data, DrawHint usage) {

		if (!isAnyBound(target)) {
			return false;
		}

		return true;

	} // bufferData

} // Renderer

nothrow @nogc
void clear(DeviceType)(ref DeviceType device, auto ref ClearParams params)
	if (isDevice!DeviceType) {

	static if (isFramebuffer!DeviceType) { Renderer.bindFramebuffer(device.handle); }
	else { Renderer.bindFramebuffer(0); }

	GLbitfield clear_flags;
	clear_flags |= GL_COLOR_BUFFER_BIT;
	if (params.depth) clear_flags |= GL_DEPTH_BUFFER_BIT;
	if (params.stencil) clear_flags |= GL_STENCIL_BUFFER_BIT;

	glClearColor(params.colour[0], params.colour[1], params.colour[2], params.colour[3]);
	glClear(clear_flags);

} // clear

nothrow @nogc
void clearColour(DeviceType)(ref DeviceType device, GLint rgb)
	if (isDevice!DeviceType) {

	static if (isFramebuffer!DeviceType) { Renderer.bindFramebuffer(device.handle); }
	else { Renderer.bindFramebuffer(0); }

	auto colour = to!GLColour(rgb);
	glClearColor(colour[0], colour[1], colour[2], colour[3]);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

} // clearColour

nothrow @nogc
void drawOffset(DeviceType, ShaderType, VertexArrayType, UniformTypes...)(ref DeviceType device, ref ShaderType shader, ref VertexArrayType vao, ref DrawParams params, uint vertexCount, ushort* offset, ref UniformTypes uniform)
	    if (isDevice!DeviceType) {

		Renderer.setViewport(device.width, device.height);

		static if (isFramebuffer!DeviceType) {
			Renderer.bindFramebuffer(device.handle);
			drawWithOffset(shader, vao, params, vertexCount, offset, uniform);
		} else {
			Renderer.bindFramebuffer(0);
			drawWithOffset(shader, vao, params, vertexCount, offset, uniform);
		}

} // drawOffset

nothrow @nogc
void draw(DeviceType, ShaderType, VertexArrayType, UniformTypes...)(ref DeviceType device, ref ShaderType shader, ref VertexArrayType vao, ref DrawParams params, ref UniformTypes uniform)
	if (isDevice!DeviceType) {
	
	static assert(!VertexArrayType.isManuallyDrawn, "can't infer drawing with a @ManualCountProvider annotated vao, please use drawOffset!");

	Renderer.setViewport(device.width, device.height);

	static if (isFramebuffer!DeviceType) {
		Renderer.bindFramebuffer(device.handle);
		draw(shader, vao, params, uniform);
	} else {
		Renderer.bindFramebuffer(0);
		draw(shader, vao, params, uniform);
	}

} // draw

nothrow @nogc
void draw(ShaderType, VertexArrayType, UniformTypes...)(ref ShaderType shader, ref VertexArrayType vao, ref DrawParams params, ref UniformTypes uniform) {
	drawWithOffset(shader, vao, params, cast(uint)vao.numVertices_, cast(ushort*)0, uniform);
} // draw

alias Alias(alias Symbol) = Symbol;

nothrow @nogc
void drawWithOffset(ShaderType, VertexArrayType, UniformTypes...)(ref ShaderType shader, ref VertexArrayType vao, ref DrawParams params, uint vertexCount, ushort* offset, ref UniformTypes uniforms) {

	Renderer.bindVertexArray(vao);
	Renderer.useProgram(shader.handle);

	static assert(!__traits(compiles, ShaderType.UniformStruct) && UniformTypes.length == 0 || is(UniformTypes[0] == ShaderType.UniformStruct),
			"uniform struct was either omitted on draw call or added when unnecessary!");

	static if (UniformTypes.length == 1)
	foreach (i, m; PODMembers!(UniformTypes[0])) with (shader) {

		alias T = typeof(__traits(getMember, uniforms[0], m));

		/**
		 * Vectors
		*/

		static if (is (T : float)) {
			glUniform1f(uniforms_[i], __traits(getMember, uniforms[0], m));
		} else static if (is (T : float[2])) {
			glUniform2f(uniforms_[i], __traits(getMember, uniforms[0], m)[0], __traits(getMember, uniforms[0], m)[1]);
		} else static if (is (T : float[3])) {
			glUniform3f(uniforms_[i], __traits(getMember, uniforms[0], m)[0], __traits(getMember, uniforms[0], m)[1], __traits(getMember, uniforms[0], m)[2]);
		} else static if (is (T : float[4])) {
			glUniform4f(uniforms_[i], __traits(getMember, uniforms[0], m)[0], __traits(getMember, uniforms[0], m)[1], __traits(getMember, uniforms[0], m)[2], __traits(getMember, uniforms[0], m)[3]);

		} else static if (is (T : uint)) {
			glUniform1ui(uniforms_[i], __traits(getMember, uniforms[0], m));
		} else static if (is (T : uint[2])) {
			glUniform2ui(uniforms_[i], __traits(getMember, uniforms[0], m)[0], __traits(getMember, uniforms[0], m)[1]);
		} else static if (is (T : uint[3])) {
			glUniform3ui(uniforms_[i], __traits(getMember, uniforms[0], m)[0], __traits(getMember, uniforms[0], m)[1], __traits(getMember, uniforms[0], m)[2]);
		} else static if (is (T : uint[4])) {
			glUniform4ui(uniforms_[i], __traits(getMember, uniforms[0], m)[0], __traits(getMember, uniforms[0], m)[1], __traits(getMember, uniforms[0], m)[2], __traits(getMember, uniforms[0], m)[3]);

		} else static if (is (T : int)) {
			glUniform1i(uniforms_[i], __traits(getMember, uniforms[0], m));
		} else static if (is (T : int[2])) {
			glUniform2i(uniforms_[i], __traits(getMember, uniforms[0], m)[0], __traits(getMember, uniforms[0], m)[1]);
		} else static if (is (T : int[3])) {
			glUniform3i(uniforms_[i], __traits(getMember, uniforms[0], m)[0], __traits(getMember, uniforms[0], m)[1], __traits(getMember, uniforms[0], m)[2]);
		} else static if (is (T : int[4])) {
			glUniform4i(uniforms_[i], __traits(getMember, uniforms[0], m)[0], __traits(getMember, uniforms[0], m)[1], __traits(getMember, uniforms[0], m)[2], __traits(getMember, uniforms[0], m)[3]);

		} else static if (is (T : float[1][])) {
			glUniform1fv(uniforms_[i], __traits(getMember, uniforms[0], m).length, cast(float*)__traits(getMember, uniforms[0], m).ptr);
		} else static if (is (T : float[2][])) {
			glUniform2fv(uniforms_[i], __traits(getMember, uniforms[0], m).length, cast(float*)__traits(getMember, uniforms[0], m).ptr);
		} else static if (is (T : float[3][])) {
			glUniform3fv(uniforms_[i], __traits(getMember, uniforms[0], m).length, cast(float*)__traits(getMember, uniforms[0], m).ptr);
		} else static if (is (T : float[4][])) {
			glUniform4fv(uniforms_[i], __traits(getMember, uniforms[0], m).length, cast(float*)__traits(getMember, uniforms[0], m).ptr);

		} else static if (is (T : uint[1][])) {
			glUniform1uiv(uniforms_[i], __traits(getMember, uniforms[0], m).length, cast(uint*)__traits(getMember, uniforms[0], m).ptr);
		} else static if (is (T : uint[2][])) {
			glUniform2uiv(uniforms_[i], __traits(getMember, uniforms[0], m).length, cast(uint*)__traits(getMember, uniforms[0], m).ptr);
		} else static if (is (T : uint[3][])) {
			glUniform3uiv(uniforms_[i], __traits(getMember, uniforms[0], m).length, cast(uint*)__traits(getMember, uniforms[0], m).ptr);
		} else static if (is (T : uint[4][])) {
			glUniform4uiv(uniforms_[i], __traits(getMember, uniforms[0], m).length, cast(uint*)__traits(getMember, uniforms[0], m).ptr);

		} else static if (is (T : int[1][])) {
			glUniform1iv(uniforms_[i], __traits(getMember, uniforms[0], m).length, cast(int*)__traits(getMember, uniforms[0], m).ptr);
		} else static if (is (T : int[2][])) {
			glUniform2iv(uniforms_[i], __traits(getMember, uniforms[0], m).length, cast(int*)__traits(getMember, uniforms[0], m).ptr);
		} else static if (is (T : int[3][])) {
			glUniform3iv(uniforms_[i], __traits(getMember, uniforms[0], m).length, cast(int*)__traits(getMember, uniforms[0], m).ptr);
		} else static if (is (T : int[4][])) {
			glUniform4iv(uniforms_[i], __traits(getMember, uniforms[0], m).length, cast(int*)__traits(getMember, uniforms[0], m).ptr);

		/**
		 * Matrices
		*/

		} else static if (is (T : float[2][2][])) {
			glUniformMatrix2fv(uniforms_[i], __traits(getMember, uniforms[0], m).length, GL_FALSE, cast(float*)__traits(getMember, uniforms[0], m).ptr);
		} else static if (is (T : float[3][3][])) {
			glUniformMatrix3fv(uniforms_[i], __traits(getMember, uniforms[0], m).length, GL_FALSE, cast(float*)__traits(getMember, uniforms[0], m).ptr);
		} else static if (is (T : float[4][4][])) {
			glUniformMatrix4fv(uniforms_[i], cast(int)__traits(getMember, uniforms[0], m).length, GL_FALSE, cast(float*)__traits(getMember, uniforms[0], m).ptr);

		} else static if (is (T : float[2][3][])) {
			glUniformMatrix2x3fv(uniforms_[i], __traits(getMember, uniforms[0], m).length, GL_FALSE, cast(float*)__traits(getMember, uniforms[0], m).ptr);
		} else static if (is (T : float[3][2][])) {
			glUniformMatrix3x2fv(uniforms_[i], __traits(getMember, uniforms[0], m).length, GL_FALSE, cast(float*)__traits(getMember, uniforms[0], m).ptr);
		} else static if (is (T : float[2][4][])) {
			glUniformMatrix2x4fv(uniforms_[i], __traits(getMember, uniforms[0], m).length, GL_FALSE, cast(float*)__traits(getMember, uniforms[0], m).ptr);
		} else static if (is (T : float[4][2][])) {
			glUniformMatrix4x2fv(uniforms_[i], __traits(getMember, uniforms[0], m).length, GL_FALSE, cast(float*)__traits(getMember, uniforms[0], m).ptr);
		} else static if (is (T : float[3][4][])) {
			glUniformMatrix3x4fv(uniforms_[i], __traits(getMember, uniforms[0], m).length, GL_FALSE, cast(float*)__traits(getMember, uniforms[0], m).ptr);
		} else static if (is (T : float[4][3][])) {
			glUniformMatrix4x3fv(uniforms_[i], __traits(getMember, uniforms[0], m).length, GL_FALSE, cast(float*)__traits(getMember, uniforms[0], m).ptr);

		/**
		 * Textures
		*/

		} else static if (isTexture!T) {

			import std.traits : getUDAs;

			// can bind to any texture unit desired, think about if default should be 0, or keep it as explicit
			alias texture_units = getUDAs!(__traits(getMember, uniforms[0], m), TextureUnit_);
			static assert(texture_units.length == 1, "expected exactly one @TextureUnit UDA on Texture type!");

			Renderer.bindTexture(__traits(getMember, uniforms[0], m).handle, __traits(getMember, uniforms[0], m).texture_type_, texture_units[0].unit);

		}

	}

	/**
	 * TODO: make this less ugly
	*/

	Renderer.setState(GL_BLEND, params.state.blend_test);
	Renderer.setState(GL_CULL_FACE, params.state.cull_face);
	Renderer.setState(GL_DEPTH_TEST, params.state.depth_test);
	Renderer.setState(GL_STENCIL_TEST, params.state.stencil_test);
	Renderer.setState(GL_SCISSOR_TEST, params.state.scissor_test);
	Renderer.setState(GL_MULTISAMPLE, params.state.multisample);

	// actions after aforemented glDisable/glEnable
	if (Renderer.scissor_test) {
		glScissor(Renderer.scissor_box.expand);
		Renderer.scissor_box = params.state.scissor_box;
	}

	if (Renderer.shading_type != params.state.shading_type) {
		glShadeModel(Renderer.shading_type);
		Renderer.shading_type = params.state.shading_type;
	}

	if (Renderer.blend_test && (Renderer.blend_eq != params.blend_eq || Renderer.blend_src != params.blend_src || Renderer.blend_dst != params.blend_dst)) {

		glBlendEquation(params.blend_eq);
		glBlendFunc(params.blend_src, params.blend_dst);

		Renderer.blend_src = params.blend_src;
		Renderer.blend_dst = params.blend_dst;
		Renderer.blend_eq = params.blend_eq;

	}

	// drawing commands here

	static if (VertexArrayType.DrawFunction == DrawType.DrawArrays) {
		glDrawArrays(vao.type_, cast(int)offset, vertexCount);

	} else static if (VertexArrayType.DrawFunction == DrawType.DrawArraysInstanced) {
		glDrawArraysInstanced(vao.type_, cast(int)offset, vertexCount, vao.numInstances_);

	} else static if (VertexArrayType.DrawFunction == DrawType.DrawElements) {
		glDrawElements(vao.type_, vertexCount, vao.drawType_, offset);

	} else static if (VertexArrayType.DrawFunction == DrawType.DrawElementsInstanced) {
		glDrawElementsInstanced(vao.type_, vao.numVertices_, vao.drawType_, 0);
	}

} // drawWithOffset
