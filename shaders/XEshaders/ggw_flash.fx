float duration = 1.0;
float elapsed = 0.0;

static const float3 WHITE = float3(1.0, 1.0, 1.0);

texture lastshader;

sampler s0 = sampler_state { texture = <lastshader>; addressu = clamp; addressv = clamp; magfilter = point; minfilter = point; };

float4 draw(float2 tex: TEXCOORD0): COLOR {
    float3 color = tex2D(s0, tex);
    float intensity = elapsed / duration;
    color = lerp(WHITE, color, intensity);
    return float4(color, 1.0);
}

technique T0<string MGEinterface = "MGE XE 0";> {
    pass { PixelShader = compile ps_3_0 draw(); }
}
