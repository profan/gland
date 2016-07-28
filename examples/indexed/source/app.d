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

alias Mat4f = float[4][4];

alias TriangleShader = Shader!(
	[ShaderType.VertexShader, ShaderType.FragmentShader], [
		AttribTuple("position", 0),
		AttribTuple("colour", 1)
	]
);

struct Vertex2f3f {

	float[2] position;
	float[3] colour;

} // Vertex2f3f

@(DrawType.DrawElements)
struct VertexData {

	@(DrawHint.StaticDraw)
	@(BufferTarget.ArrayBuffer)
	Vertex2f3f[] vertices;

	@(DrawHint.StaticDraw)
	@(BufferTarget.ElementArrayBuffer)
	@VertexCountProvider
	@TypeProvider
	uint[] indices;

} // VertexData

// VAO TYPE YES
alias ElementsVAO = VertexArrayT!VertexData;

void main() {

	// load libs
	Window.load();

	Window window;
	auto result = Window.create(window, 640, 480);

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

	// compile ze shader 
	TriangleShader triangle_shader;
	auto shader_result = TriangleShader.compile(triangle_shader, &vs_shader, &fs_shader);

	// check validity
	if (shader_result != TriangleShader.Error.Success) {
		writefln("[MAIN] Shader compile failed, exiting!");
		return; // exit now
	}


	// declare vbo data
	Vertex2f3f[4] vertices = [
		Vertex2f3f([-0.5f, -0.5f], [0.0f, 0.0f, 0.0f]), // top left
		Vertex2f3f([0.5f, -0.5f], [1.0f, 0.0f, 0.0f]), // top right
		Vertex2f3f([0.5f, 0.5f], [1.0f, 1.0f, 0.0f]), // bottom right
		Vertex2f3f([-0.5f, 0.5f], [0.0f, 1.0f, 0.0f]), // bottom left
	];

	// declare ebo data
	uint[6] indices = [
		0, 1, 2,
		2, 3, 0
	];

	auto vertex_data = VertexData(vertices, indices);

	// upload vertices and indices, get back vao to render with
	auto vao = ElementsVAO.upload(vertex_data, DrawPrimitive.Triangles);

	while (window.isAlive) {

		// handle window events
		window.handleEvents();

		// check if it's time to quit
		if (window.isKeyDown(SDL_SCANCODE_ESCAPE)) {
			window.quit();
		}

		// default state, holds all OpenGL state params like blend state etc to be use for given draw call
		DrawParams params = {};

		// cornflower blue, of course
		Renderer.clearColour(0x428bca);
		Renderer.draw(triangle_shader, vao, params);

		window.present();

	}

}
