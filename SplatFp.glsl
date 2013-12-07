#version 120
//
// Splatting fragment shader
// Copyright (C) 2009  Alexey Torkhov
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

// Splatting part is based on older Ember shader written by Erik Hjortsberg

// Number of lights
// 3 is resonable number to support
#ifndef NUM_LIGHTS
#define NUM_LIGHTS      3
#endif // ifndef NUM_LIGHTS

#if OFFSET_MAPPING
#define OFFSET_MAPPING_DISTANCE 50.0
#endif // if OFFSET_MAPPING

// Either have shadows or not
// Supports 3 lights
#ifndef SHADOW
#define SHADOW                  1
#endif // ifndef SHADOW

//BASE_LAYER defines if we should use a base layer or not.
//The base layer has no blend map attached to it, so this affects how the blend maps
//are mapped to different layers.
#ifndef BASE_LAYER
#define BASE_LAYER                  1
#endif // ifndef BASE_LAYER

#define PCF                             1

// Number of splatting layers, should be set from application
#ifndef NUM_LAYERS
#define NUM_LAYERS      1
#endif // ifndef NUM_LAYERS

#if NUM_LIGHTS > 0

// Normals are stored in a texture, not per-vertex, in object space
uniform sampler2D normalTexture;

///The number of active lights. This can be less than NUM_LIGHTS depending on the scene.
uniform float numberOfActiveLights;
#endif // if NUM_LIGHTS > 0

//If set to 1, fog colour will be disabled. This is needed when doing multipass blending.
uniform int disableFogColour;

#if SHADOW
#define LINEAR_RANGE 0

// Shadow maps
uniform sampler2D shadowMap0;
uniform sampler2D shadowMap1;
uniform sampler2D shadowMap2;
uniform sampler2D shadowMap3;
uniform sampler2D shadowMap4;

uniform vec4 inverseShadowMapSize0;
uniform vec4 inverseShadowMapSize1;
uniform vec4 inverseShadowMapSize2;
uniform vec4 inverseShadowMapSize3;
uniform vec4 inverseShadowMapSize4;

uniform float fixedDepthBias;
uniform float gradientClamp;
uniform float gradientScaleBias;

uniform vec4 pssmSplitPoints;

// Shadow texture coordinates
varying vec4 shadowTexCoord0;
varying vec4 shadowTexCoord1;
varying vec4 shadowTexCoord2;
varying vec4 shadowTexCoord3;
varying vec4 shadowTexCoord4;
#endif // if SHADOW

#if NUM_LAYERS > 0
#if NUM_LAYERS > 8
uniform vec4 scales[3];
#else
#if NUM_LAYERS > 4
uniform vec4 scales[2];
#else
uniform vec4 scales[1];
#endif // if NUM_LAYERS > 4
#endif // if NUM_LAYERS > 8
#if BASE_LAYER
uniform sampler2D baseTextureDiffuse;
#if NUM_LAYERS > 1
uniform sampler2D blendMap1;
uniform sampler2D diffuseTexture1;
#endif // if NUM_LAYERS > 1
#if NUM_LAYERS > 2
uniform sampler2D diffuseTexture2;
#endif // if NUM_LAYERS > 2
#if NUM_LAYERS > 3
uniform sampler2D diffuseTexture3;
#endif // if NUM_LAYERS > 3
#if NUM_LAYERS > 4
uniform sampler2D diffuseTexture4;
#endif // if NUM_LAYERS > 4
#if NUM_LAYERS > 5
uniform sampler2D blendMap2;
uniform sampler2D diffuseTexture5;
#endif // if NUM_LAYERS > 5
#if NUM_LAYERS > 6
uniform sampler2D diffuseTexture6;
#endif // if NUM_LAYERS > 6
#if NUM_LAYERS > 7
uniform sampler2D diffuseTexture7;
#endif // if NUM_LAYERS > 7
#if NUM_LAYERS > 8
uniform sampler2D diffuseTexture8;
#endif // if NUM_LAYERS > 8
#if NUM_LAYERS > 9
uniform sampler2D blendMap3;
uniform sampler2D diffuseTexture9;
#endif // if NUM_LAYERS > 9
#if NUM_LAYERS > 10
uniform sampler2D diffuseTexture10;
#endif // if NUM_LAYERS > 10
#if NUM_LAYERS > 11
uniform sampler2D diffuseTexture11;
#endif // if NUM_LAYERS > 11

#else // if !BASE_LAYER

uniform sampler2D blendMap1;
uniform sampler2D diffuseTexture1;

