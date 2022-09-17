import std.traits : isDelegate, ReturnType, ParameterTypeTuple;
import std.algorithm.mutation : move;
import std.typecons : tuple;
import std.stdio;
import std.meta;

import core.stdc.stdio : printf;
import derelict.imgui.imgui;
import derelict.sdl2.sdl;

import gland.util;
import gland.win;
import gland.gl;

auto bindDelegate(T, string file = __FILE__, size_t line = __LINE__)(T t) if(isDelegate!T) {

	static T dg;
	dg = t;

	extern(C) static ReturnType!T func(ParameterTypeTuple!T args) {
		return dg(args);
	}

	return &func;

} // bindDelegate (thanks Destructionator)

immutable char* vs_source = q{
	#version 330 core

	uniform mat4 ProjMtx;

	layout(location = 0) in vec2 Position;
	layout(location = 1) in vec2 UV;
	layout(location = 2) in vec4 Color;

	out vec2 Frag_UV;
	out vec4 Frag_Color;

	void main() {
		Frag_UV = UV;
		Frag_Color = Color;
		gl_Position = ProjMtx * vec4(Position.xy, 0, 1);
	}
};

immutable char* fs_source = q{
	#version 330 core

	uniform sampler2D Texture_;

	in vec2 Frag_UV;
	in vec4 Frag_Color;

	out vec4 Out_Color;

	void main() {
		Out_Color = Frag_Color * texture(Texture_, Frag_UV.st);
	}
};

struct ImguiUniform {

	float[4][4][] ProjMtx;

	@TextureUnit(0)
	OpaqueTexture* Texture_; // @suppress(dscanner.style.phobos_naming_convention)

} // ImguiUniform

alias ImguiShader = Shader!(
	[ShaderType.VertexShader, ShaderType.FragmentShader], [
		AttribTuple("Position", 0),
		AttribTuple("UV", 1),
		AttribTuple("Color", 2)
	], ImguiUniform
);

struct ImVert {

	// make sure that size of our struct matches the one in the lib
	static assert(typeof(this).sizeof == ImDrawVert.sizeof);

	float[2] position;
	float[2] uv;

	@Normalized
	ubyte[4] col;

} // ImVert

@(ManualCountProvider)
@(DrawType.DrawElements)
struct ImguiData {

	@(DrawHint.StreamDraw)
	@(BufferTarget.ArrayBuffer)
	ImVert[] vertices;

	@TypeProvider // it gets the element type from this
	@(DrawHint.StreamDraw)
	@(BufferTarget.ElementArrayBuffer)
	ImDrawIdx[] indices;

} // ImguiData

alias ImguiVao = VertexArrayT!ImguiData;

struct ImguiContext {

	import derelict.sdl2.types;

	private {

		// wandow
		Window* window_;

		// graphics device
		Device* device_;

		// graffix data
		ImguiShader shader_;
		Texture2D texture_;
		ImguiVao vao_;

		double time_;
		bool[3] mouse_buttons_pressed_;
		float scroll_wheel_;

	}

	@disable this(this);
	
	static void load() {

		import derelict.util.exception;

		ShouldThrow ignoreMissing(string symbolName) {

			if (symbolName == "igSetNextTreeNodeOpened" ||
				symbolName == "igGetInternalState" ||
				symbolName == "igGetInternalStateSize" ||
				symbolName == "igSetInternalState") {
				return ShouldThrow.No;
			}
			
			return ShouldThrow.Yes;

		} // ignoreMissing

		DerelictImgui.missingSymbolCallback = &ignoreMissing;
		DerelictImgui.load();

	} // load

