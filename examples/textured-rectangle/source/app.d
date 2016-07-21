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
	layout (location = 1) in vec2 uv;

	uniform vec2 offset;

	out vec2 tex_coord;

	void main() {
		gl_Position = vec4(position + offset, 0.0, 1.0);
		tex_coord = uv;
	}
";

immutable char* fs_shader = "
	#version 330

	in vec2 tex_coord;

	uniform sampler2D diffuse;

	out vec4 f_colour;

	void main() {
		f_colour = texture2D(diffuse, tex_coord);
	}
";

alias Mat4f = float[4][4];

alias TriangleShader = Shader!([
	ShaderTuple(ShaderType.VertexShader, [
		AttribTuple("position", 0),
		AttribTuple("uv", 1)
	]),
	ShaderTuple(ShaderType.FragmentShader, [])
], float[2], "offset", Texture*, "diffuse");

struct Vertex2f2f {

	float[2] position;
	float[2] uv;

} // Vertex2f2f

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

	// load graphics and stuff
	auto texture_shader = TriangleShader.compile(&vs_shader, &fs_shader);

	Texture texture;

	// create a simple checkered texture
	import std.algorithm : each;
	import std.range : enumerate;

	immutable uint sections = 8;
	ubyte[sections * sections] texture_data = 255;

	uint row = 0;
	foreach (i, ref b; texture_data) {

		if (i % sections == 0) row++;

		auto row_result = ((i % sections == 0 && i % 2 != 0) || (i-1 % sections == 0 || i % 2 != 0));
		b = (row % 2 == 0) ? (row_result ? 255 : 0) : (row_result ? 0 : 255);

	}

	auto texture_result = Texture.create(texture, texture_data[], sections, sections, InternalTextureFormat.R8, PixelFormat.Red);

	// check validity
	if (!texture_shader.valid) {
		writefln("[MAIN] Shader compile failed, exiting!");
		return; // exit now
	}

	// declare vertex data
	Vertex2f2f[6] vertices = [

		Vertex2f2f([0.0f, 0.0f], [0.0f, 0.0f]), // top left
		Vertex2f2f([1.0f, 0.0f], [1.0f, 0.0f]), // top right
		Vertex2f2f([1.0f, 1.0f], [1.0f, 1.0f]), // bottom right

		Vertex2f2f([0.0f, 0.0f], [0.0f, 0.0f]), // top left
		Vertex2f2f([0.0f, 1.0f], [0.0f, 1.0f]), // bottom left
		Vertex2f2f([1.0f, 1.0f], [1.0f, 1.0f]) // bottom right

	];

	// now, upload vertices
	auto vao = vertices.upload(DrawHint.StaticDraw, DrawPrimitive.Triangles);

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

		byte[] image_data;
		float[2] offset = [-0.5, -0.5];
		Renderer.draw(texture_shader, vao, params, offset, &texture);

		window.present();

	}

}
