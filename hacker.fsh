uniform vec2 seed;
uniform Image noise;
uniform float power;
float rand(vec2 co){
    return fract(cos(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
    vec4 pixel = Texel(texture, texture_coords+Texel(noise, (texture_coords+seed*5)*rand(seed)*10).rg*power);
    //float sos = rand(seed);
    //if (<0.5) {
    //	return pixel*1.5;
    //}
    return pixel;
}