	void initialize(Window* window, Device* device) {

		// DEPS
		window_ = window;
		device_ = device;

		ImGuiIO* io = igGetIO();

		io.KeyMap[ImGuiKey_Tab] = SDL_SCANCODE_KP_TAB;
		io.KeyMap[ImGuiKey_LeftArrow] = SDL_SCANCODE_LEFT;
		io.KeyMap[ImGuiKey_RightArrow] = SDL_SCANCODE_RIGHT;
		io.KeyMap[ImGuiKey_UpArrow] = SDL_SCANCODE_UP;
		io.KeyMap[ImGuiKey_DownArrow] = SDL_SCANCODE_DOWN;
		io.KeyMap[ImGuiKey_Home] = SDL_SCANCODE_HOME;
		io.KeyMap[ImGuiKey_End] = SDL_SCANCODE_END;
		io.KeyMap[ImGuiKey_Backspace] = SDL_SCANCODE_BACKSPACE;
		io.KeyMap[ImGuiKey_Delete] = SDL_SCANCODE_DELETE;
		io.KeyMap[ImGuiKey_Escape] = SDL_SCANCODE_ESCAPE;
		io.KeyMap[ImGuiKey_Enter] = SDL_SCANCODE_RETURN;
		io.KeyMap[ImGuiKey_Z] = SDL_SCANCODE_Z;

		io.RenderDrawListsFn = bindDelegate(&renderDrawLists);
		io.SetClipboardTextFn = bindDelegate(&setClipboardText);
		io.GetClipboardTextFn = bindDelegate(&getClipboardText);

		createDeviceObjects();

	} // initialize

	void onEvent(ref SDL_Event ev) {

		import core.stdc.stdio : printf;

		auto io = igGetIO();

		switch (ev.type) {

			case SDL_KEYDOWN, SDL_KEYUP:
				io.KeysDown[ev.key.keysym.scancode] = (ev.type == SDL_KEYDOWN);

				auto mods = ev.key.keysym.mod;
				io.KeyCtrl = (mods & KMOD_CTRL) != 0;
				io.KeyShift = (mods & KMOD_SHIFT) != 0;
				io.KeyAlt = (mods & KMOD_ALT) != 0;

				break;

			case SDL_MOUSEBUTTONDOWN, SDL_MOUSEBUTTONUP:
				auto btn = ev.button.button;

				if (btn < 4) {
					mouse_buttons_pressed_[btn-1] = (ev.type == SDL_MOUSEBUTTONDOWN);
				}

				break;

			case SDL_MOUSEWHEEL:
				scroll_wheel_ += ev.wheel.y;
				break;

			case SDL_TEXTINPUT:
				ImGuiIO_AddInputCharacter(cast(ushort)ev.text.text[0]);
				break;

			default:
				printf("unhandled event type in imgui: %d", ev.type);

		}

	} // onEvent

	void createDeviceObjects() {

		auto shader_result = ImguiShader.compile(shader_, &vs_source, &fs_source);

		ImguiData data = {};
		auto vao = ImguiVao.upload(data, DrawPrimitive.Triangles);
		move(vao, vao_);

		/* generate teh fonts */
		createFontTexture();

	} // createDeviceObjects

	void createFontTexture() {

		auto io = igGetIO();

		ubyte* pixels;
		int width, height;
		int bytes_per_pixel;
		ImFontAtlas_GetTexDataAsRGBA32(io.Fonts, &pixels, &width, &height, &bytes_per_pixel);

		TextureParams tex_params = {
			internalFormat : InternalTextureFormat.RGBA,
			pixelFormat : PixelFormat.RGBA,
			wrapping : TextureWrapping.ClampToEdge,
			filtering : TextureFiltering.Linear
		};

		auto tex_result = Texture2D.create(texture_, pixels, width, height, tex_params);
		ImFontAtlas_SetTexID(io.Fonts, cast(void*)texture_.handle);

	} // createFontTexture

