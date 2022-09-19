import std.algorithm : move;
import std.typecons : tuple;
import std.stdio;
import std.meta;

import derelict.sdl2.sdl;

import gland.util;
import gland.win;
import gland.gl;

import gfm.math;

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
	layout (triangle_strip, max_vertices = 6) out;

	uniform sampler2D texture_map;
	uniform mat4 projection;

	out vec4 gs_colour;

	void march_squares(mat4 transform, vec4 origin, int which) {

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
				gl_Position = transform * (origin + offset_1);
				EmitVertex();

				vec4 offset_2 = vec4(0.5, -1.0, 0.0, 1.0);
				gl_Position = transform * (origin + offset_2);
				EmitVertex();

				vec4 offset_3 = vec4(0.0, -0.5, 0.0, 1.0);
				gl_Position = transform * (origin + offset_3);
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
				gl_Position = transform * (origin + offset_1);
				EmitVertex();

				vec4 offset_2 = vec4(1.0, -0.5, 0.0, 1.0);
				gl_Position = transform * (origin + offset_2);
				EmitVertex();

				vec4 offset_3 = vec4(0.5, -1.0, 0.0, 1.0);
				gl_Position = transform * (origin + offset_3);
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

				vec4 offset_1 = vec4(0.0, -0.5, 0.0, 1.0);
				gl_Position = transform * (origin + offset_1);
				EmitVertex();

				vec4 offset_2 = vec4(1.0, -0.5, 0.0, 1.0);
				gl_Position = transform * (origin + offset_2);
				EmitVertex();

				vec4 offset_3 = vec4(0.0, -1.0, 0.0, 1.0);
				gl_Position = transform * (origin + offset_3);
				EmitVertex();

				vec4 offset_4 = vec4(1.0, -1.0, 0.0, 1.0);
				gl_Position = transform * (origin + offset_4);
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
				gl_Position = transform * (origin + offset_1);
				EmitVertex();

				vec4 offset_2 = vec4(0.5, 0.0, 0.0, 1.0);
				gl_Position  = transform * (origin + offset_2);
				EmitVertex();

				vec4 offset_3 = vec4(1.0, -0.5, 0.0, 1.0);
				gl_Position = transform * (origin + offset_3);
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
				gl_Position = transform * (origin + offset_1);
				EmitVertex();

				vec4 offset_1_mid = vec4(1.0, 0.0, 0.0, 1.0);
				gl_Position = transform * (origin + offset_1_mid);
				EmitVertex();

				vec4 offset_4 = vec4(0.0, -0.5, 0.0, 1.0);
				gl_Position = transform * (origin + offset_4);
				EmitVertex();

				vec4 offset_2 = vec4(1.0, -0.5, 0.0, 1.0);
				gl_Position = transform * (origin + offset_2);
				EmitVertex();

				vec4 offset_3_mid = vec4(0.0, -1.0, 0.0, 1.0);
				gl_Position = transform * (origin + offset_3_mid);
				EmitVertex();

				vec4 offset_3 = vec4(0.5, -1.0, 0.0, 1.0);
				gl_Position = transform * (origin + offset_3);
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
				gl_Position = transform * (origin + offset_1);
				EmitVertex();

				vec4 offset_2 = vec4(0.5, 0.0, 0.0, 1.0);
				gl_Position = transform * (origin + offset_2);
				EmitVertex();

				vec4 offset_3 = vec4(1.0, -1.0, 0.0, 1.0);
				gl_Position = transform * (origin + offset_3);
				EmitVertex();

				vec4 offset_4 = vec4(1.0, 0.0, 0.0, 1.0);
				gl_Position = transform * (origin + offset_4);
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
				gl_Position = transform * (origin + offset_1);
				EmitVertex();

				vec4 offset_2 = vec4(0.5, 0.0, 0.0, 1.0);
				gl_Position = transform * (origin + offset_2);
				EmitVertex();

				vec4 offset_3 = vec4(1.0, -1.0, 0.0, 1.0);
				gl_Position = transform * (origin + offset_3);
				EmitVertex();

				vec4 offset_4 = vec4(0.0, -0.5, 0.0, 1.0);
				gl_Position = transform * (origin + offset_4);
				EmitVertex();

				vec4 offset_5 = vec4(0.0, -1.0, 0.0, 1.0);
				gl_Position = transform * (origin + offset_5);
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
				gl_Position = transform * (origin + offset_1);
				EmitVertex();

				vec4 offset_2 = vec4(0.0, -0.5, 0.0, 1.0);
				gl_Position = transform * (origin + offset_2);
				EmitVertex();

				vec4 offset_3 = vec4(0.5, 0.0, 0.0, 1.0);
				gl_Position = transform * (origin + offset_3);
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

				vec4 offset_1 = vec4(0.0, -1.0, 0.0, 1.0);
				gl_Position = transform * (origin + offset_1);
				EmitVertex();

				vec4 offset_2 = vec4(0.5, -1.0, 0.0, 1.0);
				gl_Position = transform * (origin + offset_2);
				EmitVertex();

				vec4 offset_3 = vec4(0.0, 0.0, 0.0, 1.0);
				gl_Position = transform * (origin + offset_3);
				EmitVertex();

				vec4 offset_4 = vec4(0.5, 0.0, 0.0, 1.0);
				gl_Position = transform * (origin + offset_4);
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
				gl_Position = transform * (origin + offset_1);
				EmitVertex();

				vec4 offset_1_mid = vec4(0.0, 0.0, 0.0, 1.0);
				gl_Position = transform * (origin + offset_1_mid);
				EmitVertex();

				vec4 offset_2 = vec4(0.5, -1.0, 0.0, 1.0);
				gl_Position = transform * (origin + offset_2);
				EmitVertex();

				vec4 offset_3 = vec4(0.5, 0.0, 0.0, 1.0);
				gl_Position = transform * (origin + offset_3);
				EmitVertex();

				vec4 offset_3_mid = vec4(1.0, -1.0, 0.0, 1.0);
				gl_Position = transform * (origin + offset_3_mid);
				EmitVertex();

				vec4 offset_4 = vec4(1.0, -0.5, 0.0, 1.0);
				gl_Position = transform * (origin + offset_4);
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
				gl_Position = transform * (origin + offset_1);
				EmitVertex();

				vec4 offset_2 = vec4(0.5, 0.0, 0.0, 1.0);
				gl_Position = transform * (origin + offset_2);
				EmitVertex();

				vec4 offset_3 = vec4(0.0, -1.0, 0.0, 1.0);
				gl_Position = transform * (origin + offset_3);
				EmitVertex();

				vec4 offset_4 = vec4(1.0, -0.5, 0.0, 1.0);
				gl_Position = transform * (origin + offset_4);
				EmitVertex();

				vec4 offset_5 = vec4(1.0, -1.0, 0.0, 1.0);
				gl_Position = transform * (origin + offset_5);
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

				vec4 offset_1 = vec4(0.0, 0.0, 0.0, 1.0);
				gl_Position = transform * (origin + offset_1);
				EmitVertex();

				vec4 offset_2 = vec4(1.0, 0.0, 0.0, 1.0);
				gl_Position = transform * (origin + offset_2);
				EmitVertex();

				vec4 offset_3 = vec4(0.0, -0.5, 0.0, 1.0);
				gl_Position = transform * (origin + offset_3);
				EmitVertex();

				vec4 offset_4 = vec4(1.0, -0.5, 0.0, 1.0);
				gl_Position = transform * (origin + offset_4);
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
				gl_Position = transform * (origin + offset_1);
				EmitVertex();

				vec4 offset_2 = vec4(0.5, -1.0, 0.0, 1.0);
				gl_Position = transform * (origin + offset_2);
				EmitVertex();

				vec4 offset_3 = vec4(0.0, 0.0, 0.0, 1.0);
				gl_Position = transform * (origin + offset_3);
				EmitVertex();

				vec4 offset_4 = vec4(1.0, -0.5, 0.0, 1.0);
				gl_Position = transform * (origin + offset_4);
				EmitVertex();

				vec4 offset_5 = vec4(1.0, 0.0, 0.0, 1.0);
				gl_Position = transform * (origin + offset_5);
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
				gl_Position = transform * (origin + offset_1);
				EmitVertex();

				vec4 offset_2 = vec4(0.0, 0.0, 0.0, 1.0);
				gl_Position = transform * (origin + offset_2);
				EmitVertex();

				vec4 offset_3 = vec4(1.0, -1.0, 0.0, 1.0);
				gl_Position = transform * (origin + offset_3);
				EmitVertex();

				vec4 offset_4 = vec4(0.0, -0.5, 0.0, 1.0);
				gl_Position = transform * (origin + offset_4);
				EmitVertex();

				vec4 offset_5 = vec4(0.5, -1.0, 0.0, 1.0);
				gl_Position = transform * (origin + offset_5);
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
				gl_Position = transform * (origin + offset_1);
				EmitVertex();

				vec4 offset_2 = vec4(0.0, -1.0, 0.0, 1.0);
				gl_Position = transform * (origin + offset_2);
				EmitVertex();

				vec4 offset_3 = vec4(1.0, 0.0, 0.0, 1.0);
				gl_Position = transform * (origin + offset_3);
				EmitVertex();

				vec4 offset_4 = vec4(1.0, -1.0, 0.0, 1.0);
				gl_Position =  transform * (origin + offset_4);
				EmitVertex();

				EndPrimitive();

				break;

			}
		}

	} // march_squares

	void main() {

		vec4 origin = gl_in[0].gl_Position;
		ivec2 coord = ivec2(origin.xy);
		
		ivec2 size = textureSize(texture_map, 0);
		float colour = texelFetch(texture_map, coord, 0).r * 10;

		float top_left = texelFetch(texture_map, coord + ivec2(0, 0), 0).r * 255.0f;
		float top_right = texelFetch(texture_map, coord + ivec2(1, 0), 0).r * 255.0f;
		float bottom_left = texelFetch(texture_map, coord + ivec2(0, 1), 0).r * 255.0f;
		float bottom_right = texelFetch(texture_map, coord + ivec2(1, 1), 0).r * 255.0f;

		int bv = 10;
		int tl_bit = top_left > bv ? (1 << 0) : 0;
		int tr_bit = top_right > bv ? (1 << 1) : 0;
		int br_bit = bottom_right > bv ? (1 << 2) : 0;
		int bl_bit = bottom_left > bv ? (1 << 3) : 0;
		int result = tl_bit | tr_bit | br_bit | bl_bit;

		// pass colour over to fragment shader
		gs_colour = result != 0.0
			? vec4(0.5, 0.0, 0.0, 1.0)
			: vec4(0.0, 0.0, 0.0, 0.0);

		march_squares(projection, origin, result);

	}

};

