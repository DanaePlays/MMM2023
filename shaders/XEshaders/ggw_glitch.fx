float3 sphereCenter = float3(0.0, 0.0, 0.0);
float sphereRadius = 1.0;
float intensity = 0.02;

float time;

float3 eyepos;
float3 eyevec;

float4x4 mview;
float4x4 mproj;

texture lastshader;
texture depthframe;

sampler s0 = sampler_state { texture = <lastshader>; addressu = clamp; addressv = clamp; magfilter = point; minfilter = point; };
sampler s1 = sampler_state { texture = <depthframe>; addressu = clamp; addressv = clamp; magfilter = linear; minfilter = linear; };

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

bool raySphereIntersect(
    float3 rayOrigin,
    float3 rayDirection,
    float3 sphereCenter,
    float sphereRadius,
    out float t1,
    out float t2
) {
    // If the discriminant is negative there's no intersection.
    float3 offset = rayOrigin - sphereCenter;
    float a = dot(rayDirection, rayDirection);
    float b = 2.0 * dot(rayDirection, offset);
    float c = dot(offset, offset) - (sphereRadius * sphereRadius);
    float discriminant = b * b - 4.0 * a * c;
    if (discriminant < 0.0) {
        return false;
    }

    // Calculate intersections.
    float sd = sqrt(discriminant);
    t1 = (-b - sd) / (2.0 * a);
    t2 = (-b + sd) / (2.0 * a);

    // False if behind the ray.
    return t1 > 0.0 || t2 > 0.0;
}

float rand(float co) {
    return frac(sin(co*(91.3458)) * 47453.5453);
}

float2 glitch(float2 tex) {
    float step = 0.05;

    for(float i = 0.0; i < 1.0; i += step) {
        float r = rand(time + i) * intensity;

        if (tex.y >= i && tex.y <= i + step) {
            tex.x += r;
        }
        // if (tex.x >= i && tex.x <= i + step) {
        //     tex.y += r;
        // }
    }

    return tex;
}

float3 aberration(float f) {
    f = f * 3.0 - 1.5;
    return saturate(float3(-f, 1.0 - abs(f), f));
}

float sphereFalloff(
    float3 position,
    float3 sphereCenter,
    float sphereRadius,
    float innerScale = 0.8
) {
    float innerRadius = sphereRadius * innerScale;
    float dist = distance(position, sphereCenter);
    return saturate((dist - innerRadius) / (sphereRadius - innerRadius));
}

float4 draw(float2 tex: TEXCOORD0): COLOR {
    float3 color = tex2D(s0, tex);
    float depth = sample(s1, tex);
    float3 direction = toWorld(tex);

    float a;
    float b;
    bool intersects = raySphereIntersect(eyepos, direction, sphereCenter, sphereRadius, a, b);
    if (intersects) {
        float surfaceDist = min(a, b);
        if (surfaceDist < depth) {
            // sample glitch coords
            float3 glitched = tex2D(s0, glitch(tex));

            // add color aberration
            glitched *= saturate(aberration(rand(time)) + 0.85);

            // add a white outline
            // color = lerp(color, 1.0, 0.04);

            // blend into glitched
            float middleDist = (a + b) * 0.5;
            float3 position = eyepos + direction * middleDist;
            float falloff = sphereFalloff(position, sphereCenter, sphereRadius);
            color = lerp(glitched, color, falloff);
        }
    }

    return float4(color, 1.0);
}

technique T0<string MGEinterface = "MGE XE 0";> {
    pass { PixelShader = compile ps_3_0 draw(); }
}