	nothrow
	void renderDrawLists(ImDrawData* data) {

		import gland.util : orthographic, transpose;
		
		auto proj = orthographic(0.0f, window_.width, window_.height, 0.0f, 0.0f, 1.0f);
		float[4][4][1] proj_data = [transpose(proj)];

		DrawParams draw_params = {
			blendSrc : BlendFunc.SrcAlpha,
			blendDst : BlendFunc.OneMinusSrcAlpha,
			blendEq : BlendEquation.Add,
			state: {
				cullFace : false,
				depthTest : false,
				scissorTest : true,
				blendTest : true
			}
		};

		int width = window_.width;
		int height = window_.height;

		foreach (n; 0..data.CmdListsCount) {

			ImDrawList* cmd_list = data.CmdLists[n];
			ImDrawIdx* idx_buffer_offset;

			auto countVertices = ImDrawList_GetVertexBufferSize(cmd_list);
			auto countIndices = ImDrawList_GetIndexBufferSize(cmd_list);

			ImVert[] new_vertex_data = (cast(ImVert*)ImDrawList_GetVertexPtr(cmd_list, 0))[0..countVertices];
			ImDrawIdx[] new_index_data = ImDrawList_GetIndexPtr(cmd_list, 0)[0..countIndices];
			auto new_data = ImguiData(new_vertex_data, new_index_data);

			// upload new vertex data
			ImguiVao.update(vao_, new_data, DrawPrimitive.Triangles);

			auto cmdCnt = ImDrawList_GetCmdSize(cmd_list);

			foreach(i; 0..cmdCnt) {

				auto pcmd = ImDrawList_GetCmdPtr(cmd_list, i);

				if (pcmd.UserCallback) {
					pcmd.UserCallback(cmd_list, pcmd);
				} else {
					
					// these are some arbitrary as fuck numbers by the way TODO: fix cliprects
					draw_params.state.scissorBox = tuple(
						cast(int)(pcmd.ClipRect.x)-15,
						cast(int)(height - pcmd.ClipRect.w)-15,
						cast(int)(pcmd.ClipRect.z - pcmd.ClipRect.x)+50,
						cast(int)(pcmd.ClipRect.w - pcmd.ClipRect.y)+50
					);
			
					// temporary opaque texture
					OpaqueTexture cur_texture = Texture.fromId(cast(uint)pcmd.TextureId, TextureType.Texture2D);
					auto uniform_data = ImguiUniform(proj_data[], &cur_texture);
					(*device_).drawOffset(shader_, vao_, draw_params, pcmd.ElemCount, idx_buffer_offset, uniform_data);
					
				}
				
				idx_buffer_offset += pcmd.ElemCount;
				
			}
		}

	} // renderDrawLists

	void newFrame(double dt) {

		auto io = igGetIO();

		int display_w = window_.width;
		int display_h = window_.height;
		io.DisplaySize = ImVec2(cast(float)display_w, cast(float)display_h);
		io.DisplayFramebufferScale = ImVec2(1.0f, 1.0f);
		io.DeltaTime = cast(float)dt;

		int m_x, m_y;
		SDL_GetMouseState(&m_x, &m_y);
		io.MousePos = ImVec2(m_x, m_y);

		foreach (i; 0..3) {
			io.MouseDown[i] = mouse_buttons_pressed_[i];
		}

		io.MouseWheel = scroll_wheel_;

		igNewFrame();

	} // newFrame

	void endFrame() {

		igRender();

	} // endFrame

	const(char*) getClipboardText() nothrow {

		import derelict.sdl2.functions : SDL_GetClipboardText;
		return SDL_GetClipboardText();

	} // getClipboardText

	void setClipboardText(const(char)* text) nothrow {

		import derelict.sdl2.functions : SDL_SetClipboardText;
		SDL_SetClipboardText(text);

	} // setClipboardText

} // ImguiContext

void main() {

	// load libs
	Window.load();
	ImguiContext.load();

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

	// LOAD ZE IMGUI
	ImguiContext context;
	context.initialize(&window, &device);

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
		device.clearColour(0x428bca);

		// FRAEMZ
		context.newFrame(1.0);
		igText("Hello, World!");
		context.endFrame();

		device.present();

	}

}
