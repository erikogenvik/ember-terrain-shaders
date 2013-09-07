#if ALPHA
// Diffuse texture
uniform sampler2D diffuseMap;

varying vec2 uv;
#endif

varying vec2 depth;

void main()
{
#if ALPHA
	if (texture2D(diffuseMap, uv).a < 0.5)
	{
		discard;
	}
#endif

#if LINEAR_RANGE
	float finalDepth = depth.x;
#else
	float finalDepth = depth.x / depth.y;
#endif
	// just smear across all components
	// therefore this one needs high individual channel precision
	gl_FragColor = vec4(finalDepth, finalDepth, finalDepth, 1.0);
}

