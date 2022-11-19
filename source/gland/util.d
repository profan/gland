module gland.util;

import std.algorithm : max, swap;
import std.math : sqrt;
import gfm.math;

import gland.win;

// OpenGL maths related
alias Vec2i = Vector!(int, 2);
alias Vec2f = Vector!(float, 2);
alias Vec3f = Vector!(float, 3);
alias Vec4f = Vector!(float, 4);
alias Mat3f = Matrix!(float, 3, 3);
alias Mat4f = Matrix!(float, 4, 4);

pure @nogc nothrow
float distance2D(float x1, float y1, float x2, float y2) {
	return sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
} // distance2D

T normalize(T)(T val, T min, T max, T val_max) {
	return (min + val) / (val_max / (max - min));
} // normalize

template iota(size_t from, size_t to)
if (from <= to) {
    alias iota = siotaImpl!(to-1, from);
}

private template siotaImpl(size_t to, size_t now) {
    import std.typetuple : TypeTuple;
    static if (now >= to) {
            alias siotaImpl = TypeTuple!(now);
    } else {
            alias siotaImpl = TypeTuple!(now, siotaImpl!(to, now+1));
    }
}

T transpose(T)(auto ref T matrix) {

    auto new_matrix = matrix;
    alias dims = iota!(0, T.length);

    /* foreach over type tuple is implicitly performed at compile time. */
    foreach (x; dims) {
        foreach (y; dims) {
            /* center diagonal, do not swap. */
            static if (x != y) {
                new_matrix[x][y] = matrix[y][x];
                new_matrix[y][x] = matrix[x][y];
            } else {
                break;
            }
        }
    }

    return new_matrix;

} // transpose

nothrow pure @nogc
float[4][4] orthographic(float left, float right, float bottom, float top, float near, float far) {

    float dx = right - left;
    float dy = top - bottom;
    float dz = far - near;

    float tx = -(right + left) / dx;
    float ty = -(top + bottom) / dy;
    float tz = -(far + near)   / dz;

    return [
        [2.0/dx, 0.0, 0.0, tx],
        [0.0, 2.0/dy, 0.0, ty],
        [0.0, 0.0, -2.0/dz, tz],
        [0.0, 0.0, 0.0, 1.0]
    ];

} // orthographic

/**
 * Represents a position, rotation and scale in space, with an optional origin modifier for rotations.
*/
struct Transform {

	private {
		Vec2f position_;
		Vec3f rotation_;
		Vec2f scale_;
		Vec3f origin_;
	}

	this(in Vec2f pos, in Vec3f rotation = Vec3f(0.0f, 0.0f, 0.0f), in Vec2f scale = Vec2f(1.0f, 1.0f)) nothrow @nogc {
		this.position_ = pos;
		this.rotation_ = rotation;
		this.scale_ = scale;
		this.origin_ = Vec3f(0.0f, 0.0f, 0.0f);
	} // this

	@property ref Vec2f position() return {
		return position_;
	}

	@property ref Vec3f rotation() return {
		return rotation_;
	}

	@property void scale(Vec2f newScale) {
		scale_.x = newScale.x;
		scale_.y = newScale.y;
	} // scale

	@property void scale(float newScale) {
		scale_.x = newScale;
		scale_.y = newScale;
	} // scale

	@property float scale() {
		return scale_.x;
	} // scale

	@property Mat4f transform() const nothrow @nogc {

		Mat4f originMatrix = Mat4f.translation(origin_);
		Mat4f posMatrix = Mat4f.translation(Vec3f(position_, 0.0f) - origin_);

		Mat4f rotXMatrix = Mat4f.rotation(rotation_.x, Vec3f(1, 0, 0));
		Mat4f rotYMatrix = Mat4f.rotation(rotation_.y, Vec3f(0, 1, 0));
		Mat4f rotZMatrix = Mat4f.rotation(rotation_.z, Vec3f(0, 0, 1));
		Mat4f scaleMatrix = Mat4f.scaling(Vec3f(scale_, 1.0f));

		Mat4f rotMatrix = rotXMatrix * rotYMatrix * rotZMatrix;

		return posMatrix * rotMatrix * originMatrix * scaleMatrix;

	} // transform

} // Transform

struct Obj {

	import std.conv;
	import std.stdio;
	import std.range;
	import std.algorithm;

	private {

		float[3][] vertices_;
		int[][] faces_;

	}

	static Obj load(string filename) {

		Obj new_obj;

		auto f = File(filename, "r");

		foreach (line; f.byLine) with (new_obj) {
			if (line.startsWith("v ")) {
				float[3] v;
				v = line[2..$].splitter.map!(to!float).array;
				vertices_ ~= v;
			} else if (line.startsWith("f ")) {
				int[] face;
				int tmp;
				foreach (pol; line[2..$].splitter) {
					tmp = to!int(pol.splitter("/").array[0]) - 1;
					face ~= tmp;
				}
				faces_ ~= face;
			}
		}

		return new_obj;

	} // load

	@property {

		auto faces() { return faces_; }
		auto verts() { return vertices_; }

	}

} // Obj
