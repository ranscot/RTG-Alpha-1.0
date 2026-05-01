shader_type canvas_item;

// This tells the shader to grab whatever the game is currently rendering behind it
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec2 uv = SCREEN_UV;

    // Fetch the actual game pixels
    vec4 color = texture(screen_texture, uv);

    // 1. Scanlines: Darken horizontal rows based on screen coordinates
    float s = sin(uv.y * 1000.0); // 1000.0 controls the density of the lines
    float scanline = clamp(s, 0.85, 1.0); 

    // 2. Vignette: Darken the corners to simulate an old curved glass tube
    float dist = distance(uv, vec2(0.5, 0.5));
    float vignette = smoothstep(0.8, 0.2, dist);

    // Multiply the original game color by the dark lines and dark corners
    COLOR = color * scanline * vignette;
}