float startTime;
float stopTime;

float time;

texture lastshader;

sampler s0 = sampler_state { texture = <lastshader>; addressu = clamp; addressv = clamp; magfilter = point; minfilter = point; };

float4 draw(float2 tex : TEXCOORD0): COLOR {
    float3 color = tex2D(s0, tex);

    float t = saturate((time - startTime) / (stopTime - startTime));
    t = 1.0 - abs(2.0 * t - 1.0); // remap (0 -> 1) to (0 -> 1 -> 0)

    float upper = t * (1.0 - tex.y);
    color = lerp(color, 0.0, upper * 2.2);

    float lower = t * tex.y;
    color = lerp(color, 0.0, lower * 1.8);

    return float4(color, 1.0);
}

technique T0<string MGEinterface = "MGE XE 0";> {
    pass { PixelShader = compile ps_3_0 draw(); }
}
