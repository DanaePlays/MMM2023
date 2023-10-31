// Motion Blur
// by Knu
// adapted to MGE XE by Dexter

// **
// ** ADJUSTABLE VARIABLES

#define N 16 // Number of samples. Affects overall quality (smoothness) of the effect and performance.

static float mult_rot = 10.0 / 100.0; // Multiplier for rotational blur.
static float mult_mov = 22.0 / 100.0; // Multiplier for movement blur.
static float mask_distance = 33.0; // Set higher, if your hands/weapon get blurred.
static float max_blur = 10.0; // Maximum blur about in % of screen width.

// ** END OF
// **

float mviewLast[16]; // from lua

float fov;
float frametime = 33.0 / 1000.0;
float4x4 mview;
float2 rcpres;

static float mult_now = mult_rot / mult_mov;
static float2 t = 2.0 * tan(radians(fov * 0.5)) * float2(1.0, -rcpres.x / rcpres.y);
static float sky = 100000;
static float2 raspect = rcpres.x / rcpres;
static float max_blur_m = max_blur / 100.0;

texture lastshader;
texture lastpass;
texture depthframe;

sampler sDepth = sampler_state { texture = <depthframe>; addressu = clamp; addressv = clamp; magfilter = point; minfilter = point; };
sampler sFrame = sampler_state { texture = <lastshader>; magfilter = point; minfilter = point; };
sampler sPass = sampler_state { texture = <lastpass>;  addressu = mirror; addressv = mirror; magfilter = point; minfilter = point; };

float3 toView(float2 tex, float depth) {
    float2 xy = (tex - 0.5) * depth * t;
    return float3(xy, depth);
}

float2 fromView(float3 view) {
    return view / t / view.z + 0.5;
}

float4 Mask(in float2 tex: TEXCOORD): COLOR0 {
    float mask = (tex2D(sDepth, tex).r > mask_distance);
    return mask ? tex2D(sFrame, tex) : 0;
}

float4x4 inverse(float4x4 m) {
    float n11 = m[0][0], n12 = m[1][0], n13 = m[2][0], n14 = m[3][0];
    float n21 = m[0][1], n22 = m[1][1], n23 = m[2][1], n24 = m[3][1];
    float n31 = m[0][2], n32 = m[1][2], n33 = m[2][2], n34 = m[3][2];
    float n41 = m[0][3], n42 = m[1][3], n43 = m[2][3], n44 = m[3][3];

    float t11 = n23 * n34 * n42 - n24 * n33 * n42 + n24 * n32 * n43 - n22 * n34 * n43 - n23 * n32 * n44 + n22 * n33 * n44;
    float t12 = n14 * n33 * n42 - n13 * n34 * n42 - n14 * n32 * n43 + n12 * n34 * n43 + n13 * n32 * n44 - n12 * n33 * n44;
    float t13 = n13 * n24 * n42 - n14 * n23 * n42 + n14 * n22 * n43 - n12 * n24 * n43 - n13 * n22 * n44 + n12 * n23 * n44;
    float t14 = n14 * n23 * n32 - n13 * n24 * n32 - n14 * n22 * n33 + n12 * n24 * n33 + n13 * n22 * n34 - n12 * n23 * n34;

    float det = n11 * t11 + n21 * t12 + n31 * t13 + n41 * t14;
    float idet = 1.0f / det;

    float4x4 ret;

    ret[0][0] = t11 * idet;
    ret[0][1] = (n24 * n33 * n41 - n23 * n34 * n41 - n24 * n31 * n43 + n21 * n34 * n43 + n23 * n31 * n44 - n21 * n33 * n44) * idet;
    ret[0][2] = (n22 * n34 * n41 - n24 * n32 * n41 + n24 * n31 * n42 - n21 * n34 * n42 - n22 * n31 * n44 + n21 * n32 * n44) * idet;
    ret[0][3] = (n23 * n32 * n41 - n22 * n33 * n41 - n23 * n31 * n42 + n21 * n33 * n42 + n22 * n31 * n43 - n21 * n32 * n43) * idet;

    ret[1][0] = t12 * idet;
    ret[1][1] = (n13 * n34 * n41 - n14 * n33 * n41 + n14 * n31 * n43 - n11 * n34 * n43 - n13 * n31 * n44 + n11 * n33 * n44) * idet;
    ret[1][2] = (n14 * n32 * n41 - n12 * n34 * n41 - n14 * n31 * n42 + n11 * n34 * n42 + n12 * n31 * n44 - n11 * n32 * n44) * idet;
    ret[1][3] = (n12 * n33 * n41 - n13 * n32 * n41 + n13 * n31 * n42 - n11 * n33 * n42 - n12 * n31 * n43 + n11 * n32 * n43) * idet;

    ret[2][0] = t13 * idet;
    ret[2][1] = (n14 * n23 * n41 - n13 * n24 * n41 - n14 * n21 * n43 + n11 * n24 * n43 + n13 * n21 * n44 - n11 * n23 * n44) * idet;
    ret[2][2] = (n12 * n24 * n41 - n14 * n22 * n41 + n14 * n21 * n42 - n11 * n24 * n42 - n12 * n21 * n44 + n11 * n22 * n44) * idet;
    ret[2][3] = (n13 * n22 * n41 - n12 * n23 * n41 - n13 * n21 * n42 + n11 * n23 * n42 + n12 * n21 * n43 - n11 * n22 * n43) * idet;

    ret[3][0] = t14 * idet;
    ret[3][1] = (n13 * n24 * n31 - n14 * n23 * n31 + n14 * n21 * n33 - n11 * n24 * n33 - n13 * n21 * n34 + n11 * n23 * n34) * idet;
    ret[3][2] = (n14 * n22 * n31 - n12 * n24 * n31 - n14 * n21 * n32 + n11 * n24 * n32 + n12 * n21 * n34 - n11 * n22 * n34) * idet;
    ret[3][3] = (n12 * n23 * n31 - n13 * n22 * n31 + n13 * n21 * n32 - n11 * n23 * n32 - n12 * n21 * n33 + n11 * n22 * n33) * idet;

    return ret;
}

float4 MotionBlur(in float2 tex: TEXCOORD): COLOR0 {
    float depth = min(tex2D(sDepth, tex).r, sky);

    float4 now = float4(toView(tex, depth) * mult_now, 1.0);
    float4 then = mul(mul(now, inverse(mview)), float4x4(mviewLast));
    float2 motion = tex - fromView(then);

    float m = length(motion * raspect);
    m = min(m, max_blur_m) / m / frametime * mult_rot;
    motion *= m;
    float2 s_tex = tex - motion;
    motion /= float(N);

    float4 color = 0;
    if (depth > mask_distance) {
        for (int i = 0; i <= 2 * N; i++) {
            color += pow(tex2D(sPass, s_tex), 2.2);
            s_tex += motion * 2.7 * exp(-max(i - N + 1,1));
        }
        color /= float(N * 2 + 1);
    }

    if (depth > mask_distance * 1.1) {
        return float4(pow(color.xyz, 1.0 / 2.2), 1.0);
    } else {
        return tex2D(sFrame, tex);
    }
}

technique T0 < string MGEinterface = "MGE XE 0"; > {
    pass {
        PixelShader = compile ps_3_0 Mask();
    }
    pass {
        PixelShader = compile ps_3_0 MotionBlur();
    }
}