#if NUM_LAYERS > 1
uniform sampler2D diffuseTexture2;
#endif // if NUM_LAYERS > 2
#if NUM_LAYERS > 2
uniform sampler2D diffuseTexture3;
#endif // if NUM_LAYERS > 3
#if NUM_LAYERS > 3
uniform sampler2D diffuseTexture4;
#endif // if NUM_LAYERS > 4
#if NUM_LAYERS > 4
uniform sampler2D blendMap2;
uniform sampler2D diffuseTexture5;
#endif // if NUM_LAYERS > 4
#if NUM_LAYERS > 5
uniform sampler2D diffuseTexture6;
#endif // if NUM_LAYERS > 5
#if NUM_LAYERS > 6
uniform sampler2D diffuseTexture7;
#endif // if NUM_LAYERS > 6
#if NUM_LAYERS > 7
uniform sampler2D diffuseTexture8;
#endif // if NUM_LAYERS > 7
#if NUM_LAYERS > 8
uniform sampler2D blendMap3;
uniform sampler2D diffuseTexture9;
#endif // if NUM_LAYERS > 8
#if NUM_LAYERS > 9
uniform sampler2D diffuseTexture10;
#endif // if NUM_LAYERS > 9
#if NUM_LAYERS > 10
uniform sampler2D diffuseTexture11;
#endif // if NUM_LAYERS > 10

#endif // if BASE_LAYER

#endif // if NUM_LAYERS > 0

#if OFFSET_MAPPING

// Scale and bias for parallax
// Having scale = 0,05 - 0,1 provides big visual depth
// Bias = - scale/2  shifts texture equally by depth
// Bias = - scale    is also good to have holes or scratches on flat surface
uniform vec2 scaleBias;

uniform vec3 cameraPositionObjSpace;

#if BASE_LAYER
uniform sampler2D baseTextureNormalHeight;
#if NUM_LAYERS > 1
uniform sampler2D normalHeightTexture1;
#endif // if NUM_LAYERS > 1
#if NUM_LAYERS > 2
uniform sampler2D normalHeightTexture2;
#endif // if NUM_LAYERS > 2
#if NUM_LAYERS > 3
uniform sampler2D normalHeightTexture3;
#endif // if NUM_LAYERS > 3
#if NUM_LAYERS > 4
uniform sampler2D normalHeightTexture4;
#endif // if NUM_LAYERS > 4
#if NUM_LAYERS > 5
uniform sampler2D normalHeightTexture5;
#endif // if NUM_LAYERS > 5
#if NUM_LAYERS > 6
uniform sampler2D normalHeightTexture6;
#endif // if NUM_LAYERS > 6
#if NUM_LAYERS > 7
uniform sampler2D normalHeightTexture7;
#endif // if NUM_LAYERS > 7
#if NUM_LAYERS > 8
uniform sampler2D normalHeightTexture8;
#endif // if NUM_LAYERS > 8
#if NUM_LAYERS > 9
uniform sampler2D normalHeightTexture9;
#endif // if NUM_LAYERS > 9
#if NUM_LAYERS > 10
uniform sampler2D normalHeightTexture10;
#endif // if NUM_LAYERS > 10
#if NUM_LAYERS > 11
uniform sampler2D normalHeightTexture11;
#endif // if NUM_LAYERS > 11

#else // else BASE_LAYER

#if NUM_LAYERS > 0
uniform sampler2D normalHeightTexture1;
#endif // if NUM_LAYERS > 0
#if NUM_LAYERS > 1
uniform sampler2D normalHeightTexture2;
#endif // if NUM_LAYERS > 1
#if NUM_LAYERS > 2
uniform sampler2D normalHeightTexture3;
#endif // if NUM_LAYERS > 2
#if NUM_LAYERS > 3
uniform sampler2D normalHeightTexture4;
#endif // if NUM_LAYERS > 3
#if NUM_LAYERS > 4
uniform sampler2D normalHeightTexture5;
#endif // if NUM_LAYERS > 4
#if NUM_LAYERS > 5
uniform sampler2D normalHeightTexture6;
#endif // if NUM_LAYERS > 5
#if NUM_LAYERS > 6
uniform sampler2D normalHeightTexture7;
#endif // if NUM_LAYERS > 6
#if NUM_LAYERS > 7
uniform sampler2D normalHeightTexture8;
#endif // if NUM_LAYERS > 7
#if NUM_LAYERS > 8
uniform sampler2D normalHeightTexture9;
#endif // if NUM_LAYERS > 8
#if NUM_LAYERS > 9
uniform sampler2D normalHeightTexture10;
#endif // if NUM_LAYERS > 9
#if NUM_LAYERS > 10
uniform sampler2D normalHeightTexture11;
#endif // if NUM_LAYERS > 10

#endif // if BASE_LAYER


#endif // if OFFSET_MAPPING

// Fog factor
varying float fog;

varying vec3 positionObjSpace;

// Light attenuation, packed to vector
varying vec3 attenuation;

// Bring the specified [0.0, 1.0] vector into [-1.0, 1.0] range
vec3 expand(in vec3 param)
{
	return param * 2.0 - 1.0;
}

#if NUM_LAYERS > 0

