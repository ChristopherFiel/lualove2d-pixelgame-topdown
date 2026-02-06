local shaders = {}

shaders.light = love.graphics.newShader[[
    extern vec2 playerPos;
    extern vec2 camPos;
    extern vec2 screenSize;

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        // Find the top-left corner of the camera in world space
        vec2 camTopLeft = camPos - (screenSize * 0.5);
        
        // Convert player's world position to screen position
        vec2 playerScreenPos = playerPos - camTopLeft;

        // Calculate distance from current pixel to player
        float dist = distance(screen_coords, playerScreenPos);

        // This creates a "hole". 
        // 0.0 alpha inside 60px, 1.0 alpha outside 300px.
        float mask = smoothstep(60.0, 300.0, dist);

        // We return the color (black) multiplied by the mask (transparency)
        return vec4(color.rgb, color.a * mask);
    }
]]

shaders.whiteout = love.graphics.newShader[[
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        vec4 pixel = Texel(texture, texture_coords);
        return vec4(1.0, 1.0, 1.0, pixel.a);
    }
]]

return shaders