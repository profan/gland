import std.typecons : tuple;
import std.stdio;
import std.meta;

import derelict.sdl2.sdl;

import gland.util;
import gland.win;
import gland.gl;

immutable char* vs_shader = "
	#version 330

	layout (location = 0) in vec2 position;
	layout (location = 1) in vec3 colour;

	out vec3 v_colour;

	void main() {
		gl_Position = vec4(position, 0.0, 1.0);
		v_colour = colour;
	}
";

immutable char* fs_shader = "
	#version 330

	in vec3 v_colour;
	out vec4 f_colour;

	void main() {
		f_colour = vec4(v_colour, 1.0);
	}
";

immutable char* tex_vs_shader = "
    #version 330 core

    layout (location = 0) in vec2 position;
    layout (location = 1) in vec2 uv;

    out vec2 tex_coord;

    void main() {
        gl_Position = vec4(position, 0.0, 1.0);
        tex_coord = uv;
    }
";

immutable char* tex_fs_shader = "
    #version 330 core

    in vec2 tex_coord;

    uniform sampler2D diffuse;

    out vec4 f_colour;

    void main() {
        f_colour = texture2D(diffuse, tex_coord);
    }
";

alias Mat4f = float[4][4];

alias TriangleShader = Shader!(
	[ShaderType.VertexShader, ShaderType.FragmentShader], [
		AttribTuple("position", 0),
		AttribTuple("colour", 1)
	]
);

alias TextureShader = Shader!(
	[ShaderType.VertexShader, ShaderType.FragmentShader], [
        AttribTuple("position", 0),
        AttribTuple("uv", 1)
    ], Texture*, "diffuse"
);

struct Vertex2f3f {

	float[2] position;
	float[3] colour;

} // Vertex2f3f

@(DrawType.DrawArrays)
struct TriangleData {

	@(DrawHint.StaticDraw)
	@(BufferTarget.ArrayBuffer)
	@VertexCountProvider
	Vertex2f3f[] vertices;

} // TriangleData

alias TriangleVao = VertexArrayT!TriangleData;

struct Vertex2f2f {

	float[2] position;
	float[2] uv;

} // Vertex2f2f

@(DrawType.DrawArrays)
struct FramebufferData {

	@(DrawHint.StaticDraw)
	@(BufferTarget.ArrayBuffer)
	@VertexCountProvider
	Vertex2f2f[] vertices;

} // FramebufferData

alias FrameVao = VertexArrayT!FramebufferData;

void main() {

	// load libs
	Window.load();

	Window window;
	auto result = Window.create(window, 640, 480);
	Renderer.viewport_width_ = window.width;
	Renderer.viewport_height_ = window.height;

	final switch (result) with (Window.Error) {

		/* return from main if we failed, print stuff. */
		case WindowCreationFailed, ContextCreationFailed:
			writefln("[WIN] Error: %s", cast(string)result);
			return;

		/* we succeeded, just continue. */
		case Success:
			writefln("[WIN] %s", cast(string)result);
			break;

	}

	// hold state for current x, y size of framebuffer texture
	int texture_w = window.width / 8;
	int texture_h = window.height / 8;

	// create texture to render to
	Texture framebuffer_texture;
	TextureParams tex_params = {
		internal_format : InternalTextureFormat.RGB,
		pixel_format : PixelFormat.RGB
	};
	auto texture_result = Texture.create(framebuffer_texture, null, texture_w, texture_h, tex_params);
	
	// create a frame buffer from this texture
	SimpleFramebuffer frame_buffer;
	auto framebuffer_result = framebuffer_texture.asSurface(frame_buffer, false);

	// load shader for drawing textured thing
	TextureShader texture_shader;
	auto texture_shader_result = TextureShader.compile(texture_shader, &tex_vs_shader, &tex_fs_shader);

	// check validity
	if (texture_shader_result != TextureShader.Error.Success) {
		writefln("[MAIN] Texture Shader compile failed, exiting!");
		return; // exit now
	}

	// load graphics and stuff
	TriangleShader triangle_shader;
	auto triangle_result = TriangleShader.compile(triangle_shader, &vs_shader, &fs_shader);
	
	// check validity
	if (triangle_result != TriangleShader.Error.Success) {
		writefln("[MAIN] Triangle Shader compile failed, exiting!");
		return; // exit now
	}

	// declare vertex data
	Vertex2f3f[3] tri_vertices = [
		Vertex2f3f([0.0f, 0.5f], [1.0f, 0.0f, 0.0f]), // triangle top
		Vertex2f3f([-0.5f, -0.5f], [0.0f, 1.0f, 0.0f]), // triangle left
		Vertex2f3f([0.5f, -0.5f], [0.0f, 0.0f, 1.0f]) // triangle right
	];

	// now, upload vertices
	auto tri_data = TriangleData(tri_vertices);
	auto vao = TriangleVao.upload(tri_data, DrawPrimitive.Triangles);

	// declare vertex data
	Vertex2f2f[6] rect_vertices = [
		Vertex2f2f([-1.0f, -1.0f], [0.0f, 0.0f]), // top left
		Vertex2f2f([1.0f, -1.0f], [1.0f, 0.0f]), // top right
		Vertex2f2f([1.0f, 1.0f], [1.0f, 1.0f]), // bottom right

		Vertex2f2f([-1.0f, -1.0f], [0.0f, 0.0f]), // top left
		Vertex2f2f([-1.0f, 1.0f], [0.0f, 1.0f]), // bottom left
		Vertex2f2f([1.0f, 1.0f], [1.0f, 1.0f]) // bottom right
	];

	// also, rect vertices
	auto frame_data = FramebufferData(rect_vertices);
	auto rect_vao = FrameVao.upload(frame_data, DrawPrimitive.Triangles);

	while (window.isAlive) {

		// handle window events
		window.handleEvents();

		// check if it's time to quit
		if (window.isKeyDown(SDL_SCANCODE_ESCAPE)) {
			window.quit();
		}

		// default state, holds all OpenGL state params like blend state etc to be use for given draw call
		DrawParams params = {};

		// render to texture, also clear with ze blau
		Renderer.draw(frame_buffer, triangle_shader, vao, params);

		// now render given texture, woo!
		Renderer.draw(texture_shader, rect_vao, params, &framebuffer_texture);

		window.present();

	}

}