#if OFFSET_MAPPING
#if BASE_LAYER
vec4 splatting_offset_mapping(in vec2 texCoord, in vec2 cameraDirTangentSpace, out vec3 blendedNormal)
{
	vec4 diffuseColour;
	// Temporary variables used by each layer calculation
	vec2 uv;         // scaled texCoord
	vec3 layerNormal;
	float displacement;
	float blendWeight;

	uv = texCoord * scales[0][0];
	displacement = texture2D(baseTextureNormalHeight, uv).a * scaleBias.x + scaleBias.y;
	uv += cameraDirTangentSpace * displacement;
	blendedNormal = texture2D(baseTextureNormalHeight, uv).rgb;
	diffuseColour = texture2D(baseTextureDiffuse, uv);

#if NUM_LAYERS > 1
	uv = texCoord * scales[0][1];
	displacement = texture2D(normalHeightTexture1, uv).a * scaleBias.x + scaleBias.y;
	uv += cameraDirTangentSpace * displacement;
	blendWeight = texture2D(blendMap1, texCoord).w;         // Need to use unscaled uv here since blend map = unscaled
	blendedNormal = mix(blendedNormal, texture2D(normalHeightTexture1, uv).rgb, blendWeight);
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture1, uv), blendWeight);
#endif // if NUM_LAYERS > 1
#if NUM_LAYERS > 2
	uv = texCoord * scales[0][2];
	displacement = texture2D(normalHeightTexture2, uv).a * scaleBias.x + scaleBias.y;
	uv += cameraDirTangentSpace * displacement;
	blendWeight = texture2D(blendMap1, texCoord).x;         // Need to use unscaled uv here since blend map = unscaled
	blendedNormal = mix(blendedNormal, texture2D(normalHeightTexture2, uv).rgb, blendWeight);
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture2, uv), blendWeight);
#endif // if NUM_LAYERS > 2
#if NUM_LAYERS > 3
	uv = texCoord * scales[0][3];
	displacement = texture2D(normalHeightTexture3, uv).a * scaleBias.x + scaleBias.y;
	uv += cameraDirTangentSpace * displacement;
	blendWeight = texture2D(blendMap1, texCoord).y;         // Need to use unscaled uv here since blend map = unscaled
	blendedNormal = mix(blendedNormal, texture2D(normalHeightTexture3, uv).rgb, blendWeight);
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture3, uv), blendWeight);
#endif // if NUM_LAYERS > 3
#if NUM_LAYERS > 4
	uv = texCoord * scales[1][0];
	displacement = texture2D(normalHeightTexture4, uv).a * scaleBias.x + scaleBias.y;
	uv += cameraDirTangentSpace * displacement;
	blendWeight = texture2D(blendMap1, texCoord).z;         // Need to use unscaled uv here since blend map = unscaled
	blendedNormal = mix(blendedNormal, texture2D(normalHeightTexture4, uv).rgb, blendWeight);
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture4, uv), blendWeight);
#endif // if NUM_LAYERS > 4
#if NUM_LAYERS > 5
	uv = texCoord * scales[1][1];
	displacement = texture2D(normalHeightTexture5, uv).a * scaleBias.x + scaleBias.y;
	uv += cameraDirTangentSpace * displacement;
	blendWeight = texture2D(blendMap2, texCoord).w;         // Need to use unscaled uv here since blend map = unscaled
	blendedNormal = mix(blendedNormal, texture2D(normalHeightTexture5, uv).rgb, blendWeight);
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture5, uv), blendWeight);
#endif // if NUM_LAYERS > 5
#if NUM_LAYERS > 6
	uv = texCoord * scales[1][2];
	displacement = texture2D(normalHeightTexture6, uv).a * scaleBias.x + scaleBias.y;
	uv += cameraDirTangentSpace * displacement;
	blendWeight = texture2D(blendMap2, texCoord).x;         // Need to use unscaled uv here since blend map = unscaled
	blendedNormal = mix(blendedNormal, texture2D(normalHeightTexture6, uv).rgb, blendWeight);
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture6, uv), blendWeight);
#endif // if NUM_LAYERS > 6
#if NUM_LAYERS > 7
	uv = texCoord * scales[1][3];
	displacement = texture2D(normalHeightTexture7, uv).a * scaleBias.x + scaleBias.y;
	uv += cameraDirTangentSpace * displacement;
	blendWeight = texture2D(blendMap2, texCoord).y;         // Need to use unscaled uv here since blend map = unscaled
	blendedNormal = mix(blendedNormal, texture2D(normalHeightTexture7, uv).rgb, blendWeight);
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture7, uv), blendWeight);
#endif // if NUM_LAYERS > 7
#if NUM_LAYERS > 8
	uv = texCoord * scales[2][0];
	displacement = texture2D(normalHeightTexture8, uv).a * scaleBias.x + scaleBias.y;
	uv += cameraDirTangentSpace * displacement;
	blendWeight = texture2D(blendMap2, texCoord).z;         // Need to use unscaled uv here since blend map = unscaled
	blendedNormal = mix(blendedNormal, texture2D(normalHeightTexture8, uv).rgb, blendWeight);
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture8, uv), blendWeight);
#endif // if NUM_LAYERS > 8
#if NUM_LAYERS > 9
	uv = texCoord * scales[2][1];
	displacement = texture2D(normalHeightTexture9, uv).a * scaleBias.x + scaleBias.y;
	uv += cameraDirTangentSpace * displacement;
	blendWeight = texture2D(blendMap3, texCoord).w;         // Need to use unscaled uv here since blend map = unscaled
	blendedNormal = mix(blendedNormal, texture2D(normalHeightTexture9, uv).rgb, blendWeight);
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture9, uv), blendWeight);
#endif // if NUM_LAYERS > 9
#if NUM_LAYERS > 10
	uv = texCoord * scales[2][2];
	displacement = texture2D(normalHeightTexture10, uv).a * scaleBias.x + scaleBias.y;
	uv += cameraDirTangentSpace * displacement;
	blendWeight = texture2D(blendMap3, texCoord).x;         // Need to use unscaled uv here since blend map = unscaled
	blendedNormal = mix(blendedNormal, texture2D(normalHeightTexture10, uv).rgb, blendWeight);
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture10, uv), blendWeight);
#endif // if NUM_LAYERS > 10
#if NUM_LAYERS > 11
	uv = texCoord * scales[2][3];
	displacement = texture2D(normalHeightTexture11, uv).a * scaleBias.x + scaleBias.y;
	uv += cameraDirTangentSpace * displacement;
	blendWeight = texture2D(blendMap3, texCoord).y;         // Need to use unscaled uv here since blend map = unscaled
	blendedNormal = mix(blendedNormal, texture2D(normalHeightTexture11, uv).rgb, blendWeight);
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture11, uv), blendWeight);
#endif // if NUM_LAYERS > 11

	blendedNormal = normalize(expand(blendedNormal));
	return diffuseColour;
}
#else //if !BASE_LAYER

