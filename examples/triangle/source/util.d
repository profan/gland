import std.algorithm : max, swap;
import std.math : sqrt;

import gland.win;

float distance2D(float x1, float y1, float x2, float y2) {
	return sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
} // distance2D

T normalize(T)(T val, T min, T max, T val_max) pure @nogc nothrow {
        return (min + val) / (val_max / (max - min));
} //normalize

/**
 * Takes a mouse position, and grades each component (R, G, B) as 0 to 255 depending on
 *  the direction from top left to top right for R, the direction from top left to bottom right for G,
 *  and the distance from the top left to the bottom left for B.
 * Returns the calculated RGB value.
*/
float[3] posToColour(ref Window win, int m_x, int m_y) {

	float w = win.width, h = win.height;
	float r_dist = distance2D(w, 0, m_x, m_y);
	float g_dist = distance2D(w, h, m_x, m_y);
	float b_dist = distance2D(0, h, m_x, m_y);

	float corner_dist = distance2D(w, h, 0.0, 0.0);
	float furthest_corner = max(w, corner_dist, h);

	float r = normalize(r_dist, 0.0, 1.0, furthest_corner);
	float g = normalize(g_dist, 0.0, 1.0, furthest_corner);
	float b = normalize(b_dist, 0.0, 1.0, furthest_corner);

	return [r, g, b];

} // posToColour

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

T transpose(T)(ref T matrix) {

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

float[4][4] orthographic(float left, float right, float bottom, float top, float near, float far) pure {

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
