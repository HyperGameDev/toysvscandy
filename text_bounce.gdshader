shader_type canvas_item;

group_uniforms Sine;
uniform bool do_abs;
uniform bool do_quantize;
uniform float quantize_to : hint_range(0, 2, 0.1) = 1;
uniform vec2 sine_amplitude = vec2(1.0, 0.0);
uniform vec2 sine_speed = vec2(1.0, 0.0);
uniform float scale_factor : hint_range(0.1, 5.0, 0.1) = 1.0; // Uniform scale factor
uniform float center_position_x = 0.0; // Separate x-coordinate for center
uniform float center_position_y = 0.0; // Separate y-coordinate for center

void vertex() {
    vec2 s = sin(TIME * sine_speed);
    if (do_abs) {
        s = abs(s);
    }
    VERTEX += s * sine_amplitude;
    if (do_quantize) {
        VERTEX = round(VERTEX / quantize_to);
        VERTEX *= quantize_to;
    }

    // Adjust vertices relative to the separated center position before scaling
    VERTEX.x -= center_position_x;
    VERTEX.y -= center_position_y;
    VERTEX *= scale_factor; // Apply uniform scaling
    VERTEX.x += center_position_x;
    VERTEX.y += center_position_y; // Move back after adjustments
}