vec4 splatting_offset_mapping(in vec2 texCoord, in vec2 cameraDirTangentSpace, out vec3 blendedNormal)
{
	vec4 diffuseColour;
	// Temporary variables used by each layer calculation
	vec2 uv;         // scaled texCoord
	float displacement;
	float blendWeight;

	uv = texCoord * scales[0][0];
	displacement = texture2D(normalHeightTexture1, uv).a * scaleBias.x + scaleBias.y;
	uv += cameraDirTangentSpace * displacement;
	blendWeight = texture2D(blendMap1, texCoord).w;         // Need to use unscaled uv here since blend map = unscaled
	blendedNormal = texture2D(normalHeightTexture1, uv).rgb;
	diffuseColour = texture2D(diffuseTexture1, uv) * blendWeight;
#if NUM_LAYERS > 1
	uv = texCoord * scales[0][1];
	displacement = texture2D(normalHeightTexture2, uv).a * scaleBias.x + scaleBias.y;
	uv += cameraDirTangentSpace * displacement;
	blendWeight = texture2D(blendMap1, texCoord).x;         // Need to use unscaled uv here since blend map = unscaled
	blendedNormal = mix(blendedNormal, texture2D(normalHeightTexture2, uv).rgb, blendWeight);
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture2, uv), blendWeight);
#endif // if NUM_LAYERS > 1
#if NUM_LAYERS > 2
	uv = texCoord * scales[0][2];
	displacement = texture2D(normalHeightTexture3, uv).a * scaleBias.x + scaleBias.y;
	uv += cameraDirTangentSpace * displacement;
	blendWeight = texture2D(blendMap1, texCoord).y;         // Need to use unscaled uv here since blend map = unscaled
	blendedNormal = mix(blendedNormal, texture2D(normalHeightTexture3, uv).rgb, blendWeight);
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture3, uv), blendWeight);
#endif // if NUM_LAYERS > 2
#if NUM_LAYERS > 3
	uv = texCoord * scales[0][3];
	displacement = texture2D(normalHeightTexture4, uv).a * scaleBias.x + scaleBias.y;
	uv += cameraDirTangentSpace * displacement;
	blendWeight = texture2D(blendMap1, texCoord).z;         // Need to use unscaled uv here since blend map = unscaled
	blendedNormal = mix(blendedNormal, texture2D(normalHeightTexture4, uv).rgb, blendWeight);
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture4, uv), blendWeight);
#endif // if NUM_LAYERS > 3
#if NUM_LAYERS > 4
	uv = texCoord * scales[1][0];
	displacement = texture2D(normalHeightTexture5, uv).a * scaleBias.x + scaleBias.y;
	uv += cameraDirTangentSpace * displacement;
	blendWeight = texture2D(blendMap2, texCoord).w;         // Need to use unscaled uv here since blend map = unscaled
	blendedNormal = mix(blendedNormal, texture2D(normalHeightTexture5, uv).rgb, blendWeight);
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture5, uv), blendWeight);
#endif // if NUM_LAYERS > 4
#if NUM_LAYERS > 5
	uv = texCoord * scales[1][1];
	displacement = texture2D(normalHeightTexture6, uv).a * scaleBias.x + scaleBias.y;
	uv += cameraDirTangentSpace * displacement;
	blendWeight = texture2D(blendMap2, texCoord).x;         // Need to use unscaled uv here since blend map = unscaled
	blendedNormal = mix(blendedNormal, texture2D(normalHeightTexture6, uv).rgb, blendWeight);
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture6, uv), blendWeight);
#endif // if NUM_LAYERS > 5
#if NUM_LAYERS > 6
	uv = texCoord * scales[1][2];
	displacement = texture2D(normalHeightTexture7, uv).a * scaleBias.x + scaleBias.y;
	uv += cameraDirTangentSpace * displacement;
	blendWeight = texture2D(blendMap2, texCoord).y;         // Need to use unscaled uv here since blend map = unscaled
	blendedNormal = mix(blendedNormal, texture2D(normalHeightTexture7, uv).rgb, blendWeight);
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture7, uv), blendWeight);
#endif // if NUM_LAYERS > 6
#if NUM_LAYERS > 7
	uv = texCoord * scales[1][3];
	displacement = texture2D(normalHeightTexture8, uv).a * scaleBias.x + scaleBias.y;
	uv += cameraDirTangentSpace * displacement;
	blendWeight = texture2D(blendMap2, texCoord).z;         // Need to use unscaled uv here since blend map = unscaled
	blendedNormal = mix(blendedNormal, texture2D(normalHeightTexture8, uv).rgb, blendWeight);
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture8, uv), blendWeight);
#endif // if NUM_LAYERS > 7
#if NUM_LAYERS > 8
	uv = texCoord * scales[2][0];
	displacement = texture2D(normalHeightTexture9, uv).a * scaleBias.x + scaleBias.y;
	uv += cameraDirTangentSpace * displacement;
	blendWeight = texture2D(blendMap3, texCoord).w;         // Need to use unscaled uv here since blend map = unscaled
	blendedNormal = mix(blendedNormal, texture2D(normalHeightTexture9, uv).rgb, blendWeight);
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture9, uv), blendWeight);
#endif // if NUM_LAYERS > 8
#if NUM_LAYERS > 9
	uv = texCoord * scales[2][1];
	displacement = texture2D(normalHeightTexture10, uv).a * scaleBias.x + scaleBias.y;
	uv += cameraDirTangentSpace * displacement;
	blendWeight = texture2D(blendMap3, texCoord).x;         // Need to use unscaled uv here since blend map = unscaled
	blendedNormal = mix(blendedNormal, texture2D(normalHeightTexture10, uv).rgb, blendWeight);
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture10, uv), blendWeight);
#endif // if NUM_LAYERS > 9
#if NUM_LAYERS > 10
	uv = texCoord * scales[2][2];
	displacement = texture2D(normalHeightTexture11, uv).a * scaleBias.x + scaleBias.y;
	uv += cameraDirTangentSpace * displacement;
	blendWeight = texture2D(blendMap3, texCoord).y;         // Need to use unscaled uv here since blend map = unscaled
	blendedNormal = mix(blendedNormal, texture2D(normalHeightTexture11, uv).rgb, blendWeight);
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture11, uv), blendWeight);
#endif // if NUM_LAYERS > 10

	blendedNormal = normalize(expand(blendedNormal));
	return diffuseColour;
}

