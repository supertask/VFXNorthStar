Shader "Custom/Converted_SG_Culling_Off"
{
    Properties
    {
        [NoScaleOffset] Texture2D_E94A1D41("MainTex", 2D) = "white" {}
[NoScaleOffset] Texture2D_7262B6FF("BumpMap", 2D) = "bump" {}

    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="HDRenderPipeline"
            "RenderType"="Transparent"
            "Queue"="Transparent+0"
        }
        
        Pass
        {
            // based on HDPBRPass.template
            Name "META"
            Tags { "LightMode" = "META" }
        
            //-------------------------------------------------------------------------------------
            // Render Modes (Blend, Cull, ZTest, Stencil, etc)
            //-------------------------------------------------------------------------------------
            Blend One OneMinusSrcAlpha
        
            Cull Off
        
            ZTest LEqual
        
            ZWrite Off
        
            ZClip [_ZClip]
        
            // Default Stencil
        
            
            //-------------------------------------------------------------------------------------
            // End Render Modes
            //-------------------------------------------------------------------------------------
        
            HLSLPROGRAM
        
            #pragma target 4.5
            #pragma only_renderers d3d11 ps4 xboxone vulkan metal switch
            //#pragma enable_d3d11_debug_symbols
        
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ LOD_FADE_CROSSFADE
        
            //-------------------------------------------------------------------------------------
            // Variant Definitions (active field translations to HDRP defines)
            //-------------------------------------------------------------------------------------
            #define _MATERIAL_FEATURE_SPECULAR_COLOR 1
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _BLENDMODE_ALPHA 1
            #define _DOUBLESIDED_ON 1
        
            //-------------------------------------------------------------------------------------
            // End Variant Definitions
            //-------------------------------------------------------------------------------------
        
            #pragma vertex Vert
            #pragma fragment Frag
        
            // Use surface gradient normal mapping as it handle correctly triplanar normal mapping and multiple UVSet
            // this modifies the normal calculation
            // #define SURFACE_GRADIENT
        
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
        
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/NormalSurfaceGradient.hlsl"
        
            // define FragInputs structure
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
        
            //-------------------------------------------------------------------------------------
            // Defines
            //-------------------------------------------------------------------------------------
                    #define SHADERPASS SHADERPASS_LIGHT_TRANSPORT
        
            // this translates the new dependency tracker into the old preprocessor definitions for the existing HDRP shader code
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define ATTRIBUTES_NEED_COLOR
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_CULLFACE
        
            //-------------------------------------------------------------------------------------
            // End Defines
            //-------------------------------------------------------------------------------------
        
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
            #ifdef DEBUG_DISPLAY
                #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Debug/DebugDisplay.hlsl"
            #endif
        
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
        
        #if (SHADERPASS == SHADERPASS_FORWARD)
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/Lighting.hlsl"
        
            #define HAS_LIGHTLOOP
        
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoopDef.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoop.hlsl"
        #else
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
        #endif
        
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalUtilities.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitDecalData.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
            //Used by SceneSelectionPass
            int _ObjectId;
            int _PassValue;
        
            //-------------------------------------------------------------------------------------
            // Interpolator Packing And Struct Declarations
            //-------------------------------------------------------------------------------------
        // Generated Type: AttributesMesh
        struct AttributesMesh {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL; // optional
            float4 tangentOS : TANGENT; // optional
            float4 uv0 : TEXCOORD0; // optional
            float4 uv1 : TEXCOORD1; // optional
            float4 uv2 : TEXCOORD2; // optional
            float4 color : COLOR; // optional
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif // UNITY_ANY_INSTANCING_ENABLED
        };
        
        // Generated Type: VaryingsMeshToPS
        struct VaryingsMeshToPS {
            float4 positionCS : SV_Position;
            float4 texCoord0; // optional
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif // UNITY_ANY_INSTANCING_ENABLED
            #if SHADER_STAGE_FRAGMENT
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC; // optional
            #endif // SHADER_STAGE_FRAGMENT
        };
        struct PackedVaryingsMeshToPS {
            float4 interp00 : TEXCOORD0; // auto-packed
            float4 positionCS : SV_Position; // unpacked
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC; // unpacked
            #endif // UNITY_ANY_INSTANCING_ENABLED
            #if SHADER_STAGE_FRAGMENT
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC; // unpacked
            #endif // SHADER_STAGE_FRAGMENT
        };
        PackedVaryingsMeshToPS PackVaryingsMeshToPS(VaryingsMeshToPS input)
        {
            PackedVaryingsMeshToPS output;
            output.positionCS = input.positionCS;
            output.interp00.xyzw = input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif // UNITY_ANY_INSTANCING_ENABLED
            #if SHADER_STAGE_FRAGMENT
            output.cullFace = input.cullFace;
            #endif // SHADER_STAGE_FRAGMENT
            return output;
        }
        VaryingsMeshToPS UnpackVaryingsMeshToPS(PackedVaryingsMeshToPS input)
        {
            VaryingsMeshToPS output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp00.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif // UNITY_ANY_INSTANCING_ENABLED
            #if SHADER_STAGE_FRAGMENT
            output.cullFace = input.cullFace;
            #endif // SHADER_STAGE_FRAGMENT
            return output;
        }
        
        // Generated Type: VaryingsMeshToDS
        struct VaryingsMeshToDS {
            float3 positionRWS;
            float3 normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif // UNITY_ANY_INSTANCING_ENABLED
        };
        struct PackedVaryingsMeshToDS {
            float3 interp00 : TEXCOORD0; // auto-packed
            float3 interp01 : TEXCOORD1; // auto-packed
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC; // unpacked
            #endif // UNITY_ANY_INSTANCING_ENABLED
        };
        PackedVaryingsMeshToDS PackVaryingsMeshToDS(VaryingsMeshToDS input)
        {
            PackedVaryingsMeshToDS output;
            output.interp00.xyz = input.positionRWS;
            output.interp01.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif // UNITY_ANY_INSTANCING_ENABLED
            return output;
        }
        VaryingsMeshToDS UnpackVaryingsMeshToDS(PackedVaryingsMeshToDS input)
        {
            VaryingsMeshToDS output;
            output.positionRWS = input.interp00.xyz;
            output.normalWS = input.interp01.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif // UNITY_ANY_INSTANCING_ENABLED
            return output;
        }
        
            //-------------------------------------------------------------------------------------
            // End Interpolator Packing And Struct Declarations
            //-------------------------------------------------------------------------------------
        
            //-------------------------------------------------------------------------------------
            // Graph generated code
            //-------------------------------------------------------------------------------------
                    // Shared Graph Properties (uniform inputs)
                    CBUFFER_START(UnityPerMaterial)
                    CBUFFER_END
                
                    TEXTURE2D(Texture2D_E94A1D41); SAMPLER(samplerTexture2D_E94A1D41); float4 Texture2D_E94A1D41_TexelSize;
                    TEXTURE2D(Texture2D_7262B6FF); SAMPLER(samplerTexture2D_7262B6FF); float4 Texture2D_7262B6FF_TexelSize;
                
                // Pixel Graph Inputs
                    struct SurfaceDescriptionInputs {
                        float4 uv0; // optional
                    };
                // Pixel Graph Outputs
                    struct SurfaceDescription
                    {
                        float3 Albedo;
                        float3 Normal;
                        float3 Specular;
                        float3 Emission;
                        float Smoothness;
                        float Occlusion;
                        float Alpha;
                        float AlphaClipThreshold;
                    };
                    
                // Shared Graph Node Functions
                
                    void Unity_NormalFromTexture_float(Texture2D Texture, SamplerState Sampler, float2 UV, float Offset, float Strength, out float3 Out)
                    {
                        Offset = pow(Offset, 3) * 0.1;
                        float2 offsetU = float2(UV.x + Offset, UV.y);
                        float2 offsetV = float2(UV.x, UV.y + Offset);
                        float normalSample = Texture.Sample(Sampler, UV);
                        float uSample = Texture.Sample(Sampler, offsetU);
                        float vSample = Texture.Sample(Sampler, offsetV);
                        float3 va = float3(1, 0, (uSample - normalSample) * Strength);
                        float3 vb = float3(0, 1, (vSample - normalSample) * Strength);
                        Out = normalize(cross(va, vb));
                    }
                
                // Pixel Graph Evaluation
                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                    {
                        SurfaceDescription surface = (SurfaceDescription)0;
                        float3 _NormalFromTexture_CA0B55E7_Out;
                        Unity_NormalFromTexture_float(Texture2D_7262B6FF, samplerTexture2D_7262B6FF, IN.uv0.xy, 0.5, 8, _NormalFromTexture_CA0B55E7_Out);
                    
                        float4 _SampleTexture2D_25824A8A_RGBA = SAMPLE_TEXTURE2D(Texture2D_E94A1D41, samplerTexture2D_E94A1D41, IN.uv0.xy);
                        float _SampleTexture2D_25824A8A_R = _SampleTexture2D_25824A8A_RGBA.r;
                        float _SampleTexture2D_25824A8A_G = _SampleTexture2D_25824A8A_RGBA.g;
                        float _SampleTexture2D_25824A8A_B = _SampleTexture2D_25824A8A_RGBA.b;
                        float _SampleTexture2D_25824A8A_A = _SampleTexture2D_25824A8A_RGBA.a;
                        surface.Albedo = IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0));
                        surface.Normal = _NormalFromTexture_CA0B55E7_Out;
                        surface.Specular = IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0));
                        surface.Emission = (_SampleTexture2D_25824A8A_RGBA.xyz);
                        surface.Smoothness = 0;
                        surface.Occlusion = 1;
                        surface.Alpha = 1;
                        surface.AlphaClipThreshold = 0;
                        return surface;
                    }
                    
            //-------------------------------------------------------------------------------------
            // End graph generated code
            //-------------------------------------------------------------------------------------
        
        
        
        //-------------------------------------------------------------------------------------
        // TEMPLATE INCLUDE : SharedCode.template.hlsl
        //-------------------------------------------------------------------------------------
            FragInputs BuildFragInputs(VaryingsMeshToPS input)
            {
                FragInputs output;
                ZERO_INITIALIZE(FragInputs, output);
        
                // Init to some default value to make the computer quiet (else it output 'divide by zero' warning even if value is not used).
                // TODO: this is a really poor workaround, but the variable is used in a bunch of places
                // to compute normals which are then passed on elsewhere to compute other values...
                output.worldToTangent = k_identity3x3;
                output.positionSS = input.positionCS;       // input.positionCS is SV_Position
        
                output.texCoord0 = input.texCoord0;
                #if SHADER_STAGE_FRAGMENT
                output.isFrontFace = IS_FRONT_VFACE(input.cullFace, true, false);       // TODO: SHADER_STAGE_FRAGMENT only
                #endif // SHADER_STAGE_FRAGMENT
        
                return output;
            }
        
            SurfaceDescriptionInputs FragInputsToSurfaceDescriptionInputs(FragInputs input, float3 viewWS)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
                output.uv0 =                         input.texCoord0;
        
                return output;
            }
        
            // existing HDRP code uses the combined function to go directly from packed to frag inputs
            FragInputs UnpackVaryingsMeshToFragInputs(PackedVaryingsMeshToPS input)
            {
                UNITY_SETUP_INSTANCE_ID(input);
                VaryingsMeshToPS unpacked= UnpackVaryingsMeshToPS(input);
                return BuildFragInputs(unpacked);
            }
        
        //-------------------------------------------------------------------------------------
        // END TEMPLATE INCLUDE : SharedCode.template.hlsl
        //-------------------------------------------------------------------------------------
        
        
        
            void BuildSurfaceData(FragInputs fragInputs, inout SurfaceDescription surfaceDescription, float3 V, PositionInputs posInput, out SurfaceData surfaceData)
            {
                // setup defaults -- these are used if the graph doesn't output a value
                ZERO_INITIALIZE(SurfaceData, surfaceData);
                surfaceData.ambientOcclusion =      1.0f;
        
                // copy across graph values, if defined
                surfaceData.baseColor =             surfaceDescription.Albedo;
                surfaceData.perceptualSmoothness =  surfaceDescription.Smoothness;
                surfaceData.ambientOcclusion =      surfaceDescription.Occlusion;
                surfaceData.specularColor =         surfaceDescription.Specular;
        
                // These static material feature allow compile time optimization
                surfaceData.materialFeatures = MATERIALFEATUREFLAGS_LIT_STANDARD;
        #ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
                surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SPECULAR_COLOR;
        #endif
        
                float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
                doubleSidedConstants = float3( 1.0,  1.0, -1.0);
        
                // tangent-space normal
                float3 normalTS = float3(0.0f, 0.0f, 1.0f);
                normalTS = surfaceDescription.Normal;
        
                // compute world space normal
                GetNormalWS(fragInputs, normalTS, surfaceData.normalWS, doubleSidedConstants);
        
                surfaceData.geomNormalWS = fragInputs.worldToTangent[2];
        
                surfaceData.tangentWS = normalize(fragInputs.worldToTangent[0].xyz);    // The tangent is not normalize in worldToTangent for mikkt. TODO: Check if it expected that we normalize with Morten. Tag: SURFACE_GRADIENT
                surfaceData.tangentWS = Orthonormalize(surfaceData.tangentWS, surfaceData.normalWS);
        
                // By default we use the ambient occlusion with Tri-ace trick (apply outside) for specular occlusion.
                // If user provide bent normal then we process a better term
                surfaceData.specularOcclusion = GetSpecularOcclusionFromAmbientOcclusion(ClampNdotV(dot(surfaceData.normalWS, V)), surfaceData.ambientOcclusion, PerceptualSmoothnessToRoughness(surfaceData.perceptualSmoothness));
        
        #if HAVE_DECALS
                if (_EnableDecals)
                {
                    DecalSurfaceData decalSurfaceData = GetDecalSurfaceData(posInput, surfaceDescription.Alpha);
                    ApplyDecalToSurfaceData(decalSurfaceData, surfaceData);
                }
        #endif
        
        #ifdef DEBUG_DISPLAY
                if (_DebugMipMapMode != DEBUGMIPMAPMODE_NONE)
                {
                    // TODO: need to update mip info
                    surfaceData.metallic = 0;
                }
        
                // We need to call ApplyDebugToSurfaceData after filling the surfarcedata and before filling builtinData
                // as it can modify attribute use for static lighting
                ApplyDebugToSurfaceData(fragInputs.worldToTangent, surfaceData);
        #endif
            }
        
            void GetSurfaceAndBuiltinData(FragInputs fragInputs, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
            {
        #ifdef LOD_FADE_CROSSFADE // enable dithering LOD transition if user select CrossFade transition in LOD group
                uint3 fadeMaskSeed = asuint((int3)(V * _ScreenSize.xyx)); // Quantize V to _ScreenSize values
                LODDitheringTransition(fadeMaskSeed, unity_LODFade.x);
        #endif
        
                float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
                doubleSidedConstants = float3( 1.0,  1.0, -1.0);
        
                ApplyDoubleSidedFlipOrMirror(fragInputs, doubleSidedConstants);
        
                SurfaceDescriptionInputs surfaceDescriptionInputs = FragInputsToSurfaceDescriptionInputs(fragInputs, V);
                SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs);
        
                // Perform alpha test very early to save performance (a killed pixel will not sample textures)
                // TODO: split graph evaluation to grab just alpha dependencies first? tricky..
        
                BuildSurfaceData(fragInputs, surfaceDescription, V, posInput, surfaceData);
        
                // Builtin Data
                // For back lighting we use the oposite vertex normal 
                InitBuiltinData(surfaceDescription.Alpha, surfaceData.normalWS, -fragInputs.worldToTangent[2], fragInputs.positionRWS, fragInputs.texCoord1, fragInputs.texCoord2, builtinData);
        
                builtinData.emissiveColor = surfaceDescription.Emission;
        
                PostInitBuiltinData(V, posInput, surfaceData, builtinData);
            }
        
            //-------------------------------------------------------------------------------------
            // Pass Includes
            //-------------------------------------------------------------------------------------
                #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassLightTransport.hlsl"
            //-------------------------------------------------------------------------------------
            // End Pass Includes
            //-------------------------------------------------------------------------------------
        
            ENDHLSL
        }
        
        Pass
        {
            // based on HDPBRPass.template
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
        
            //-------------------------------------------------------------------------------------
            // Render Modes (Blend, Cull, ZTest, Stencil, etc)
            //-------------------------------------------------------------------------------------
            Blend One Zero
        
            Cull Off
        
            ZTest LEqual
        
            ZWrite On
        
            ZClip [_ZClip]
        
            // Default Stencil
        
            ColorMask 0
        
            //-------------------------------------------------------------------------------------
            // End Render Modes
            //-------------------------------------------------------------------------------------
        
            HLSLPROGRAM
        
            #pragma target 4.5
            #pragma only_renderers d3d11 ps4 xboxone vulkan metal switch
            //#pragma enable_d3d11_debug_symbols
        
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ LOD_FADE_CROSSFADE
        
            //-------------------------------------------------------------------------------------
            // Variant Definitions (active field translations to HDRP defines)
            //-------------------------------------------------------------------------------------
            #define _MATERIAL_FEATURE_SPECULAR_COLOR 1
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _BLENDMODE_ALPHA 1
            #define _DOUBLESIDED_ON 1
        
            //-------------------------------------------------------------------------------------
            // End Variant Definitions
            //-------------------------------------------------------------------------------------
        
            #pragma vertex Vert
            #pragma fragment Frag
        
            // Use surface gradient normal mapping as it handle correctly triplanar normal mapping and multiple UVSet
            // this modifies the normal calculation
            // #define SURFACE_GRADIENT
        
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
        
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/NormalSurfaceGradient.hlsl"
        
            // define FragInputs structure
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
        
            //-------------------------------------------------------------------------------------
            // Defines
            //-------------------------------------------------------------------------------------
                    #define SHADERPASS SHADERPASS_SHADOWS
                #define USE_LEGACY_UNITY_MATRIX_VARIABLES
        
            // this translates the new dependency tracker into the old preprocessor definitions for the existing HDRP shader code
            #define VARYINGS_NEED_CULLFACE
        
            //-------------------------------------------------------------------------------------
            // End Defines
            //-------------------------------------------------------------------------------------
        
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
            #ifdef DEBUG_DISPLAY
                #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Debug/DebugDisplay.hlsl"
            #endif
        
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
        
        #if (SHADERPASS == SHADERPASS_FORWARD)
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/Lighting.hlsl"
        
            #define HAS_LIGHTLOOP
        
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoopDef.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoop.hlsl"
        #else
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
        #endif
        
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalUtilities.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitDecalData.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
            //Used by SceneSelectionPass
            int _ObjectId;
            int _PassValue;
        
            //-------------------------------------------------------------------------------------
            // Interpolator Packing And Struct Declarations
            //-------------------------------------------------------------------------------------
        // Generated Type: AttributesMesh
        struct AttributesMesh {
            float3 positionOS : POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif // UNITY_ANY_INSTANCING_ENABLED
        };
        
        // Generated Type: VaryingsMeshToPS
        struct VaryingsMeshToPS {
            float4 positionCS : SV_Position;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif // UNITY_ANY_INSTANCING_ENABLED
            #if SHADER_STAGE_FRAGMENT
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC; // optional
            #endif // SHADER_STAGE_FRAGMENT
        };
        struct PackedVaryingsMeshToPS {
            float4 positionCS : SV_Position; // unpacked
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC; // unpacked
            #endif // UNITY_ANY_INSTANCING_ENABLED
            #if SHADER_STAGE_FRAGMENT
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC; // unpacked
            #endif // SHADER_STAGE_FRAGMENT
        };
        PackedVaryingsMeshToPS PackVaryingsMeshToPS(VaryingsMeshToPS input)
        {
            PackedVaryingsMeshToPS output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif // UNITY_ANY_INSTANCING_ENABLED
            #if SHADER_STAGE_FRAGMENT
            output.cullFace = input.cullFace;
            #endif // SHADER_STAGE_FRAGMENT
            return output;
        }
        VaryingsMeshToPS UnpackVaryingsMeshToPS(PackedVaryingsMeshToPS input)
        {
            VaryingsMeshToPS output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif // UNITY_ANY_INSTANCING_ENABLED
            #if SHADER_STAGE_FRAGMENT
            output.cullFace = input.cullFace;
            #endif // SHADER_STAGE_FRAGMENT
            return output;
        }
        
        // Generated Type: VaryingsMeshToDS
        struct VaryingsMeshToDS {
            float3 positionRWS;
            float3 normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif // UNITY_ANY_INSTANCING_ENABLED
        };
        struct PackedVaryingsMeshToDS {
            float3 interp00 : TEXCOORD0; // auto-packed
            float3 interp01 : TEXCOORD1; // auto-packed
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC; // unpacked
            #endif // UNITY_ANY_INSTANCING_ENABLED
        };
        PackedVaryingsMeshToDS PackVaryingsMeshToDS(VaryingsMeshToDS input)
        {
            PackedVaryingsMeshToDS output;
            output.interp00.xyz = input.positionRWS;
            output.interp01.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif // UNITY_ANY_INSTANCING_ENABLED
            return output;
        }
        VaryingsMeshToDS UnpackVaryingsMeshToDS(PackedVaryingsMeshToDS input)
        {
            VaryingsMeshToDS output;
            output.positionRWS = input.interp00.xyz;
            output.normalWS = input.interp01.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif // UNITY_ANY_INSTANCING_ENABLED
            return output;
        }
        
            //-------------------------------------------------------------------------------------
            // End Interpolator Packing And Struct Declarations
            //-------------------------------------------------------------------------------------
        
            //-------------------------------------------------------------------------------------
            // Graph generated code
            //-------------------------------------------------------------------------------------
                    // Shared Graph Properties (uniform inputs)
                    CBUFFER_START(UnityPerMaterial)
                    CBUFFER_END
                
                    TEXTURE2D(Texture2D_E94A1D41); SAMPLER(samplerTexture2D_E94A1D41); float4 Texture2D_E94A1D41_TexelSize;
                    TEXTURE2D(Texture2D_7262B6FF); SAMPLER(samplerTexture2D_7262B6FF); float4 Texture2D_7262B6FF_TexelSize;
                
                // Pixel Graph Inputs
                    struct SurfaceDescriptionInputs {
                    };
                // Pixel Graph Outputs
                    struct SurfaceDescription
                    {
                        float Alpha;
                        float AlphaClipThreshold;
                    };
                    
                // Shared Graph Node Functions
                // Pixel Graph Evaluation
                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                    {
                        SurfaceDescription surface = (SurfaceDescription)0;
                        surface.Alpha = 1;
                        surface.AlphaClipThreshold = 0;
                        return surface;
                    }
                    
            //-------------------------------------------------------------------------------------
            // End graph generated code
            //-------------------------------------------------------------------------------------
        
        
        
        //-------------------------------------------------------------------------------------
        // TEMPLATE INCLUDE : SharedCode.template.hlsl
        //-------------------------------------------------------------------------------------
            FragInputs BuildFragInputs(VaryingsMeshToPS input)
            {
                FragInputs output;
                ZERO_INITIALIZE(FragInputs, output);
        
                // Init to some default value to make the computer quiet (else it output 'divide by zero' warning even if value is not used).
                // TODO: this is a really poor workaround, but the variable is used in a bunch of places
                // to compute normals which are then passed on elsewhere to compute other values...
                output.worldToTangent = k_identity3x3;
                output.positionSS = input.positionCS;       // input.positionCS is SV_Position
        
                #if SHADER_STAGE_FRAGMENT
                output.isFrontFace = IS_FRONT_VFACE(input.cullFace, true, false);       // TODO: SHADER_STAGE_FRAGMENT only
                #endif // SHADER_STAGE_FRAGMENT
        
                return output;
            }
        
            SurfaceDescriptionInputs FragInputsToSurfaceDescriptionInputs(FragInputs input, float3 viewWS)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        
                return output;
            }
        
            // existing HDRP code uses the combined function to go directly from packed to frag inputs
            FragInputs UnpackVaryingsMeshToFragInputs(PackedVaryingsMeshToPS input)
            {
                UNITY_SETUP_INSTANCE_ID(input);
                VaryingsMeshToPS unpacked= UnpackVaryingsMeshToPS(input);
                return BuildFragInputs(unpacked);
            }
        
        //-------------------------------------------------------------------------------------
        // END TEMPLATE INCLUDE : SharedCode.template.hlsl
        //-------------------------------------------------------------------------------------
        
        
        
            void BuildSurfaceData(FragInputs fragInputs, inout SurfaceDescription surfaceDescription, float3 V, PositionInputs posInput, out SurfaceData surfaceData)
            {
                // setup defaults -- these are used if the graph doesn't output a value
                ZERO_INITIALIZE(SurfaceData, surfaceData);
                surfaceData.ambientOcclusion =      1.0f;
        
                // copy across graph values, if defined
        
                // These static material feature allow compile time optimization
                surfaceData.materialFeatures = MATERIALFEATUREFLAGS_LIT_STANDARD;
        #ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
                surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SPECULAR_COLOR;
        #endif
        
                float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
                doubleSidedConstants = float3( 1.0,  1.0, -1.0);
        
                // tangent-space normal
                float3 normalTS = float3(0.0f, 0.0f, 1.0f);
        
                // compute world space normal
                GetNormalWS(fragInputs, normalTS, surfaceData.normalWS, doubleSidedConstants);
        
                surfaceData.geomNormalWS = fragInputs.worldToTangent[2];
        
                surfaceData.tangentWS = normalize(fragInputs.worldToTangent[0].xyz);    // The tangent is not normalize in worldToTangent for mikkt. TODO: Check if it expected that we normalize with Morten. Tag: SURFACE_GRADIENT
                surfaceData.tangentWS = Orthonormalize(surfaceData.tangentWS, surfaceData.normalWS);
        
                // By default we use the ambient occlusion with Tri-ace trick (apply outside) for specular occlusion.
                // If user provide bent normal then we process a better term
                surfaceData.specularOcclusion = GetSpecularOcclusionFromAmbientOcclusion(ClampNdotV(dot(surfaceData.normalWS, V)), surfaceData.ambientOcclusion, PerceptualSmoothnessToRoughness(surfaceData.perceptualSmoothness));
        
        #if HAVE_DECALS
                if (_EnableDecals)
                {
                    DecalSurfaceData decalSurfaceData = GetDecalSurfaceData(posInput, surfaceDescription.Alpha);
                    ApplyDecalToSurfaceData(decalSurfaceData, surfaceData);
                }
        #endif
        
        #ifdef DEBUG_DISPLAY
                if (_DebugMipMapMode != DEBUGMIPMAPMODE_NONE)
                {
                    // TODO: need to update mip info
                    surfaceData.metallic = 0;
                }
        
                // We need to call ApplyDebugToSurfaceData after filling the surfarcedata and before filling builtinData
                // as it can modify attribute use for static lighting
                ApplyDebugToSurfaceData(fragInputs.worldToTangent, surfaceData);
        #endif
            }
        
            void GetSurfaceAndBuiltinData(FragInputs fragInputs, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
            {
        #ifdef LOD_FADE_CROSSFADE // enable dithering LOD transition if user select CrossFade transition in LOD group
                uint3 fadeMaskSeed = asuint((int3)(V * _ScreenSize.xyx)); // Quantize V to _ScreenSize values
                LODDitheringTransition(fadeMaskSeed, unity_LODFade.x);
        #endif
        
                float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
                doubleSidedConstants = float3( 1.0,  1.0, -1.0);
        
                ApplyDoubleSidedFlipOrMirror(fragInputs, doubleSidedConstants);
        
                SurfaceDescriptionInputs surfaceDescriptionInputs = FragInputsToSurfaceDescriptionInputs(fragInputs, V);
                SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs);
        
                // Perform alpha test very early to save performance (a killed pixel will not sample textures)
                // TODO: split graph evaluation to grab just alpha dependencies first? tricky..
        
                BuildSurfaceData(fragInputs, surfaceDescription, V, posInput, surfaceData);
        
                // Builtin Data
                // For back lighting we use the oposite vertex normal 
                InitBuiltinData(surfaceDescription.Alpha, surfaceData.normalWS, -fragInputs.worldToTangent[2], fragInputs.positionRWS, fragInputs.texCoord1, fragInputs.texCoord2, builtinData);
        
        
                PostInitBuiltinData(V, posInput, surfaceData, builtinData);
            }
        
            //-------------------------------------------------------------------------------------
            // Pass Includes
            //-------------------------------------------------------------------------------------
                #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassDepthOnly.hlsl"
            //-------------------------------------------------------------------------------------
            // End Pass Includes
            //-------------------------------------------------------------------------------------
        
            ENDHLSL
        }
        
        Pass
        {
            // based on HDPBRPass.template
            Name "SceneSelectionPass"
            Tags { "LightMode" = "SceneSelectionPass" }
        
            //-------------------------------------------------------------------------------------
            // Render Modes (Blend, Cull, ZTest, Stencil, etc)
            //-------------------------------------------------------------------------------------
            Blend One OneMinusSrcAlpha
        
            Cull Off
        
            ZTest LEqual
        
			ZWrite Off
        
            ZClip [_ZClip]
        
            // Default Stencil
        
            ColorMask 0
        
            //-------------------------------------------------------------------------------------
            // End Render Modes
            //-------------------------------------------------------------------------------------
        
            HLSLPROGRAM
        
            #pragma target 4.5
            #pragma only_renderers d3d11 ps4 xboxone vulkan metal switch
            //#pragma enable_d3d11_debug_symbols
        
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ LOD_FADE_CROSSFADE
        
            //-------------------------------------------------------------------------------------
            // Variant Definitions (active field translations to HDRP defines)
            //-------------------------------------------------------------------------------------
            #define _MATERIAL_FEATURE_SPECULAR_COLOR 1
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _BLENDMODE_ALPHA 1
            #define _DOUBLESIDED_ON 1
        
            //-------------------------------------------------------------------------------------
            // End Variant Definitions
            //-------------------------------------------------------------------------------------
        
            #pragma vertex Vert
            #pragma fragment Frag
        
            // Use surface gradient normal mapping as it handle correctly triplanar normal mapping and multiple UVSet
            // this modifies the normal calculation
            // #define SURFACE_GRADIENT
        
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
        
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/NormalSurfaceGradient.hlsl"
        
            // define FragInputs structure
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
        
            //-------------------------------------------------------------------------------------
            // Defines
            //-------------------------------------------------------------------------------------
                    #define SHADERPASS SHADERPASS_DEPTH_ONLY
                #define SCENESELECTIONPASS
        
            // this translates the new dependency tracker into the old preprocessor definitions for the existing HDRP shader code
            #define VARYINGS_NEED_CULLFACE
        
            //-------------------------------------------------------------------------------------
            // End Defines
            //-------------------------------------------------------------------------------------
        
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
            #ifdef DEBUG_DISPLAY
                #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Debug/DebugDisplay.hlsl"
            #endif
        
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
        
        #if (SHADERPASS == SHADERPASS_FORWARD)
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/Lighting.hlsl"
        
            #define HAS_LIGHTLOOP
        
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoopDef.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoop.hlsl"
        #else
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
        #endif
        
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalUtilities.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitDecalData.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
            //Used by SceneSelectionPass
            int _ObjectId;
            int _PassValue;
        
            //-------------------------------------------------------------------------------------
            // Interpolator Packing And Struct Declarations
            //-------------------------------------------------------------------------------------
        // Generated Type: AttributesMesh
        struct AttributesMesh {
            float3 positionOS : POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif // UNITY_ANY_INSTANCING_ENABLED
        };
        
        // Generated Type: VaryingsMeshToPS
        struct VaryingsMeshToPS {
            float4 positionCS : SV_Position;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif // UNITY_ANY_INSTANCING_ENABLED
            #if SHADER_STAGE_FRAGMENT
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC; // optional
            #endif // SHADER_STAGE_FRAGMENT
        };
        struct PackedVaryingsMeshToPS {
            float4 positionCS : SV_Position; // unpacked
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC; // unpacked
            #endif // UNITY_ANY_INSTANCING_ENABLED
            #if SHADER_STAGE_FRAGMENT
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC; // unpacked
            #endif // SHADER_STAGE_FRAGMENT
        };
        PackedVaryingsMeshToPS PackVaryingsMeshToPS(VaryingsMeshToPS input)
        {
            PackedVaryingsMeshToPS output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif // UNITY_ANY_INSTANCING_ENABLED
            #if SHADER_STAGE_FRAGMENT
            output.cullFace = input.cullFace;
            #endif // SHADER_STAGE_FRAGMENT
            return output;
        }
        VaryingsMeshToPS UnpackVaryingsMeshToPS(PackedVaryingsMeshToPS input)
        {
            VaryingsMeshToPS output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif // UNITY_ANY_INSTANCING_ENABLED
            #if SHADER_STAGE_FRAGMENT
            output.cullFace = input.cullFace;
            #endif // SHADER_STAGE_FRAGMENT
            return output;
        }
        
        // Generated Type: VaryingsMeshToDS
        struct VaryingsMeshToDS {
            float3 positionRWS;
            float3 normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif // UNITY_ANY_INSTANCING_ENABLED
        };
        struct PackedVaryingsMeshToDS {
            float3 interp00 : TEXCOORD0; // auto-packed
            float3 interp01 : TEXCOORD1; // auto-packed
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC; // unpacked
            #endif // UNITY_ANY_INSTANCING_ENABLED
        };
        PackedVaryingsMeshToDS PackVaryingsMeshToDS(VaryingsMeshToDS input)
        {
            PackedVaryingsMeshToDS output;
            output.interp00.xyz = input.positionRWS;
            output.interp01.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif // UNITY_ANY_INSTANCING_ENABLED
            return output;
        }
        VaryingsMeshToDS UnpackVaryingsMeshToDS(PackedVaryingsMeshToDS input)
        {
            VaryingsMeshToDS output;
            output.positionRWS = input.interp00.xyz;
            output.normalWS = input.interp01.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif // UNITY_ANY_INSTANCING_ENABLED
            return output;
        }
        
            //-------------------------------------------------------------------------------------
            // End Interpolator Packing And Struct Declarations
            //-------------------------------------------------------------------------------------
        
            //-------------------------------------------------------------------------------------
            // Graph generated code
            //-------------------------------------------------------------------------------------
                    // Shared Graph Properties (uniform inputs)
                    CBUFFER_START(UnityPerMaterial)
                    CBUFFER_END
                
                    TEXTURE2D(Texture2D_E94A1D41); SAMPLER(samplerTexture2D_E94A1D41); float4 Texture2D_E94A1D41_TexelSize;
                    TEXTURE2D(Texture2D_7262B6FF); SAMPLER(samplerTexture2D_7262B6FF); float4 Texture2D_7262B6FF_TexelSize;
                
                // Pixel Graph Inputs
                    struct SurfaceDescriptionInputs {
                    };
                // Pixel Graph Outputs
                    struct SurfaceDescription
                    {
                        float Alpha;
                        float AlphaClipThreshold;
                    };
                    
                // Shared Graph Node Functions
                // Pixel Graph Evaluation
                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                    {
                        SurfaceDescription surface = (SurfaceDescription)0;
                        surface.Alpha = 1;
                        surface.AlphaClipThreshold = 0;
                        return surface;
                    }
                    
            //-------------------------------------------------------------------------------------
            // End graph generated code
            //-------------------------------------------------------------------------------------
        
        
        
        //-------------------------------------------------------------------------------------
        // TEMPLATE INCLUDE : SharedCode.template.hlsl
        //-------------------------------------------------------------------------------------
            FragInputs BuildFragInputs(VaryingsMeshToPS input)
            {
                FragInputs output;
                ZERO_INITIALIZE(FragInputs, output);
        
                // Init to some default value to make the computer quiet (else it output 'divide by zero' warning even if value is not used).
                // TODO: this is a really poor workaround, but the variable is used in a bunch of places
                // to compute normals which are then passed on elsewhere to compute other values...
                output.worldToTangent = k_identity3x3;
                output.positionSS = input.positionCS;       // input.positionCS is SV_Position
        
                #if SHADER_STAGE_FRAGMENT
                output.isFrontFace = IS_FRONT_VFACE(input.cullFace, true, false);       // TODO: SHADER_STAGE_FRAGMENT only
                #endif // SHADER_STAGE_FRAGMENT
        
                return output;
            }
        
            SurfaceDescriptionInputs FragInputsToSurfaceDescriptionInputs(FragInputs input, float3 viewWS)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        
                return output;
            }
        
            // existing HDRP code uses the combined function to go directly from packed to frag inputs
            FragInputs UnpackVaryingsMeshToFragInputs(PackedVaryingsMeshToPS input)
            {
                UNITY_SETUP_INSTANCE_ID(input);
                VaryingsMeshToPS unpacked= UnpackVaryingsMeshToPS(input);
                return BuildFragInputs(unpacked);
            }
        
        //-------------------------------------------------------------------------------------
        // END TEMPLATE INCLUDE : SharedCode.template.hlsl
        //-------------------------------------------------------------------------------------
        
        
        
            void BuildSurfaceData(FragInputs fragInputs, inout SurfaceDescription surfaceDescription, float3 V, PositionInputs posInput, out SurfaceData surfaceData)
            {
                // setup defaults -- these are used if the graph doesn't output a value
                ZERO_INITIALIZE(SurfaceData, surfaceData);
                surfaceData.ambientOcclusion =      1.0f;
        
                // copy across graph values, if defined
        
                // These static material feature allow compile time optimization
                surfaceData.materialFeatures = MATERIALFEATUREFLAGS_LIT_STANDARD;
        #ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
                surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SPECULAR_COLOR;
        #endif
        
                float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
                doubleSidedConstants = float3( 1.0,  1.0, -1.0);
        
                // tangent-space normal
                float3 normalTS = float3(0.0f, 0.0f, 1.0f);
        
                // compute world space normal
                GetNormalWS(fragInputs, normalTS, surfaceData.normalWS, doubleSidedConstants);
        
                surfaceData.geomNormalWS = fragInputs.worldToTangent[2];
        
                surfaceData.tangentWS = normalize(fragInputs.worldToTangent[0].xyz);    // The tangent is not normalize in worldToTangent for mikkt. TODO: Check if it expected that we normalize with Morten. Tag: SURFACE_GRADIENT
                surfaceData.tangentWS = Orthonormalize(surfaceData.tangentWS, surfaceData.normalWS);
        
                // By default we use the ambient occlusion with Tri-ace trick (apply outside) for specular occlusion.
                // If user provide bent normal then we process a better term
                surfaceData.specularOcclusion = GetSpecularOcclusionFromAmbientOcclusion(ClampNdotV(dot(surfaceData.normalWS, V)), surfaceData.ambientOcclusion, PerceptualSmoothnessToRoughness(surfaceData.perceptualSmoothness));
        
        #if HAVE_DECALS
                if (_EnableDecals)
                {
                    DecalSurfaceData decalSurfaceData = GetDecalSurfaceData(posInput, surfaceDescription.Alpha);
                    ApplyDecalToSurfaceData(decalSurfaceData, surfaceData);
                }
        #endif
        
        #ifdef DEBUG_DISPLAY
                if (_DebugMipMapMode != DEBUGMIPMAPMODE_NONE)
                {
                    // TODO: need to update mip info
                    surfaceData.metallic = 0;
                }
        
                // We need to call ApplyDebugToSurfaceData after filling the surfarcedata and before filling builtinData
                // as it can modify attribute use for static lighting
                ApplyDebugToSurfaceData(fragInputs.worldToTangent, surfaceData);
        #endif
            }
        
            void GetSurfaceAndBuiltinData(FragInputs fragInputs, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
            {
        #ifdef LOD_FADE_CROSSFADE // enable dithering LOD transition if user select CrossFade transition in LOD group
                uint3 fadeMaskSeed = asuint((int3)(V * _ScreenSize.xyx)); // Quantize V to _ScreenSize values
                LODDitheringTransition(fadeMaskSeed, unity_LODFade.x);
        #endif
        
                float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
                doubleSidedConstants = float3( 1.0,  1.0, -1.0);
        
                ApplyDoubleSidedFlipOrMirror(fragInputs, doubleSidedConstants);
        
                SurfaceDescriptionInputs surfaceDescriptionInputs = FragInputsToSurfaceDescriptionInputs(fragInputs, V);
                SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs);
        
                // Perform alpha test very early to save performance (a killed pixel will not sample textures)
                // TODO: split graph evaluation to grab just alpha dependencies first? tricky..
        
                BuildSurfaceData(fragInputs, surfaceDescription, V, posInput, surfaceData);
        
                // Builtin Data
                // For back lighting we use the oposite vertex normal 
                InitBuiltinData(surfaceDescription.Alpha, surfaceData.normalWS, -fragInputs.worldToTangent[2], fragInputs.positionRWS, fragInputs.texCoord1, fragInputs.texCoord2, builtinData);
        
        
                PostInitBuiltinData(V, posInput, surfaceData, builtinData);
            }
        
            //-------------------------------------------------------------------------------------
            // Pass Includes
            //-------------------------------------------------------------------------------------
                #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassDepthOnly.hlsl"
            //-------------------------------------------------------------------------------------
            // End Pass Includes
            //-------------------------------------------------------------------------------------
        
            ENDHLSL
        }
        
        Pass
        {
            // based on HDPBRPass.template
            Name "Forward"
            Tags { "LightMode" = "Forward" }
        
            //-------------------------------------------------------------------------------------
            // Render Modes (Blend, Cull, ZTest, Stencil, etc)
            //-------------------------------------------------------------------------------------
            Blend One OneMinusSrcAlpha
        
            Cull Off
        
            ZTest LEqual

			//
			// Modified from original PBR shader graph setting on Feb 24 in 2019
			// "ZTest LEqual" doesn't work if the ZWrite is "Off"
			//
			//ZWrite Off 
			ZWrite On 
        
            ZClip [_ZClip]
        
            // Stencil setup
        Stencil
        {
           WriteMask 7
           Ref  2
           Comp Always
           Pass Replace
        }
        
            
            //-------------------------------------------------------------------------------------
            // End Render Modes
            //-------------------------------------------------------------------------------------
        
            HLSLPROGRAM
        
            #pragma target 4.5
            #pragma only_renderers d3d11 ps4 xboxone vulkan metal switch
            //#pragma enable_d3d11_debug_symbols
        
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ LOD_FADE_CROSSFADE
        
            //-------------------------------------------------------------------------------------
            // Variant Definitions (active field translations to HDRP defines)
            //-------------------------------------------------------------------------------------
            #define _MATERIAL_FEATURE_SPECULAR_COLOR 1
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _BLENDMODE_ALPHA 1
            #define _DOUBLESIDED_ON 1
        
            //-------------------------------------------------------------------------------------
            // End Variant Definitions
            //-------------------------------------------------------------------------------------
        
            #pragma vertex Vert
            #pragma fragment Frag
        
            // Use surface gradient normal mapping as it handle correctly triplanar normal mapping and multiple UVSet
            // this modifies the normal calculation
            // #define SURFACE_GRADIENT
        
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
        
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/NormalSurfaceGradient.hlsl"
        
            // define FragInputs structure
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
        
            //-------------------------------------------------------------------------------------
            // Defines
            //-------------------------------------------------------------------------------------
                    #define SHADERPASS SHADERPASS_FORWARD
                #pragma multi_compile _ DEBUG_DISPLAY
                #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma multi_compile _ DYNAMICLIGHTMAP_ON
                #pragma multi_compile _ SHADOWS_SHADOWMASK
                #pragma multi_compile DECALS_OFF DECALS_3RT DECALS_4RT
                #define LIGHTLOOP_TILE_PASS
                #define USE_CLUSTERED_LIGHTLIST
                #pragma multi_compile SHADOW_LOW SHADOW_MEDIUM SHADOW_HIGH
        
            // this translates the new dependency tracker into the old preprocessor definitions for the existing HDRP shader code
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TANGENT_TO_WORLD
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_TEXCOORD1
            #define VARYINGS_NEED_TEXCOORD2
            #define VARYINGS_NEED_CULLFACE
        
            //-------------------------------------------------------------------------------------
            // End Defines
            //-------------------------------------------------------------------------------------
        
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
            #ifdef DEBUG_DISPLAY
                #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Debug/DebugDisplay.hlsl"
            #endif
        
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
        
        #if (SHADERPASS == SHADERPASS_FORWARD)
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/Lighting.hlsl"
        
            #define HAS_LIGHTLOOP
        
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoopDef.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoop.hlsl"
        #else
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
        #endif
        
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalUtilities.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitDecalData.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
            //Used by SceneSelectionPass
            int _ObjectId;
            int _PassValue;
        
            //-------------------------------------------------------------------------------------
            // Interpolator Packing And Struct Declarations
            //-------------------------------------------------------------------------------------
        // Generated Type: AttributesMesh
        struct AttributesMesh {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL; // optional
            float4 tangentOS : TANGENT; // optional
            float4 uv0 : TEXCOORD0; // optional
            float4 uv1 : TEXCOORD1; // optional
            float4 uv2 : TEXCOORD2; // optional
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif // UNITY_ANY_INSTANCING_ENABLED
        };
        
        // Generated Type: VaryingsMeshToPS
        struct VaryingsMeshToPS {
            float4 positionCS : SV_Position;
            float3 positionRWS; // optional
            float3 normalWS; // optional
            float4 tangentWS; // optional
            float4 texCoord0; // optional
            float4 texCoord1; // optional
            float4 texCoord2; // optional
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif // UNITY_ANY_INSTANCING_ENABLED
            #if SHADER_STAGE_FRAGMENT
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC; // optional
            #endif // SHADER_STAGE_FRAGMENT
        };
        struct PackedVaryingsMeshToPS {
            float3 interp00 : TEXCOORD0; // auto-packed
            float3 interp01 : TEXCOORD1; // auto-packed
            float4 interp02 : TEXCOORD2; // auto-packed
            float4 interp03 : TEXCOORD3; // auto-packed
            float4 interp04 : TEXCOORD4; // auto-packed
            float4 interp05 : TEXCOORD5; // auto-packed
            float4 positionCS : SV_Position; // unpacked
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC; // unpacked
            #endif // UNITY_ANY_INSTANCING_ENABLED
            #if SHADER_STAGE_FRAGMENT
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC; // unpacked
            #endif // SHADER_STAGE_FRAGMENT
        };
        PackedVaryingsMeshToPS PackVaryingsMeshToPS(VaryingsMeshToPS input)
        {
            PackedVaryingsMeshToPS output;
            output.positionCS = input.positionCS;
            output.interp00.xyz = input.positionRWS;
            output.interp01.xyz = input.normalWS;
            output.interp02.xyzw = input.tangentWS;
            output.interp03.xyzw = input.texCoord0;
            output.interp04.xyzw = input.texCoord1;
            output.interp05.xyzw = input.texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif // UNITY_ANY_INSTANCING_ENABLED
            #if SHADER_STAGE_FRAGMENT
            output.cullFace = input.cullFace;
            #endif // SHADER_STAGE_FRAGMENT
            return output;
        }
        VaryingsMeshToPS UnpackVaryingsMeshToPS(PackedVaryingsMeshToPS input)
        {
            VaryingsMeshToPS output;
            output.positionCS = input.positionCS;
            output.positionRWS = input.interp00.xyz;
            output.normalWS = input.interp01.xyz;
            output.tangentWS = input.interp02.xyzw;
            output.texCoord0 = input.interp03.xyzw;
            output.texCoord1 = input.interp04.xyzw;
            output.texCoord2 = input.interp05.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif // UNITY_ANY_INSTANCING_ENABLED
            #if SHADER_STAGE_FRAGMENT
            output.cullFace = input.cullFace;
            #endif // SHADER_STAGE_FRAGMENT
            return output;
        }
        
        // Generated Type: VaryingsMeshToDS
        struct VaryingsMeshToDS {
            float3 positionRWS;
            float3 normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif // UNITY_ANY_INSTANCING_ENABLED
        };
        struct PackedVaryingsMeshToDS {
            float3 interp00 : TEXCOORD0; // auto-packed
            float3 interp01 : TEXCOORD1; // auto-packed
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC; // unpacked
            #endif // UNITY_ANY_INSTANCING_ENABLED
        };
        PackedVaryingsMeshToDS PackVaryingsMeshToDS(VaryingsMeshToDS input)
        {
            PackedVaryingsMeshToDS output;
            output.interp00.xyz = input.positionRWS;
            output.interp01.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif // UNITY_ANY_INSTANCING_ENABLED
            return output;
        }
        VaryingsMeshToDS UnpackVaryingsMeshToDS(PackedVaryingsMeshToDS input)
        {
            VaryingsMeshToDS output;
            output.positionRWS = input.interp00.xyz;
            output.normalWS = input.interp01.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif // UNITY_ANY_INSTANCING_ENABLED
            return output;
        }
        
            //-------------------------------------------------------------------------------------
            // End Interpolator Packing And Struct Declarations
            //-------------------------------------------------------------------------------------
        
            //-------------------------------------------------------------------------------------
            // Graph generated code
            //-------------------------------------------------------------------------------------
                    // Shared Graph Properties (uniform inputs)
                    CBUFFER_START(UnityPerMaterial)
                    CBUFFER_END
                
                    TEXTURE2D(Texture2D_E94A1D41); SAMPLER(samplerTexture2D_E94A1D41); float4 Texture2D_E94A1D41_TexelSize;
                    TEXTURE2D(Texture2D_7262B6FF); SAMPLER(samplerTexture2D_7262B6FF); float4 Texture2D_7262B6FF_TexelSize;
                
                // Pixel Graph Inputs
                    struct SurfaceDescriptionInputs {
                        float4 uv0; // optional
                    };
                // Pixel Graph Outputs
                    struct SurfaceDescription
                    {
                        float3 Albedo;
                        float3 Normal;
                        float3 Specular;
                        float3 Emission;
                        float Smoothness;
                        float Occlusion;
                        float Alpha;
                        float AlphaClipThreshold;
                    };
                    
                // Shared Graph Node Functions
                
                    void Unity_NormalFromTexture_float(Texture2D Texture, SamplerState Sampler, float2 UV, float Offset, float Strength, out float3 Out)
                    {
                        Offset = pow(Offset, 3) * 0.1;
                        float2 offsetU = float2(UV.x + Offset, UV.y);
                        float2 offsetV = float2(UV.x, UV.y + Offset);
                        float normalSample = Texture.Sample(Sampler, UV);
                        float uSample = Texture.Sample(Sampler, offsetU);
                        float vSample = Texture.Sample(Sampler, offsetV);
                        float3 va = float3(1, 0, (uSample - normalSample) * Strength);
                        float3 vb = float3(0, 1, (vSample - normalSample) * Strength);
                        Out = normalize(cross(va, vb));
                    }
                
                // Pixel Graph Evaluation
                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                    {
                        SurfaceDescription surface = (SurfaceDescription)0;
                        float3 _NormalFromTexture_CA0B55E7_Out;
                        Unity_NormalFromTexture_float(Texture2D_7262B6FF, samplerTexture2D_7262B6FF, IN.uv0.xy, 0.5, 8, _NormalFromTexture_CA0B55E7_Out);
                    
                        float4 _SampleTexture2D_25824A8A_RGBA = SAMPLE_TEXTURE2D(Texture2D_E94A1D41, samplerTexture2D_E94A1D41, IN.uv0.xy);
                        float _SampleTexture2D_25824A8A_R = _SampleTexture2D_25824A8A_RGBA.r;
                        float _SampleTexture2D_25824A8A_G = _SampleTexture2D_25824A8A_RGBA.g;
                        float _SampleTexture2D_25824A8A_B = _SampleTexture2D_25824A8A_RGBA.b;
                        float _SampleTexture2D_25824A8A_A = _SampleTexture2D_25824A8A_RGBA.a;
                        surface.Albedo = IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0));
                        surface.Normal = _NormalFromTexture_CA0B55E7_Out;
                        surface.Specular = IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0));
                        surface.Emission = (_SampleTexture2D_25824A8A_RGBA.xyz);
                        surface.Smoothness = 0;
                        surface.Occlusion = 1;
                        surface.Alpha = 1;
                        surface.AlphaClipThreshold = 0;
                        return surface;
                    }
                    
            //-------------------------------------------------------------------------------------
            // End graph generated code
            //-------------------------------------------------------------------------------------
        
        
        
        //-------------------------------------------------------------------------------------
        // TEMPLATE INCLUDE : SharedCode.template.hlsl
        //-------------------------------------------------------------------------------------
            FragInputs BuildFragInputs(VaryingsMeshToPS input)
            {
                FragInputs output;
                ZERO_INITIALIZE(FragInputs, output);
        
                // Init to some default value to make the computer quiet (else it output 'divide by zero' warning even if value is not used).
                // TODO: this is a really poor workaround, but the variable is used in a bunch of places
                // to compute normals which are then passed on elsewhere to compute other values...
                output.worldToTangent = k_identity3x3;
                output.positionSS = input.positionCS;       // input.positionCS is SV_Position
        
                output.positionRWS = input.positionRWS;
                output.worldToTangent = BuildWorldToTangent(input.tangentWS, input.normalWS);
                output.texCoord0 = input.texCoord0;
                output.texCoord1 = input.texCoord1;
                output.texCoord2 = input.texCoord2;
                #if SHADER_STAGE_FRAGMENT
                output.isFrontFace = IS_FRONT_VFACE(input.cullFace, true, false);       // TODO: SHADER_STAGE_FRAGMENT only
                #endif // SHADER_STAGE_FRAGMENT
        
                return output;
            }
        
            SurfaceDescriptionInputs FragInputsToSurfaceDescriptionInputs(FragInputs input, float3 viewWS)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
                output.uv0 =                         input.texCoord0;
        
                return output;
            }
        
            // existing HDRP code uses the combined function to go directly from packed to frag inputs
            FragInputs UnpackVaryingsMeshToFragInputs(PackedVaryingsMeshToPS input)
            {
                UNITY_SETUP_INSTANCE_ID(input);
                VaryingsMeshToPS unpacked= UnpackVaryingsMeshToPS(input);
                return BuildFragInputs(unpacked);
            }
        
        //-------------------------------------------------------------------------------------
        // END TEMPLATE INCLUDE : SharedCode.template.hlsl
        //-------------------------------------------------------------------------------------
        
        
        
            void BuildSurfaceData(FragInputs fragInputs, inout SurfaceDescription surfaceDescription, float3 V, PositionInputs posInput, out SurfaceData surfaceData)
            {
                // setup defaults -- these are used if the graph doesn't output a value
                ZERO_INITIALIZE(SurfaceData, surfaceData);
                surfaceData.ambientOcclusion =      1.0f;
        
                // copy across graph values, if defined
                surfaceData.baseColor =             surfaceDescription.Albedo;
                surfaceData.perceptualSmoothness =  surfaceDescription.Smoothness;
                surfaceData.ambientOcclusion =      surfaceDescription.Occlusion;
                surfaceData.specularColor =         surfaceDescription.Specular;
        
                // These static material feature allow compile time optimization
                surfaceData.materialFeatures = MATERIALFEATUREFLAGS_LIT_STANDARD;
        #ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
                surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SPECULAR_COLOR;
        #endif
        
                float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
                doubleSidedConstants = float3( 1.0,  1.0, -1.0);
        
                // tangent-space normal
                float3 normalTS = float3(0.0f, 0.0f, 1.0f);
                normalTS = surfaceDescription.Normal;
        
                // compute world space normal
                GetNormalWS(fragInputs, normalTS, surfaceData.normalWS, doubleSidedConstants);
        
                surfaceData.geomNormalWS = fragInputs.worldToTangent[2];
        
                surfaceData.tangentWS = normalize(fragInputs.worldToTangent[0].xyz);    // The tangent is not normalize in worldToTangent for mikkt. TODO: Check if it expected that we normalize with Morten. Tag: SURFACE_GRADIENT
                surfaceData.tangentWS = Orthonormalize(surfaceData.tangentWS, surfaceData.normalWS);
        
                // By default we use the ambient occlusion with Tri-ace trick (apply outside) for specular occlusion.
                // If user provide bent normal then we process a better term
                surfaceData.specularOcclusion = GetSpecularOcclusionFromAmbientOcclusion(ClampNdotV(dot(surfaceData.normalWS, V)), surfaceData.ambientOcclusion, PerceptualSmoothnessToRoughness(surfaceData.perceptualSmoothness));
        
        #if HAVE_DECALS
                if (_EnableDecals)
                {
                    DecalSurfaceData decalSurfaceData = GetDecalSurfaceData(posInput, surfaceDescription.Alpha);
                    ApplyDecalToSurfaceData(decalSurfaceData, surfaceData);
                }
        #endif
        
        #ifdef DEBUG_DISPLAY
                if (_DebugMipMapMode != DEBUGMIPMAPMODE_NONE)
                {
                    // TODO: need to update mip info
                    surfaceData.metallic = 0;
                }
        
                // We need to call ApplyDebugToSurfaceData after filling the surfarcedata and before filling builtinData
                // as it can modify attribute use for static lighting
                ApplyDebugToSurfaceData(fragInputs.worldToTangent, surfaceData);
        #endif
            }
        
            void GetSurfaceAndBuiltinData(FragInputs fragInputs, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
            {
        #ifdef LOD_FADE_CROSSFADE // enable dithering LOD transition if user select CrossFade transition in LOD group
                uint3 fadeMaskSeed = asuint((int3)(V * _ScreenSize.xyx)); // Quantize V to _ScreenSize values
                LODDitheringTransition(fadeMaskSeed, unity_LODFade.x);
        #endif
        
                float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
                doubleSidedConstants = float3( 1.0,  1.0, -1.0);
        
                ApplyDoubleSidedFlipOrMirror(fragInputs, doubleSidedConstants);
        
                SurfaceDescriptionInputs surfaceDescriptionInputs = FragInputsToSurfaceDescriptionInputs(fragInputs, V);
                SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs);
        
                // Perform alpha test very early to save performance (a killed pixel will not sample textures)
                // TODO: split graph evaluation to grab just alpha dependencies first? tricky..
        
                BuildSurfaceData(fragInputs, surfaceDescription, V, posInput, surfaceData);
        
                // Builtin Data
                // For back lighting we use the oposite vertex normal 
                InitBuiltinData(surfaceDescription.Alpha, surfaceData.normalWS, -fragInputs.worldToTangent[2], fragInputs.positionRWS, fragInputs.texCoord1, fragInputs.texCoord2, builtinData);
        
                builtinData.emissiveColor = surfaceDescription.Emission;
        
                PostInitBuiltinData(V, posInput, surfaceData, builtinData);
            }
        
            //-------------------------------------------------------------------------------------
            // Pass Includes
            //-------------------------------------------------------------------------------------
                #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassForward.hlsl"
            //-------------------------------------------------------------------------------------
            // End Pass Includes
            //-------------------------------------------------------------------------------------
        
            ENDHLSL
        }
        
    }
    CustomEditor "UnityEditor.ShaderGraph.HDLitGUI"
    SubShader
    {
        Tags
        {
            "RenderPipeline"="LightweightPipeline"
            "RenderType"="Transparent"
            "Queue"="Transparent+0"
        }
        Pass
        {
        	Tags{"LightMode" = "LightweightForward"}

        	// Material options generated by graph

            Blend SrcAlpha OneMinusSrcAlpha

            Cull Off

            ZTest LEqual

            ZWrite Off

        	HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

        	// -------------------------------------
            // Lightweight Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
            
        	// -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex vert
        	#pragma fragment frag

        	// Defines generated by graph
            #define _NORMALMAP 1
            #define _SPECULAR_SETUP 1

        	#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
        	#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"
        	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
        	#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"

            CBUFFER_START(UnityPerMaterial)
            CBUFFER_END

            TEXTURE2D(Texture2D_E94A1D41); SAMPLER(samplerTexture2D_E94A1D41); float4 Texture2D_E94A1D41_TexelSize;
            TEXTURE2D(Texture2D_7262B6FF); SAMPLER(samplerTexture2D_7262B6FF); float4 Texture2D_7262B6FF_TexelSize;

            struct VertexDescriptionInputs
            {
                float3 ObjectSpacePosition;
            };

            struct SurfaceDescriptionInputs
            {
                half4 uv0;
            };


            void Unity_NormalFromTexture_float(Texture2D Texture, SamplerState Sampler, float2 UV, float Offset, float Strength, out float3 Out)
            {
                Offset = pow(Offset, 3) * 0.1;
                float2 offsetU = float2(UV.x + Offset, UV.y);
                float2 offsetV = float2(UV.x, UV.y + Offset);
                float normalSample = Texture.Sample(Sampler, UV);
                float uSample = Texture.Sample(Sampler, offsetU);
                float vSample = Texture.Sample(Sampler, offsetV);
                float3 va = float3(1, 0, (uSample - normalSample) * Strength);
                float3 vb = float3(0, 1, (vSample - normalSample) * Strength);
                Out = normalize(cross(va, vb));
            }

            struct VertexDescription
            {
                float3 Position;
            };

            VertexDescription PopulateVertexData(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                return description;
            }

            struct SurfaceDescription
            {
                float3 Albedo;
                float3 Normal;
                float3 Emission;
                float3 Specular;
                float Smoothness;
                float Occlusion;
                float Alpha;
                float AlphaClipThreshold;
            };

            SurfaceDescription PopulateSurfaceData(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float3 _NormalFromTexture_CA0B55E7_Out;
                Unity_NormalFromTexture_float(Texture2D_7262B6FF, samplerTexture2D_7262B6FF, IN.uv0.xy, 0.5, 8, _NormalFromTexture_CA0B55E7_Out);

                float4 _SampleTexture2D_25824A8A_RGBA = SAMPLE_TEXTURE2D(Texture2D_E94A1D41, samplerTexture2D_E94A1D41, IN.uv0.xy);
                float _SampleTexture2D_25824A8A_R = _SampleTexture2D_25824A8A_RGBA.r;
                float _SampleTexture2D_25824A8A_G = _SampleTexture2D_25824A8A_RGBA.g;
                float _SampleTexture2D_25824A8A_B = _SampleTexture2D_25824A8A_RGBA.b;
                float _SampleTexture2D_25824A8A_A = _SampleTexture2D_25824A8A_RGBA.a;
                surface.Albedo = IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0));
                surface.Normal = _NormalFromTexture_CA0B55E7_Out;
                surface.Emission = (_SampleTexture2D_25824A8A_RGBA.xyz);
                surface.Specular = IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0));
                surface.Smoothness = 0;
                surface.Occlusion = 1;
                surface.Alpha = 1;
                surface.AlphaClipThreshold = 0;
                return surface;
            }

            struct GraphVertexInput
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord0 : TEXCOORD0;
                float4 texcoord1 : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };


        	struct GraphVertexOutput
            {
                float4 clipPos                : SV_POSITION;
                DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 0);
        		half4 fogFactorAndVertexLight : TEXCOORD1; // x: fogFactor, yzw: vertex light
            	float4 shadowCoord            : TEXCOORD2;

        		// Interpolators defined by graph
                float3 WorldSpacePosition : TEXCOORD3;
                float3 WorldSpaceNormal : TEXCOORD4;
                float3 WorldSpaceTangent : TEXCOORD5;
                float3 WorldSpaceBiTangent : TEXCOORD6;
                float3 WorldSpaceViewDirection : TEXCOORD7;
                half4 uv0 : TEXCOORD8;
                half4 uv1 : TEXCOORD9;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            	UNITY_VERTEX_OUTPUT_STEREO
            };

            GraphVertexOutput vert (GraphVertexInput v)
        	{
        		GraphVertexOutput o = (GraphVertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
            	UNITY_TRANSFER_INSTANCE_ID(v, o);
        		UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

        		// Vertex transformations performed by graph
                float3 WorldSpacePosition = mul(UNITY_MATRIX_M,v.vertex).xyz;
                float3 WorldSpaceNormal = normalize(mul(v.normal,(float3x3)UNITY_MATRIX_I_M));
                float3 WorldSpaceTangent = normalize(mul((float3x3)UNITY_MATRIX_M,v.tangent.xyz));
                float3 WorldSpaceBiTangent = cross(WorldSpaceNormal, WorldSpaceTangent.xyz) * v.tangent.w;
                float3 WorldSpaceViewDirection = _WorldSpaceCameraPos.xyz - mul(GetObjectToWorldMatrix(), float4(v.vertex.xyz, 1.0)).xyz;
                float4 uv0 = v.texcoord0;
                float4 uv1 = v.texcoord1;
                float3 ObjectSpacePosition = mul(UNITY_MATRIX_I_M,float4(WorldSpacePosition,1.0)).xyz;

        		VertexDescriptionInputs vdi = (VertexDescriptionInputs)0;

        		// Vertex description inputs defined by graph
                vdi.ObjectSpacePosition = ObjectSpacePosition;

        	    VertexDescription vd = PopulateVertexData(vdi);
        		v.vertex.xyz = vd.Position;

        		// Vertex shader outputs defined by graph
                o.WorldSpacePosition = WorldSpacePosition;
                o.WorldSpaceNormal = WorldSpaceNormal;
                o.WorldSpaceTangent = WorldSpaceTangent;
                o.WorldSpaceBiTangent = WorldSpaceBiTangent;
                o.WorldSpaceViewDirection = WorldSpaceViewDirection;
                o.uv0 = uv0;
                o.uv1 = uv1;

        		float3 lwWNormal = TransformObjectToWorldNormal(v.normal);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
                
         		// We either sample GI from lightmap or SH.
        	    // Lightmap UV and vertex SH coefficients use the same interpolator ("float2 lightmapUV" for lightmap or "half3 vertexSH" for SH)
                // see DECLARE_LIGHTMAP_OR_SH macro.
        	    // The following funcions initialize the correct variable with correct data
        	    OUTPUT_LIGHTMAP_UV(v.texcoord1, unity_LightmapST, o.lightmapUV);
        	    OUTPUT_SH(lwWNormal, o.vertexSH);

        	    half3 vertexLight = VertexLighting(vertexInput.positionWS, lwWNormal);
        	    half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
        	    o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
        	    o.clipPos = vertexInput.positionCS;

        	#ifdef _MAIN_LIGHT_SHADOWS
        		o.shadowCoord = GetShadowCoord(vertexInput);
        	#endif
        		return o;
        	}

        	half4 frag (GraphVertexOutput IN ) : SV_Target
            {
            	UNITY_SETUP_INSTANCE_ID(IN);

        		// Pixel transformations performed by graph
                float3 WorldSpacePosition = IN.WorldSpacePosition;
                float3 WorldSpaceNormal = IN.WorldSpaceNormal;
                float3 WorldSpaceTangent = IN.WorldSpaceTangent;
                float3 WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
                float3 WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
                float4 uv0 = IN.uv0;
                float4 uv1 = IN.uv1;

                SurfaceDescriptionInputs surfaceInput = (SurfaceDescriptionInputs)0;

        		// Surface description inputs defined by graph
                surfaceInput.uv0 = uv0;

                SurfaceDescription surf = PopulateSurfaceData(surfaceInput);

        		float3 Albedo = float3(0.5, 0.5, 0.5);
        		float3 Specular = float3(0, 0, 0);
        		float Metallic = 1;
        		float3 Normal = float3(0, 0, 1);
        		float3 Emission = 0;
        		float Smoothness = 0.5;
        		float Occlusion = 1;
        		float Alpha = 1;
        		float AlphaClipThreshold = 0;

        		// Surface description remap performed by graph
                Albedo = surf.Albedo;
                Normal = surf.Normal;
                Emission = surf.Emission;
                Specular = surf.Specular;
                Smoothness = surf.Smoothness;
                Occlusion = surf.Occlusion;
                Alpha = surf.Alpha;
                AlphaClipThreshold = surf.AlphaClipThreshold;

        		InputData inputData;
        		inputData.positionWS = WorldSpacePosition;

        #ifdef _NORMALMAP
        	    inputData.normalWS = normalize(TransformTangentToWorld(Normal, half3x3(WorldSpaceTangent, WorldSpaceBiTangent, WorldSpaceNormal)));
        #else
            #if !SHADER_HINT_NICE_QUALITY
                inputData.normalWS = WorldSpaceNormal;
            #else
        	    inputData.normalWS = normalize(WorldSpaceNormal);
            #endif
        #endif

        #if !SHADER_HINT_NICE_QUALITY
        	    // viewDirection should be normalized here, but we avoid doing it as it's close enough and we save some ALU.
        	    inputData.viewDirectionWS = WorldSpaceViewDirection;
        #else
        	    inputData.viewDirectionWS = normalize(WorldSpaceViewDirection);
        #endif

        	    inputData.shadowCoord = IN.shadowCoord;

        	    inputData.fogCoord = IN.fogFactorAndVertexLight.x;
        	    inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;
        	    inputData.bakedGI = SAMPLE_GI(IN.lightmapUV, IN.vertexSH, inputData.normalWS);

        		half4 color = LightweightFragmentPBR(
        			inputData, 
        			Albedo, 
        			Metallic, 
        			Specular, 
        			Smoothness, 
        			Occlusion, 
        			Emission, 
        			Alpha);

        		// Computes fog factor per-vertex
            	color.rgb = MixFog(color.rgb, IN.fogFactorAndVertexLight.x);

        #if _AlphaClip
        		clip(Alpha - AlphaClipThreshold);
        #endif
        		return color;
            }

        	ENDHLSL
        }
        Pass
        {
        	Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On ZTest LEqual

            // Material options generated by graph
            Cull Off

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            // Defines generated by graph
            #define _NORMALMAP 1
            #define _SPECULAR_SETUP 1

            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

            CBUFFER_START(UnityPerMaterial)
            CBUFFER_END

            TEXTURE2D(Texture2D_E94A1D41); SAMPLER(samplerTexture2D_E94A1D41); float4 Texture2D_E94A1D41_TexelSize;
            TEXTURE2D(Texture2D_7262B6FF); SAMPLER(samplerTexture2D_7262B6FF); float4 Texture2D_7262B6FF_TexelSize;

            struct VertexDescriptionInputs
            {
                float3 ObjectSpacePosition;
            };

            struct SurfaceDescriptionInputs
            {
                half4 uv0;
            };


            struct VertexDescription
            {
                float3 Position;
            };

            VertexDescription PopulateVertexData(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                return description;
            }

            struct SurfaceDescription
            {
                float3 Albedo;
                float3 Emission;
                float Alpha;
                float AlphaClipThreshold;
            };

            SurfaceDescription PopulateSurfaceData(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float4 _SampleTexture2D_25824A8A_RGBA = SAMPLE_TEXTURE2D(Texture2D_E94A1D41, samplerTexture2D_E94A1D41, IN.uv0.xy);
                float _SampleTexture2D_25824A8A_R = _SampleTexture2D_25824A8A_RGBA.r;
                float _SampleTexture2D_25824A8A_G = _SampleTexture2D_25824A8A_RGBA.g;
                float _SampleTexture2D_25824A8A_B = _SampleTexture2D_25824A8A_RGBA.b;
                float _SampleTexture2D_25824A8A_A = _SampleTexture2D_25824A8A_RGBA.a;
                surface.Albedo = IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0));
                surface.Emission = (_SampleTexture2D_25824A8A_RGBA.xyz);
                surface.Alpha = 1;
                surface.AlphaClipThreshold = 0;
                return surface;
            }

            struct GraphVertexInput
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord0 : TEXCOORD0;
                float4 texcoord1 : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };


        	struct VertexOutput
        	{
        	    float2 uv           : TEXCOORD0;
        	    float4 clipPos      : SV_POSITION;
                // Interpolators defined by graph
                float3 WorldSpacePosition : TEXCOORD3;
                float3 WorldSpaceNormal : TEXCOORD4;
                float3 WorldSpaceTangent : TEXCOORD5;
                float3 WorldSpaceBiTangent : TEXCOORD6;
                float3 WorldSpaceViewDirection : TEXCOORD7;
                half4 uv0 : TEXCOORD8;
                half4 uv1 : TEXCOORD9;

                UNITY_VERTEX_INPUT_INSTANCE_ID
        	};

            // x: global clip space bias, y: normal world space bias
            float4 _ShadowBias;
            float3 _LightDirection;

            VertexOutput ShadowPassVertex(GraphVertexInput v)
        	{
        	    VertexOutput o;
        	    UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                // Vertex transformations performed by graph
                float3 WorldSpacePosition = mul(UNITY_MATRIX_M,v.vertex).xyz;
                float3 WorldSpaceNormal = normalize(mul(v.normal,(float3x3)UNITY_MATRIX_I_M));
                float3 WorldSpaceTangent = normalize(mul((float3x3)UNITY_MATRIX_M,v.tangent.xyz));
                float3 WorldSpaceBiTangent = cross(WorldSpaceNormal, WorldSpaceTangent.xyz) * v.tangent.w;
                float3 WorldSpaceViewDirection = _WorldSpaceCameraPos.xyz - mul(GetObjectToWorldMatrix(), float4(v.vertex.xyz, 1.0)).xyz;
                float4 uv0 = v.texcoord0;
                float4 uv1 = v.texcoord1;
                float3 ObjectSpacePosition = mul(UNITY_MATRIX_I_M,float4(WorldSpacePosition,1.0)).xyz;

        		VertexDescriptionInputs vdi = (VertexDescriptionInputs)0;

                // Vertex description inputs defined by graph
                vdi.ObjectSpacePosition = ObjectSpacePosition;

        	    VertexDescription vd = PopulateVertexData(vdi);
                v.vertex.xyz = vd.Position;

        	    // Vertex shader outputs defined by graph
                o.WorldSpacePosition = WorldSpacePosition;
                o.WorldSpaceNormal = WorldSpaceNormal;
                o.WorldSpaceTangent = WorldSpaceTangent;
                o.WorldSpaceBiTangent = WorldSpaceBiTangent;
                o.WorldSpaceViewDirection = WorldSpaceViewDirection;
                o.uv0 = uv0;
                o.uv1 = uv1;

        	    
        	    float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                float3 normalWS = TransformObjectToWorldNormal(v.normal);

                float invNdotL = 1.0 - saturate(dot(_LightDirection, normalWS));
                float scale = invNdotL * _ShadowBias.y;

                // normal bias is negative since we want to apply an inset normal offset
                positionWS = normalWS * scale.xxx + positionWS;
                float4 clipPos = TransformWorldToHClip(positionWS);

                // _ShadowBias.x sign depens on if platform has reversed z buffer
                clipPos.z += _ShadowBias.x;

        	#if UNITY_REVERSED_Z
        	    clipPos.z = min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
        	#else
        	    clipPos.z = max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
        	#endif
                o.clipPos = clipPos;

        	    return o;
        	}

            half4 ShadowPassFragment(VertexOutput IN ) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);

                // Pixel transformations performed by graph
                float3 WorldSpacePosition = IN.WorldSpacePosition;
                float3 WorldSpaceNormal = IN.WorldSpaceNormal;
                float3 WorldSpaceTangent = IN.WorldSpaceTangent;
                float3 WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
                float3 WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
                float4 uv0 = IN.uv0;
                float4 uv1 = IN.uv1;

                SurfaceDescriptionInputs surfaceInput = (SurfaceDescriptionInputs)0;

        		// Surface description inputs defined by graph
                surfaceInput.uv0 = uv0;

                SurfaceDescription surf = PopulateSurfaceData(surfaceInput);

                float3 Albedo = float3(0.5, 0.5, 0.5);
        		float3 Emission = 0;
        		float Alpha = 1;
        		float AlphaClipThreshold = 0;

        		// Surface description remap performed by graph
                Albedo = surf.Albedo;
                Emission = surf.Emission;
                Alpha = surf.Alpha;
                AlphaClipThreshold = surf.AlphaClipThreshold;

         #if _AlphaClip
        		clip(Alpha - AlphaClipThreshold);
        #endif
                return 0;
            }

            ENDHLSL
        }

        Pass
        {
        	Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ColorMask 0

            // Material options generated by graph
            Cull Off

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex vert
            #pragma fragment frag

            // Defines generated by graph
            #define _NORMALMAP 1
            #define _SPECULAR_SETUP 1

            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

            CBUFFER_START(UnityPerMaterial)
            CBUFFER_END

            TEXTURE2D(Texture2D_E94A1D41); SAMPLER(samplerTexture2D_E94A1D41); float4 Texture2D_E94A1D41_TexelSize;
            TEXTURE2D(Texture2D_7262B6FF); SAMPLER(samplerTexture2D_7262B6FF); float4 Texture2D_7262B6FF_TexelSize;

            struct VertexDescriptionInputs
            {
                float3 ObjectSpacePosition;
            };

            struct SurfaceDescriptionInputs
            {
                half4 uv0;
            };


            struct VertexDescription
            {
                float3 Position;
            };

            VertexDescription PopulateVertexData(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                return description;
            }

            struct SurfaceDescription
            {
                float3 Albedo;
                float3 Emission;
                float Alpha;
                float AlphaClipThreshold;
            };

            SurfaceDescription PopulateSurfaceData(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float4 _SampleTexture2D_25824A8A_RGBA = SAMPLE_TEXTURE2D(Texture2D_E94A1D41, samplerTexture2D_E94A1D41, IN.uv0.xy);
                float _SampleTexture2D_25824A8A_R = _SampleTexture2D_25824A8A_RGBA.r;
                float _SampleTexture2D_25824A8A_G = _SampleTexture2D_25824A8A_RGBA.g;
                float _SampleTexture2D_25824A8A_B = _SampleTexture2D_25824A8A_RGBA.b;
                float _SampleTexture2D_25824A8A_A = _SampleTexture2D_25824A8A_RGBA.a;
                surface.Albedo = IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0));
                surface.Emission = (_SampleTexture2D_25824A8A_RGBA.xyz);
                surface.Alpha = 1;
                surface.AlphaClipThreshold = 0;
                return surface;
            }

            struct GraphVertexInput
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord0 : TEXCOORD0;
                float4 texcoord1 : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };


        	struct VertexOutput
        	{
        	    float2 uv           : TEXCOORD0;
        	    float4 clipPos      : SV_POSITION;
                // Interpolators defined by graph
                float3 WorldSpacePosition : TEXCOORD3;
                float3 WorldSpaceNormal : TEXCOORD4;
                float3 WorldSpaceTangent : TEXCOORD5;
                float3 WorldSpaceBiTangent : TEXCOORD6;
                float3 WorldSpaceViewDirection : TEXCOORD7;
                half4 uv0 : TEXCOORD8;
                half4 uv1 : TEXCOORD9;

                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
        	};

            VertexOutput vert(GraphVertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
        	    UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

        	    // Vertex transformations performed by graph
                float3 WorldSpacePosition = mul(UNITY_MATRIX_M,v.vertex).xyz;
                float3 WorldSpaceNormal = normalize(mul(v.normal,(float3x3)UNITY_MATRIX_I_M));
                float3 WorldSpaceTangent = normalize(mul((float3x3)UNITY_MATRIX_M,v.tangent.xyz));
                float3 WorldSpaceBiTangent = cross(WorldSpaceNormal, WorldSpaceTangent.xyz) * v.tangent.w;
                float3 WorldSpaceViewDirection = _WorldSpaceCameraPos.xyz - mul(GetObjectToWorldMatrix(), float4(v.vertex.xyz, 1.0)).xyz;
                float4 uv0 = v.texcoord0;
                float4 uv1 = v.texcoord1;
                float3 ObjectSpacePosition = mul(UNITY_MATRIX_I_M,float4(WorldSpacePosition,1.0)).xyz;

        		VertexDescriptionInputs vdi = (VertexDescriptionInputs)0;

                // Vertex description inputs defined by graph
                vdi.ObjectSpacePosition = ObjectSpacePosition;

        	    VertexDescription vd = PopulateVertexData(vdi);
                v.vertex.xyz = vd.Position;

        	    // Vertex shader outputs defined by graph
                o.WorldSpacePosition = WorldSpacePosition;
                o.WorldSpaceNormal = WorldSpaceNormal;
                o.WorldSpaceTangent = WorldSpaceTangent;
                o.WorldSpaceBiTangent = WorldSpaceBiTangent;
                o.WorldSpaceViewDirection = WorldSpaceViewDirection;
                o.uv0 = uv0;
                o.uv1 = uv1;

        	    o.clipPos = TransformObjectToHClip(v.vertex.xyz);
        	    return o;
            }

            half4 frag(VertexOutput IN ) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);

                // Pixel transformations performed by graph
                float3 WorldSpacePosition = IN.WorldSpacePosition;
                float3 WorldSpaceNormal = IN.WorldSpaceNormal;
                float3 WorldSpaceTangent = IN.WorldSpaceTangent;
                float3 WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
                float3 WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
                float4 uv0 = IN.uv0;
                float4 uv1 = IN.uv1;

                SurfaceDescriptionInputs surfaceInput = (SurfaceDescriptionInputs)0;

        		// Surface description inputs defined by graph
                surfaceInput.uv0 = uv0;

                SurfaceDescription surf = PopulateSurfaceData(surfaceInput);

                float3 Albedo = float3(0.5, 0.5, 0.5);
        		float3 Emission = 0;
        		float Alpha = 1;
        		float AlphaClipThreshold = 0;

        		// Surface description remap performed by graph
                Albedo = surf.Albedo;
                Emission = surf.Emission;
                Alpha = surf.Alpha;
                AlphaClipThreshold = surf.AlphaClipThreshold;

         #if _AlphaClip
        		clip(Alpha - AlphaClipThreshold);
        #endif
                return 0;
            }
            ENDHLSL
        }

        // This pass it not used during regular rendering, only for lightmap baking.
        Pass
        {
        	Name "Meta"
            Tags{"LightMode" = "Meta"}

            Cull Off

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma vertex vert
            #pragma fragment frag

            float4 _MainTex_ST;

            // Defines generated by graph
            #define _NORMALMAP 1
            #define _SPECULAR_SETUP 1

            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/MetaInput.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

                CBUFFER_START(UnityPerMaterial)
            CBUFFER_END

            TEXTURE2D(Texture2D_E94A1D41); SAMPLER(samplerTexture2D_E94A1D41); float4 Texture2D_E94A1D41_TexelSize;
            TEXTURE2D(Texture2D_7262B6FF); SAMPLER(samplerTexture2D_7262B6FF); float4 Texture2D_7262B6FF_TexelSize;

            struct VertexDescriptionInputs
            {
                float3 ObjectSpacePosition;
            };

            struct SurfaceDescriptionInputs
            {
                half4 uv0;
            };


            struct VertexDescription
            {
                float3 Position;
            };

            VertexDescription PopulateVertexData(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                return description;
            }

            struct SurfaceDescription
            {
                float3 Albedo;
                float3 Emission;
                float Alpha;
                float AlphaClipThreshold;
            };

            SurfaceDescription PopulateSurfaceData(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float4 _SampleTexture2D_25824A8A_RGBA = SAMPLE_TEXTURE2D(Texture2D_E94A1D41, samplerTexture2D_E94A1D41, IN.uv0.xy);
                float _SampleTexture2D_25824A8A_R = _SampleTexture2D_25824A8A_RGBA.r;
                float _SampleTexture2D_25824A8A_G = _SampleTexture2D_25824A8A_RGBA.g;
                float _SampleTexture2D_25824A8A_B = _SampleTexture2D_25824A8A_RGBA.b;
                float _SampleTexture2D_25824A8A_A = _SampleTexture2D_25824A8A_RGBA.a;
                surface.Albedo = IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0));
                surface.Emission = (_SampleTexture2D_25824A8A_RGBA.xyz);
                surface.Alpha = 1;
                surface.AlphaClipThreshold = 0;
                return surface;
            }

            struct GraphVertexInput
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord0 : TEXCOORD0;
                float4 texcoord1 : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };


        	struct VertexOutput
        	{
        	    float2 uv           : TEXCOORD0;
        	    float4 clipPos      : SV_POSITION;
                // Interpolators defined by graph
                float3 WorldSpacePosition : TEXCOORD3;
                float3 WorldSpaceNormal : TEXCOORD4;
                float3 WorldSpaceTangent : TEXCOORD5;
                float3 WorldSpaceBiTangent : TEXCOORD6;
                float3 WorldSpaceViewDirection : TEXCOORD7;
                half4 uv0 : TEXCOORD8;
                half4 uv1 : TEXCOORD9;

                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
        	};

            VertexOutput vert(GraphVertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
        	    UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

        	    // Vertex transformations performed by graph
                float3 WorldSpacePosition = mul(UNITY_MATRIX_M,v.vertex).xyz;
                float3 WorldSpaceNormal = normalize(mul(v.normal,(float3x3)UNITY_MATRIX_I_M));
                float3 WorldSpaceTangent = normalize(mul((float3x3)UNITY_MATRIX_M,v.tangent.xyz));
                float3 WorldSpaceBiTangent = cross(WorldSpaceNormal, WorldSpaceTangent.xyz) * v.tangent.w;
                float3 WorldSpaceViewDirection = _WorldSpaceCameraPos.xyz - mul(GetObjectToWorldMatrix(), float4(v.vertex.xyz, 1.0)).xyz;
                float4 uv0 = v.texcoord0;
                float4 uv1 = v.texcoord1;
                float3 ObjectSpacePosition = mul(UNITY_MATRIX_I_M,float4(WorldSpacePosition,1.0)).xyz;


        	    // Vertex shader outputs defined by graph
                o.WorldSpacePosition = WorldSpacePosition;
                o.WorldSpaceNormal = WorldSpaceNormal;
                o.WorldSpaceTangent = WorldSpaceTangent;
                o.WorldSpaceBiTangent = WorldSpaceBiTangent;
                o.WorldSpaceViewDirection = WorldSpaceViewDirection;
                o.uv0 = uv0;
                o.uv1 = uv1;

                o.clipPos = MetaVertexPosition(v.vertex, uv1, uv1, unity_LightmapST);
        	    return o;
            }

            half4 frag(VertexOutput IN ) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);

                // Pixel transformations performed by graph
                float3 WorldSpacePosition = IN.WorldSpacePosition;
                float3 WorldSpaceNormal = IN.WorldSpaceNormal;
                float3 WorldSpaceTangent = IN.WorldSpaceTangent;
                float3 WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
                float3 WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
                float4 uv0 = IN.uv0;
                float4 uv1 = IN.uv1;

                SurfaceDescriptionInputs surfaceInput = (SurfaceDescriptionInputs)0;

        		// Surface description inputs defined by graph
                surfaceInput.uv0 = uv0;

                SurfaceDescription surf = PopulateSurfaceData(surfaceInput);

        		float3 Albedo = float3(0.5, 0.5, 0.5);
        		float3 Emission = 0;
        		float Alpha = 1;
        		float AlphaClipThreshold = 0;

        		// Surface description remap performed by graph
                Albedo = surf.Albedo;
                Emission = surf.Emission;
                Alpha = surf.Alpha;
                AlphaClipThreshold = surf.AlphaClipThreshold;

         #if _AlphaClip
        		clip(Alpha - AlphaClipThreshold);
        #endif

                MetaInput metaInput = (MetaInput)0;
                metaInput.Albedo = Albedo;
                metaInput.Emission = Emission;
                
                return MetaFragment(metaInput);
            }
            ENDHLSL
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
    FallBack "Hidden/InternalErrorShader"
}
