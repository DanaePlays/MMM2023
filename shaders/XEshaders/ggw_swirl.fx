float3 sphereCenter = float3(0.0, 0.0, 0.0);
float sphereRadius = 1.0;

float tension = 1.0;
float angle = radians(180.0);

float time;

// float fov;
float2 rcpres;

float3 eyepos;
// float3 eyevec;

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

    float x = 1.0 / mproj[0][0];
    float y = -1.0 / mproj[1][1];
    float2 uv = 2.0 * tex - 1.0;

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

float2x2 swirlTransform(float theta) {
    float cs = cos(theta);
    float sn = sin(theta);
    return float2x2(cs, -sn, sn, cs);
}

float4 draw(float2 tex: TEXCOORD0): COLOR {
    float3 color = tex2D(s0, tex);
    float depth = sample(s1, tex);
    float3 direction = toWorld(tex);

    // do nothing if occluded
    float a, b;
    bool intersects = raySphereIntersect(eyepos, direction, sphereCenter, sphereRadius, a, b);
    if (!intersects || depth < min(a, b)) {
        return float4(color, 1.0);
    }

    // calculate screen center
    float4 viewPos = mul(float4(sphereCenter, 1.0), mul(mview, mproj));
    float2 ndcPos = viewPos.xy / viewPos.w;
    float2 center = ndcPos * 0.5 + 0.5;
    center.y = 1.0 - center.y;

    // calculate screen radius
    float radius = 0.5 * mproj[0][0] * (sphereRadius / viewPos.w);

    // do swirling

    center /= 2.0;
    tex -= center;

    float2 resolution = 1.0 / rcpres;
    float aspectRatio = resolution.x / resolution.y;
    center.x /= aspectRatio;
    tex.x /= aspectRatio;

    float distRadius = radius - distance(tex, center);
    float tensionRadius = lerp(distRadius, radius, tension);

    float percent = max(distRadius, 0.0) / tensionRadius;
    float theta = percent * percent * angle * 0.5;

    // animation
    // theta *= saturate(frac(time * 0.05));

    tex = mul(swirlTransform(theta), tex - center);
    tex += 2.0 * center;
    tex.x *= aspectRatio;
    color = tex2D(s0, tex);

    return float4(color, 1.0);
}

technique T0<string MGEinterface = "MGE XE 0";> {
    pass { PixelShader = compile ps_3_0 draw(); }
}