#endif // if BASE_LAYER

#endif // if OFFSET_MAPPING

#if BASE_LAYER

vec4 splatting(in vec2 texCoord)
{
	vec4 diffuseColour;
	// Temporary variables used by each layer calculation
	vec2 uv;         // scaled texCoord
	float blendWeight;

	uv = texCoord * scales[0][0];
	diffuseColour = texture2D(baseTextureDiffuse, uv);

#if NUM_LAYERS > 1
	uv = texCoord * scales[0][1];
	blendWeight = texture2D(blendMap1, texCoord).w;         // Need to use unscaled uv here since blend map = unscaled
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture1, uv), blendWeight);
#endif // if NUM_LAYERS > 1
#if NUM_LAYERS > 2
	uv = texCoord * scales[0][2];
	blendWeight = texture2D(blendMap1, texCoord).x;         // Need to use unscaled uv here since blend map = unscaled
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture2, uv), blendWeight);
#endif // if NUM_LAYERS > 2
#if NUM_LAYERS > 3
	uv = texCoord * scales[0][3];
	blendWeight = texture2D(blendMap1, texCoord).y;         // Need to use unscaled uv here since blend map = unscaled
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture3, uv), blendWeight);
#endif // if NUM_LAYERS > 3
#if NUM_LAYERS > 4
	uv = texCoord * scales[1][0];
	blendWeight = texture2D(blendMap1, texCoord).z;         // Need to use unscaled uv here since blend map = unscaled
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture4, uv), blendWeight);
#endif // if NUM_LAYERS > 4
#if NUM_LAYERS > 5
	uv = texCoord * scales[1][1];
	blendWeight = texture2D(blendMap2, texCoord).w;         // Need to use unscaled uv here since blend map = unscaled
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture5, uv), blendWeight);
#endif // if NUM_LAYERS > 5
#if NUM_LAYERS > 6
	uv = texCoord * scales[1][2];
	blendWeight = texture2D(blendMap2, texCoord).x;         // Need to use unscaled uv here since blend map = unscaled
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture6, uv), blendWeight);
#endif // if NUM_LAYERS > 6
#if NUM_LAYERS > 7
	uv = texCoord * scales[1][3];
	blendWeight = texture2D(blendMap2, texCoord).y;         // Need to use unscaled uv here since blend map = unscaled
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture7, uv), blendWeight);
#endif // if NUM_LAYERS > 7
#if NUM_LAYERS > 8
	uv = texCoord * scales[2][0];
	blendWeight = texture2D(blendMap2, texCoord).z;         // Need to use unscaled uv here since blend map = unscaled
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture8, uv), blendWeight);
#endif // if NUM_LAYERS > 8
#if NUM_LAYERS > 9
	uv = texCoord * scales[2][1];
	blendWeight = texture2D(blendMap3, texCoord).w;         // Need to use unscaled uv here since blend map = unscaled
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture9, uv), blendWeight);
#endif // if NUM_LAYERS > 9
#if NUM_LAYERS > 10
	uv = texCoord * scales[2][2];
	blendWeight = texture2D(blendMap3, texCoord).x;         // Need to use unscaled uv here since blend map = unscaled
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture10, uv), blendWeight);
#endif // if NUM_LAYERS > 10
#if NUM_LAYERS > 11
	uv = texCoord * scales[2][3];
	blendWeight = texture2D(blendMap3, texCoord).y;         // Need to use unscaled uv here since blend map = unscaled
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture11, uv), blendWeight);
#endif // if NUM_LAYERS > 11

	return diffuseColour;
}

