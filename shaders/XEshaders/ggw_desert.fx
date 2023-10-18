float3 eyepos;

float4x4 mview;
float4x4 mproj;

texture lastshader;
texture depthframe;

texture heightsmap <string src = "//ggw//heightmap.png";>;

sampler s0 = sampler_state { texture = <lastshader>; addressu = clamp; addressv = clamp; magfilter = point; minfilter = point; };
sampler s1 = sampler_state { texture = <depthframe>; addressu = clamp; addressv = clamp; magfilter = linear; minfilter = linear; };
sampler s2 = sampler_state { texture = <heightsmap>; addressu = clamp; addressv = clamp; magfilter = linear; minfilter = linear; };

float4 sample(sampler2D s, float2 t) {
    return tex2Dlod(s, float4(t, 0, 0));
}

float3 toWorld(float2 tex) {
    float3 rt = float3(mview[0][0], mview[1][0], mview[2][0]);
    float3 up = float3(mview[0][1], mview[1][1], mview[2][1]);
    float3 fw = float3(mview[0][2], mview[1][2], mview[2][2]);

    float x = 1.0f / mproj[0][0];
    float y = -1.0f / mproj[1][1];
    float2 uv = 2.0f * tex - 1.0f;

    return fw + (uv.x * rt * x) + (uv.y * up * y);
}

float getLandscapeHeight(float3 position) {
    float2 co = position.xy;
    co /= 100.0; // de-scale
    co /= 819.2; // normalize to cell size
    co = (co + 1.0) * 0.5; // remap from [-1,+1] to [0,1]

    // sample height
    float height = sample(s2, co).z;

    // re-distribute
    float min = -0.028290145;
    float max = 46.624370575;
    height = height * (max - min) + min;

    // add base height
    height += 32.0;

    // apply scale
    height *= 100.0;

    return height;
}

float4 draw(float2 tex: TEXCOORD0): COLOR {
    float3 color = tex2D(s0, tex);
    float depth = sample(s1, tex);

    float3 direction = toWorld(tex);
    float3 position = eyepos + direction * depth;

    float landscapeHeight = getLandscapeHeight(position);

    if (distance(position.z, landscapeHeight) < 32.0) {
        color.b = 1.0;
    }

    return float4(color, 1.0);
}

technique T0<string MGEinterface = "MGE XE 0";> {
    pass { PixelShader = compile ps_3_0 draw(); }
}