immutable char* ms_fs = q{
	#version 330 core

	in vec4 gs_colour;

	out vec4 f_colour;

	void main() {
		f_colour = gs_colour;
	}
};

alias Vec2u = Vector!(uint, 2);
alias Vec2f = Vector!(float, 2);
alias Vec4f = Vector!(float, 4);
alias Mat4f = Matrix!(float, 4, 4);
alias Height = ubyte;

struct MapUniform {

	@TextureUnit(0)
	Texture2D* texture_map;

	float[4][4][] projection;

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
	float[2][] positions;

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

Height[] generateGrid(int width, int height, ubyte insideValue, ubyte outsideValue) {

	bool isBoundary(int w, int h, int x, int y) {
		return x <= 1 || y <= 2 || x >= (w - 1) || y >= (h - 1);
	}

	Height[] newGrid = new Height[width * height];

	for (int x = 0; x < width; ++x)
	{
		for (int y = 0; y < height; ++y) {
			newGrid[x + width * y] = isBoundary(width, height, x, y) ? outsideValue : insideValue;
		}
	}

	return newGrid;

}

Texture2D generateMapTexture(in Height[] cells, int width, int height) {

	TextureParams params = {
		internalFormat : InternalTextureFormat.R8,
		pixelFormat : PixelFormat.Red,
		packAlignment : PixelPack.One,
		unpackAlignment : PixelPack.One,
		wrapping : TextureWrapping.Repeat,
		mipmapMaxLevel : 0
	};

	Texture2D newTexture;
	auto textureResult = Texture2D.create(newTexture, cast(ubyte*)cells.ptr, width, height, params);

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

	// create our grid
	auto backgroundGridWidth = 32;
	auto backgroundGridHeight = 32;
	auto backgroundGrid = generateGrid(backgroundGridWidth, backgroundGridHeight, 15, 5);

	// load graphics and stuff
	MapShader mapShader;
	auto shaderResult = MapShader.compile(mapShader, &ms_vs, &ms_gs, &ms_fs);
	auto mapTexture = generateMapTexture(backgroundGrid, backgroundGridWidth, backgroundGridHeight);
	
	// check validity
	if (shaderResult != MapShader.Error.Success) {
		writefln("[MAIN] Shader compile failed, exiting!");
		return; // exit now
	}

	// position data (points)
	uint cur_x, cur_y;
	float[2][] gridPositions = new float[2][backgroundGridWidth * backgroundGridHeight];
	for (int y = 0; y < backgroundGridHeight; ++y) {
		for (int x = 0; x < backgroundGridWidth; ++x) {
			gridPositions[x + backgroundGridWidth * y] = [cur_x++, cur_y];
		}
		cur_y++;
		cur_x = 0;
	}

	// upload the list of positions to put points at that will be the GS input
	auto mapData = MapData(cast(float[2][])gridPositions);

	// now, upload vertices
	auto vao = MapVao.upload(mapData, DrawPrimitive.Points);

	// set up projection
	Mat4f screenProjection = Mat4f.orthographic(0.0f, window.width, window.height, 0.0f, 0.0f, 1.0f);

	// set up camera projection with translation
	auto camera = Transform(Vec2f(0.0f, 0.0f));
	camera.scale = Vec2f(
		(window.width / cast(float)backgroundGridWidth) * 2.0f,
		(window.height / cast(float)backgroundGridHeight) * 2.0f
	);

	Vec2f mouseToWorldPosition(float mouseX, float mouseY) {
		auto worldPosition = camera.transform.inverse() * Vec4f(mouseX, mouseY, 0.0f, 1.0f);
		return worldPosition.xy * 2.0f;
	}

	Vec2u mouseToGridPosition(float mouseX, float mouseY) {
		auto worldPosition = mouseToWorldPosition(mouseX, mouseY);
		return Vec2u(
			cast(uint)worldPosition.x,
			cast(uint)worldPosition.y
		);
	}

	Vec2u currentMouseToGridPosition() {
		auto mousePosition = window.getMousePosition();
		return mouseToGridPosition(
			mousePosition[0],
			mousePosition[1]
		);
	}

	Texture2D uploadTextureDataWithGrid() {
		return generateMapTexture(backgroundGrid, backgroundGridWidth, backgroundGridHeight);
	}

	while (window.isAlive) {

		auto currentProjection = screenProjection * camera.transform();
		auto transposedProjection = currentProjection.transposed();

		// handle window events
		window.handleEvents();

		// add to the grid on left mouse, remove on right
		if (window.isMouseButtonDown(SDL_BUTTON_LEFT)) {
			auto gridPosition = currentMouseToGridPosition();
			backgroundGrid[gridPosition.x + backgroundGridWidth * gridPosition.y] = 15;
			auto newMapTexture = uploadTextureDataWithGrid();
			move(newMapTexture, mapTexture);
		}

		if (window.isMouseButtonDown(SDL_BUTTON_RIGHT)) {
			auto gridPosition = currentMouseToGridPosition();
			backgroundGrid[gridPosition.x + backgroundGridWidth * gridPosition.y] = 0;
			auto newMapTexture = uploadTextureDataWithGrid();
			move(newMapTexture, mapTexture);
		}

		// check if it's time to quit
		if (window.isKeyDown(SDL_SCANCODE_ESCAPE)) {
			window.quit();
		}

		device.clearColour(0x428bca);

		// default state, holds all OpenGL state params like blend state etc to be use for given draw call
		DrawParams drawParams = {
			blendSrc : BlendFunc.SrcAlpha,
			blendDst : BlendFunc.OneMinusSrcAlpha,
			blendEq : BlendEquation.Add,
			state: {
				cullFace : false,
				depthTest : false,
				scissorTest : false,
				blendTest : true
			}
		};

		sfb.clearColour(0xffa500);

		// map is drawn to our framebuffer

		float[4][4][1] projectionData = [*(cast(float[4][4]*)(transposedProjection.ptr))];
		auto mapUniform = MapUniform(&mapTexture, projectionData[]);
		sfb.draw(mapShader, vao, drawParams, mapUniform);

		// frame buffer texture is then rendered
		auto texUniform = TextureUniform(&fbTexture);
		device.draw(texShader, texVao, drawParams, texUniform);

		device.present();

	}

}