#else //if !BASE_LAYER

vec4 splatting(in vec2 texCoord)
{
	vec4 diffuseColour;
	// Temporary variables used by each layer calculation
	vec2 uv;         // scaled texCoord
	float blendWeight;

	uv = texCoord * scales[0][0];
	blendWeight = texture2D(blendMap1, texCoord).w;         // Need to use unscaled uv here since blend map = unscaled
	diffuseColour = texture2D(diffuseTexture1, uv) * blendWeight;
#if NUM_LAYERS > 1
	uv = texCoord * scales[0][1];
	blendWeight = texture2D(blendMap1, texCoord).x;         // Need to use unscaled uv here since blend map = unscaled
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture2, uv), blendWeight);
#endif // if NUM_LAYERS > 1
#if NUM_LAYERS > 2
	uv = texCoord * scales[0][2];
	blendWeight = texture2D(blendMap1, texCoord).y;         // Need to use unscaled uv here since blend map = unscaled
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture3, uv), blendWeight);
#endif // if NUM_LAYERS > 2
#if NUM_LAYERS > 3
	uv = texCoord * scales[0][3];
	blendWeight = texture2D(blendMap1, texCoord).z;         // Need to use unscaled uv here since blend map = unscaled
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture4, uv), blendWeight);
#endif // if NUM_LAYERS > 3
#if NUM_LAYERS > 4
	uv = texCoord * scales[1][0];
	blendWeight = texture2D(blendMap2, texCoord).w;         // Need to use unscaled uv here since blend map = unscaled
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture5, uv), blendWeight);
#endif // if NUM_LAYERS > 4
#if NUM_LAYERS > 5
	uv = texCoord * scales[1][1];
	blendWeight = texture2D(blendMap2, texCoord).x;         // Need to use unscaled uv here since blend map = unscaled
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture6, uv), blendWeight);
#endif // if NUM_LAYERS > 5
#if NUM_LAYERS > 6
	uv = texCoord * scales[1][2];
	blendWeight = texture2D(blendMap2, texCoord).y;         // Need to use unscaled uv here since blend map = unscaled
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture7, uv), blendWeight);
#endif // if NUM_LAYERS > 6
#if NUM_LAYERS > 7
	uv = texCoord * scales[1][3];
	blendWeight = texture2D(blendMap2, texCoord).z;         // Need to use unscaled uv here since blend map = unscaled
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture8, uv), blendWeight);
#endif // if NUM_LAYERS > 7
#if NUM_LAYERS > 8
	uv = texCoord * scales[2][0];
	blendWeight = texture2D(blendMap3, texCoord).w;         // Need to use unscaled uv here since blend map = unscaled
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture9, uv), blendWeight);
#endif // if NUM_LAYERS > 8
#if NUM_LAYERS > 9
	uv = texCoord * scales[2][1];
	blendWeight = texture2D(blendMap3, texCoord).x;         // Need to use unscaled uv here since blend map = unscaled
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture10, uv), blendWeight);
#endif // if NUM_LAYERS > 9
#if NUM_LAYERS > 10
	uv = texCoord * scales[2][2];
	blendWeight = texture2D(blendMap3, texCoord).y;         // Need to use unscaled uv here since blend map = unscaled
	diffuseColour = mix(diffuseColour, texture2D(diffuseTexture11, uv), blendWeight);
#endif // if NUM_LAYERS > 10

	return diffuseColour;
}


#endif // if BASE_LAYER

#endif // if NUM_LAYERS > 0


