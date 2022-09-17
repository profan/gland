import std.typecons : tuple;
import std.stdio;
import std.meta;

import derelict.sdl2.sdl;

import gland.util;
import gland.win;
import gland.gl;

immutable char* ms_vs = q{
	#version 330 core

	layout (location = 0) in vec2 position;

	void main() {
		gl_Position = vec4(position, 0.0, 1.0);
	}

};

immutable char* ms_gs = q{
	#version 330 core

	layout (points) in;
	layout (triangle_strip, max_vertices = 25) out;

	uniform sampler2D texture_map;

	out vec3 gs_colour;

	void outputSequence(vec4 origin, int which) {

		switch (which) {

			case 0:
				break;

			/*
			   x---o
			   |   |
			   o---o
			*/
			case 1: {

				vec4 offset_1 = vec4(0.0, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_1;
				EmitVertex();

				vec4 offset_2 = vec4(0.5, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_2;
				EmitVertex();

				vec4 offset_3 = vec4(0.0, -0.5, 0.0, 1.0);
				gl_Position = origin + offset_3;
				EmitVertex();

				EndPrimitive();

				break;
				
			}

			/*
			   o--x
			   |  |
			   o--o
			*/
			case 2: {

				vec4 offset_1 = vec4(1.0, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_1;
				EmitVertex();

				vec4 offset_2 = vec4(1.0, -0.5, 0.0, 1.0);
				gl_Position = origin + offset_2;
				EmitVertex();

				vec4 offset_3 = vec4(0.5, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_3;
				EmitVertex();

				EndPrimitive();

				break;

			}

			/*
			   x--x
			   |  |
			   o--o
			*/
			case 3: {

				vec4 offset_1 = vec4(0.0, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_1;
				EmitVertex();

				vec4 offset_2 = vec4(0.0, -0.5, 0.0, 1.0);
				gl_Position = origin + offset_2;
				EmitVertex();

				vec4 offset_3 = vec4(1.0, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_3;
				EmitVertex();

				vec4 offset_4 = vec4(1.0, -0.5, 0.0, 1.0);
				gl_Position = origin + offset_4;
				EmitVertex();

				EndPrimitive();

				break;

			}

			/*
			   o--o
			   |  |
			   o--x
			*/
			case 4: {

				vec4 offset_1 = vec4(1.0, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_1;
				EmitVertex();

				vec4 offset_2 = vec4(0.5, 0.0, 0.0, 1.0);
				gl_Position  = origin + offset_2;
				EmitVertex();

				vec4 offset_3 = vec4(1.0, -0.5, 0.0, 1.0);
				gl_Position = origin + offset_3;
				EmitVertex();

				EndPrimitive();

				break;

			}

			/*
			   x--o
			   |  |
			   o--x
			*/
			case 5: {

				vec4 offset_1 = vec4(0.5, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_1;
				EmitVertex();

				vec4 offset_1_mid = vec4(1.0, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_1_mid;
				EmitVertex();

				vec4 offset_4 = vec4(0.0, -0.5, 0.0, 1.0);
				gl_Position = origin + offset_4;
				EmitVertex();

				vec4 offset_2 = vec4(1.0, -0.5, 0.0, 1.0);
				gl_Position = origin + offset_2;
				EmitVertex();

				vec4 offset_3_mid = vec4(0.0, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_3_mid;
				EmitVertex();

				vec4 offset_3 = vec4(0.5, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_3;
				EmitVertex();

				EndPrimitive();

				break;

			}

			/*
			   o--x
			   |  |
			   o--x
			*/
			case 6: {

				vec4 offset_1 = vec4(0.5, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_1;
				EmitVertex();

				vec4 offset_2 = vec4(0.5, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_2;
				EmitVertex();

				vec4 offset_3 = vec4(1.0, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_3;
				EmitVertex();

				vec4 offset_4 = vec4(1.0, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_4;
				EmitVertex();

				EndPrimitive();

				break;

			}

			/*
			   o--x
			   |  |
			   x--x
			*/
			case 7: {
				
				vec4 offset_1 = vec4(1.0, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_1;
				EmitVertex();

				vec4 offset_2 = vec4(0.5, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_2;
				EmitVertex();

				vec4 offset_3 = vec4(1.0, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_3;
				EmitVertex();

				vec4 offset_4 = vec4(0.0, -0.5, 0.0, 1.0);
				gl_Position = origin + offset_4;
				EmitVertex();

				vec4 offset_5 = vec4(0.0, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_5;
				EmitVertex();

				EndPrimitive();

				break;

			}

			/*
			   o--o
			   |  |
			   x--o
			*/
			case 8: {

				vec4 offset_1 = vec4(0.0, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_1;
				EmitVertex();

				vec4 offset_2 = vec4(0.0, -0.5, 0.0, 1.0);
				gl_Position = origin + offset_2;
				EmitVertex();

				vec4 offset_3 = vec4(0.5, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_3;
				EmitVertex();

				EndPrimitive();

				break;

			}

			/*
			   x--o
			   |  |
			   x--o
			*/
			case 9: {

				vec4 offset_1 = vec4(0.0, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_1;
				EmitVertex();

				vec4 offset_2 = vec4(0.0, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_2;
				EmitVertex();

				vec4 offset_3 = vec4(0.5, 1.0, 0.0, 1.0);
				gl_Position = origin + offset_3;
				EmitVertex();

				vec4 offset_4 = vec4(0.5, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_4;
				EmitVertex();

				EndPrimitive();

				break;
			
			}

			/*
			   o--x
			   |  |
			   x--o
			*/
			case 10: {

				vec4 offset_1 = vec4(0.0, -0.5, 0.0, 1.0);
				gl_Position = origin + offset_1;
				EmitVertex();

				vec4 offset_1_mid = vec4(0.0, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_1_mid;
				EmitVertex();

				vec4 offset_2 = vec4(0.5, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_2;
				EmitVertex();

				vec4 offset_3 = vec4(0.5, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_3;
				EmitVertex();

				vec4 offset_3_mid = vec4(1.0, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_3_mid;
				EmitVertex();

				vec4 offset_4 = vec4(1.0, -0.5, 0.0, 1.0);
				gl_Position = origin + offset_4;
				EmitVertex();

				EndPrimitive();

				break;

			}

			/*
			   x--o
			   |  |
			   x--x
			*/
			case 11: {

				vec4 offset_1 = vec4(0.0, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_1;
				EmitVertex();

				vec4 offset_2 = vec4(0.5, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_2;
				EmitVertex();

				vec4 offset_3 = vec4(0.0, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_3;
				EmitVertex();

				vec4 offset_4 = vec4(1.0, -0.5, 0.0, 1.0);
				gl_Position = origin + offset_4;
				EmitVertex();

				vec4 offset_5 = vec4(1.0, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_5;
				EmitVertex();

				EndPrimitive();

				break;

			}

			/*
			   o--o
			   |  |
			   x--x
			*/
			case 12: {

				vec4 offset_1 = vec4(0.0, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_1;
				EmitVertex();

				vec4 offset_2 = vec4(1.0, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_2;
				EmitVertex();

				vec4 offset_3 = vec4(0.0, -0.5, 0.0, 1.0);
				gl_Position = origin + offset_3;
				EmitVertex();

				vec4 offset_4 = vec4(1.0, -0.5, 0.0, 1.0);
				gl_Position = origin + offset_4;
				EmitVertex();

				EndPrimitive();

				break;
				
			}

			/*
			   x--x
			   |  |
			   x--o
			*/
			case 13: {

				vec4 offset_1 = vec4(0.0, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_1;
				EmitVertex();

				vec4 offset_2 = vec4(0.5, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_2;
				EmitVertex();

				vec4 offset_3 = vec4(0.0, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_3;
				EmitVertex();

				vec4 offset_4 = vec4(1.0, -0.5, 0.0, 1.0);
				gl_Position = origin + offset_4;
				EmitVertex();

				vec4 offset_5 = vec4(1.0, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_5;
				EmitVertex();

				EndPrimitive();

				break;

			}

			/*
			   x--x
			   |  |
			   o--x
			*/
			case 14: {

				vec4 offset_1 = vec4(1.0, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_1;
				EmitVertex();

				vec4 offset_2 = vec4(0.0, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_2;
				EmitVertex();

				vec4 offset_3 = vec4(1.0, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_3;
				EmitVertex();

				vec4 offset_4 = vec4(0.0, -0.5, 0.0, 1.0);
				gl_Position = origin + offset_4;
				EmitVertex();

				vec4 offset_5 = vec4(0.5, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_5;
				EmitVertex();

				EndPrimitive();

				break;

			}

			/*
			   x--x
			   |  |
			   x--x
			*/
			case 15: {
				
				vec4 offset_1 = vec4(0.0, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_1;
				EmitVertex();

				vec4 offset_2 = vec4(0.0, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_2;
				EmitVertex();

				vec4 offset_3 = vec4(1.0, 0.0, 0.0, 1.0);
				gl_Position = origin + offset_3;
				EmitVertex();

				vec4 offset_4 = vec4(1.0, -1.0, 0.0, 1.0);
				gl_Position = origin + offset_4;
				EmitVertex();

				EndPrimitive();

				break;

			}
		}

	} // outputSequence

	void main() {

		vec4 origin = gl_in[0].gl_Position;
		ivec2 coord = ivec2(origin.xy);
		float colour = texelFetch(texture_map, coord, 0).r * 10;

		gs_colour = vec3(colour, 0.0, 0.0);

		vec2[9] positions = vec2[9](
			vec2(origin.x, origin.y), // point itself
			vec2(origin.x + 1, origin.y), // right of point
			vec2(origin.x, origin.y + 1), // below point
			vec2(origin.x + 1, origin.y + 1), // below to the right
			vec2(origin.x - 1, origin.y), // to the left of the point
			vec2(origin.x, origin.y - 1), // above point
			vec2(origin.x - 1, origin.y - 1), // above and to the left
			vec2(origin.x + 1, origin.y - 1), // above and to the right
			vec2(origin.x - 1, origin.y + 1) // below and to the left
		);

		int start_x = clamp(int(origin.x) - 1, 0, 8);
		int start_y = clamp(int(origin.y) - 1, 0, 8);
		int end_x = clamp(int(origin.x) + 1, 0, 8);
		int end_y = clamp(int(origin.y) + 1, 0, 8);

		/*
		int result;
		for (int y = start_y; y < end_y; y++) {
			for (int x = start_x; x < end_x; x++) {
				int value = int(texelFetch(texture_map, coord + ivec2(x, y), 0).r);
				result |= value;
			}
		}
		*/

		//int result;
		//result += int(texelFetch(texture_map, coord, 0).r);

		//vec4 actual_origin = vec4(origin.xy - vec2(2, 1), origin.zw);
		outputSequence(origin, 5);

	}

};

immutable char* ms_fs = q{
	#version 330 core

	in vec3 gs_colour;

	out vec3 f_colour;

	void main() {
		f_colour = gs_colour;
	}
};

alias Vec2f = float[2];
alias Mat4f = float[4][4];

enum GridSize = 8;
alias Height = ubyte;

immutable Height[GridSize][GridSize] grid = [
	[
		5, 10, 10, 10, 10, 10, 10, 5
	],
	[
		10, 10, 15, 15, 15, 15, 10, 10
	],
	[
		10, 15, 15, 15, 15, 15, 15, 10
	],
	[
		10, 15, 15, 15, 15, 15, 15, 10
	],
	[
		10, 15, 15, 15, 15, 15, 15, 10
	],
	[
		10, 15, 15, 15, 15, 15, 15, 10
	],
	[
		10, 10, 15, 15, 15, 15, 10, 10
	],
	[
		5, 10, 10, 10, 10, 10, 10, 5
	]

];

struct MapUniform {

	@TextureUnit(0)
	Texture2D* texture_map;

} // MapUniform

alias MapShader = Shader!(
	[ShaderType.VertexShader, ShaderType.GeometryShader, ShaderType.FragmentShader], [
		AttribTuple("position", 0)
	], MapUniform
);

@(DrawType.DrawArrays)
struct MapData {

	@(DrawHint.StaticDraw)
	@(BufferTarget.ArrayBuffer)
	@VertexCountProvider
	Vec2f[] positions;

} // MapData

alias MapVao = VertexArrayT!MapData;

immutable char* ts_vs = q{
	#version 330 core

	layout (location = 0) in vec2 position;
	layout (location = 1) in vec2 uv;

	out vec2 tex_coord;

	void main() {
		gl_Position = vec4(position, 0.0, 1.0);
		tex_coord = uv;
	}
};

immutable char* ts_fs = q{
	#version 330 core

	in vec2 tex_coord;

	uniform sampler2D diffuse;

	out vec4 f_colour;

	void main() {
		f_colour = vec4(texture2D(diffuse, tex_coord).r, 0.0, 0.0, 1.0);
	}
};

struct TextureUniform {

	@TextureUnit(0)
	Texture2D* diffuse;

} // TextureUniform

alias TextureShader = Shader!(
	[ShaderType.VertexShader, ShaderType.FragmentShader], [
		AttribTuple("position", 0),
		AttribTuple("uv", 1)
	], TextureUniform
);

struct Vertex2f2f {
	float[2] position;
	float[2] uv;
} // Vertex2f2f

@(DrawType.DrawArrays)
struct VertexData {

	@VertexCountProvider
	@(BufferTarget.ArrayBuffer)
	@(DrawHint.StaticDraw)
	Vertex2f2f[] vertices;

} // VertexData

alias TextureVao = VertexArrayT!VertexData;

Texture2D generateMapTexture(ref in Height[GridSize][GridSize] cells) {

	TextureParams params = {
		internalFormat : InternalTextureFormat.R8,
		pixelFormat : PixelFormat.Red,
		packAlignment : PixelPack.One,
		unpackAlignment : PixelPack.One,
		wrapping : TextureWrapping.Repeat,
		mipmapMaxLevel : 0
	};

	Texture2D newTexture;
	auto textureResult = Texture2D.create(newTexture, cast(ubyte*)cells.ptr, GridSize, GridSize, params);

	return newTexture;

} // generateMapTexture

void main() {

	// load libs
	Window.load();

	Window window;
	auto result = Window.create(window, 640, 480);
	auto device = Renderer.createDevice(&window.width, &window.height, &window.present);

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

	// framebuffer texture
	Texture2D fbTexture;
	TextureParams params = {
		internalFormat : InternalTextureFormat.RGB,
		pixelFormat : PixelFormat.RGB
	};
	auto fb_tex_result = Texture2D.create(fbTexture, cast(ubyte*)null, window.width, window.height, params);

	// create fb with texture	
	SimpleFramebuffer sfb;
	auto sfbResult = fbTexture.asSurface(sfb, false);

	// texture shader stuff
	TextureShader texShader;
	auto texShaderResult = TextureShader.compile(texShader, &ts_vs, &ts_fs);

	int w = window.width;
	int h = window.height;
	// declare texture quad data
	Vertex2f2f[6] vertices = [
		Vertex2f2f([-1.0, -1.0f], [0.0f, 0.0f]), // top left
		Vertex2f2f([1.0f, -1.0f], [1.0f, 0.0f]), // top right
		Vertex2f2f([1.0f, 1.0f], [1.0f, 1.0f]), // bottom right
		Vertex2f2f([-1.0f, -1.0f], [0.0f, 0.0f]), // top left
		Vertex2f2f([-1.0f, 1.0f], [0.0f, 1.0f]), // bottom left
		Vertex2f2f([1.0f, 1.0f], [1.0f, 1.0f]) // bottom right
	];

	auto vertex_data = VertexData(vertices);
	auto texVao = TextureVao.upload(vertex_data, DrawPrimitive.Triangles);

	// load graphics and stuff
	MapShader mapShader;
	auto shader_result = MapShader.compile(mapShader, &ms_vs, &ms_gs, &ms_fs);
	auto map_texture = generateMapTexture(grid); 
	
	// check validity
	if (shader_result != MapShader.Error.Success) {
		writefln("[MAIN] Shader compile failed, exiting!");
		return; // exit now
	}

	// position data
	uint cur_x, cur_y;
	Vec2f[GridSize][GridSize] grid_positions;
	foreach (y, row; grid_positions) {
		foreach (x, col; row) {
			grid_positions[y][x] = [cur_x++, cur_y];
		}
		cur_y++;
		cur_x = 0;
	}

	auto mapData = MapData(cast(Vec2f[])grid_positions);

	// now, upload vertices
	auto vao = MapVao.upload(mapData, DrawPrimitive.Points);

	// set up projection
	Mat4f projection = orthographic(0.0f, window.width, window.height, 0.0f, 0.0f, 1.0f);
	auto transposedProjection = transpose(projection);

	while (window.isAlive) {

		// handle window events
		window.handleEvents();

		// check if it's time to quit
		if (window.isKeyDown(SDL_SCANCODE_ESCAPE)) {
			window.quit();
		}

		// default state, holds all OpenGL state params like blend state etc to be use for given draw call
		DrawParams drawParams = {};

		sfb.clearColour(0xffa500);

		auto mapUniform = MapUniform(&map_texture);
		sfb.draw(mapShader, vao, drawParams, mapUniform);

		// cornflower blue, of course
		auto texUniform = TextureUniform(&fbTexture);
		device.draw(texShader, texVao, drawParams, texUniform);

		device.present();

	}

}