#if NUM_LIGHTS > 0
void lighting(in gl_LightSourceParameters light,
			  in vec3 normal,                         // in object space
			  in float shadowing,
			  in float attenuation,
			  inout vec4 diffuse)
{
	
	//Due to a bug in Ogre which seems to not reset state between scene managers we can't use the "object space light position" auto const.
	//We instead need to translate the light position into object space for each fragment. 

	// Compute vector from surface to light position
	vec3 lightDir = normalize((vec4(light.position.xyz, 1.0) * gl_ModelViewMatrix).xyz - positionObjSpace * light.position.w);
	float NdotL = max(0.0, dot(normal, lightDir));
	
	diffuse += light.diffuse * NdotL * attenuation * shadowing;
}
#endif // if NUM_LIGHTS > 0

#if SHADOW

float shadowPCF(in sampler2D shadowMap, in vec4 shadowTexCoord, vec2 inverseShadowMapSize)
{
	// point on shadowmap
#if LINEAR_RANGE
	shadowTexCoord.xy = shadowTexCoord.xy / shadowTexCoord.w;
#else
	shadowTexCoord = shadowTexCoord / shadowTexCoord.w;
#endif // if LINEAR_RANGE

#if !PCF
	float depth = texture2D(shadowMap, shadowTexCoord.xy).x * (1.0 - fixedDepthBias);
	return (depth > shadowTexCoord.z) ? 1.0 : 0.0;
#else

	// Do not shade too far away objects
	if (abs(shadowTexCoord.z) > 1.0) {
		return 1.0;
	}

	float centerdepth = texture2D(shadowMap, shadowTexCoord.xy).x;

	// gradient calculation
	float pixeloffset = inverseShadowMapSize.x;
	vec4 depths = vec4(
		texture2D(shadowMap, shadowTexCoord.xy + vec2(-pixeloffset, 0)).x,
		texture2D(shadowMap, shadowTexCoord.xy + vec2(+pixeloffset, 0)).x,
		texture2D(shadowMap, shadowTexCoord.xy + vec2(0, -pixeloffset)).x,
		texture2D(shadowMap, shadowTexCoord.xy + vec2(0, +pixeloffset)).x);

	vec2 differences = abs(depths.yw - depths.xz);
	float gradient = min(gradientClamp, max(differences.x, differences.y));
	float gradientFactor = gradient * gradientScaleBias;

	// visibility function
	float depthAdjust = gradientFactor - (fixedDepthBias * centerdepth);
	// depthAdjust =  -fixedDepthBias * centerdepth;
	float finalCenterDepth = centerdepth + depthAdjust;

	// use depths from prev, calculate diff
	depths += depthAdjust;
	float final = (finalCenterDepth > shadowTexCoord.z) ? 1.0 : 0.0;
	final += (depths.x > shadowTexCoord.z) ? 1.0 : 0.0;
	final += (depths.y > shadowTexCoord.z) ? 1.0 : 0.0;
	final += (depths.z > shadowTexCoord.z) ? 1.0 : 0.0;
	final += (depths.w > shadowTexCoord.z) ? 1.0 : 0.0;
	final *= 0.2;

	return final;
#endif // if !PCF
}

float shadowPSSM()
{
	float depth = gl_TexCoord[0].p;
	float shadowing = 0.0;

	if (depth <= pssmSplitPoints.y) {
		shadowing = shadowPCF(shadowMap0, shadowTexCoord0, inverseShadowMapSize0.xy);
	} else if (depth <= pssmSplitPoints.z) {
		shadowing = shadowPCF(shadowMap1, shadowTexCoord1, inverseShadowMapSize1.xy);
	} else {
		shadowing = shadowPCF(shadowMap2, shadowTexCoord2, inverseShadowMapSize2.xy);
	}

	return shadowing;
}

vec3 shadowPSSMDebug()
{
	float depth = gl_TexCoord[0].p;
	float shadowing = 0.0;
	vec3 splitColour;
	float showLayer = 0.0;

	if (depth <= pssmSplitPoints.y && showLayer == 0.0 || showLayer == 1.0) {
		splitColour = vec3(1.0, 0.0, 0.0);
		shadowing = shadowPCF(shadowMap0, shadowTexCoord0, inverseShadowMapSize0.xy);
	} else if (depth <= pssmSplitPoints.z && showLayer == 0.0 || showLayer == 2.0) {
		splitColour = vec3(0.0, 1.0, 0.0);
		shadowing = shadowPCF(shadowMap1, shadowTexCoord1, inverseShadowMapSize1.xy);
	} else {
		splitColour = vec3(0.0, 0.0, 1.0);
		shadowing = shadowPCF(shadowMap2, shadowTexCoord2, inverseShadowMapSize2.xy);
	}

	return vec3(1.0) - (vec3(1.0) - splitColour) * (1.0 - shadowing);
}

vec3 shadow3Debug()
{
	float shadowing1, shadowing2, shadowing3;

	shadowing1 = shadowPCF(shadowMap0, shadowTexCoord0, inverseShadowMapSize0.xy);
	shadowing2 = shadowPCF(shadowMap1, shadowTexCoord1, inverseShadowMapSize1.xy);
	shadowing3 = shadowPCF(shadowMap2, shadowTexCoord2, inverseShadowMapSize2.xy);

	return vec3(1.0) - ((1.0 - shadowing1) * (1.0 - vec3(1.0, 0.0, 0.0)) +
						(1.0 - shadowing2) * (1.0 - vec3(0.0, 1.0, 0.0)) +
						(1.0 - shadowing3) * (1.0 - vec3(0.0, 0.0, 1.0)));
}

#endif // if SHADOW

void main()
{
	vec2 uv = gl_TexCoord[0].st;

#if NUM_LIGHTS > 0
	// get the normal from the normal texture
	vec3 normal = normalize(expand(texture2D(normalTexture, uv).rgb));
#endif
	vec4 diffuseColour;

#if OFFSET_MAPPING
	vec3 blendedNormalTangentSpace;
	float cameraDistance = distance(cameraPositionObjSpace, positionObjSpace);
	if (cameraDistance < OFFSET_MAPPING_DISTANCE) {
		// Offset mapping code based heavily on Ogre TerrainMaterialGeneratorA

		// derive the tangent space basis
		// For Ember, the tangent is always +x because the terrain is aligned to X_Z and we work in object space
		vec3 tangent = vec3(1, 0, 0);
		vec3 binormal;
		// we do this in the pixel shader because we don't have per-vertex normals
		// because of the LOD, we use a normal map
		binormal = normalize(cross(tangent, normal));
		// note, now we need to re-cross to derive tangent again because it wasn't orthonormal
		tangent = normalize(cross(normal, binormal));
		mat3 TBN;
		// derive final matrix
		TBN = mat3(tangent, binormal, normal);

		vec3 cameraDirectionTangentSpace = normalize(transpose(TBN) * (cameraPositionObjSpace - positionObjSpace));

		// Blends all the diffuse colors and normals
		diffuseColour = splatting_offset_mapping(uv, cameraDirectionTangentSpace.xy, blendedNormalTangentSpace);
		normal = normalize(TBN * blendedNormalTangentSpace);
	} else {
		diffuseColour = splatting(uv);
	}
#else
	diffuseColour = splatting(uv);
#endif // if OFFSET_MAPPING

	// If we're using shadows, we'll iterate through all of the lights and look up against the shadow textures etc.
	// If we're not however, we'll just use the first light (normally the sun) and make the whole lightning model much simpler.
	// Accumulates diffuse light colour
	vec4 diffuse = vec4(0.0);

#if NUM_LIGHTS > 0
	// Loop through lights, compute contribution from each
	for (int i = 0; i < NUM_LIGHTS && i < int(numberOfActiveLights); i++) {
		float shadowing = 1.0;
		gl_LightSourceParameters light = gl_LightSource[i];

#if SHADOW
		// Use PSSM only for first directional light
		if (light.position.w == 0.0) {
			if (i == 0) {
				shadowing = shadowPSSM();
			} else if (i == 1) {
				shadowing = shadowPCF(shadowMap3, shadowTexCoord3, inverseShadowMapSize3.xy);
			} else if (i == 2) {
				shadowing = shadowPCF(shadowMap4, shadowTexCoord4, inverseShadowMapSize4.xy);
			}
		} else {
			if (i == 0) {
				shadowing = shadowPCF(shadowMap0, shadowTexCoord0, inverseShadowMapSize0.xy);
			} else if (i == 1) {
				shadowing = shadowPCF(shadowMap1, shadowTexCoord1, inverseShadowMapSize1.xy);
			} else if (i == 2) {
				shadowing = shadowPCF(shadowMap2, shadowTexCoord2, inverseShadowMapSize2.xy);
			}
		}
#endif // if SHADOW

		lighting(light, normal, shadowing, attenuation[i], diffuse);
	}

	vec3 colour = vec3(gl_LightModel.ambient * diffuseColour +
					   diffuseColour * diffuse)
	              ///1000.0 + shadowPSSMDebug()
	              ///1000.0 + shadow3Debug()
	;
#else
    // Should we take ambient into account if NUM_LIGHTS == 0?
    vec3 colour = diffuseColour.rgb;
#endif // if NUM_LIGHTS > 0
// For debugging: Show the a offset mapping range indicator
//#if OFFSET_MAPPING
//	if (cameraDistance < OFFSET_MAPPING_DISTANCE + 1.0 && cameraDistance > OFFSET_MAPPING_DISTANCE - 1.0f) {
//        colour = vec3(1, 0, 0);
//    }
//#endif

	// gl_FragColor.rgb = N;
	// gl_FragColor.rgb = blendedNormalTangentSpace;

#if BASE_LAYER
	gl_FragColor.a = 1.0;
#else
	gl_FragColor.a = diffuseColour.a;
#endif


#if FOG
if (disableFogColour == 1) {
	gl_FragColor.rgb = colour * fog;
} else {
	gl_FragColor.rgb = mix(gl_Fog.color.rgb, colour, fog);
}
#else
	gl_FragColor.rgb = colour;
#endif // if FOG

}
