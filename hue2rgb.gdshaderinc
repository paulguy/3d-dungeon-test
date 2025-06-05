vec3 hue2rgb(float c_hue, float c_bias) {
	// in theory, each color starts at 1.0, then a notch is cut out
	// W     R     Y     G     C     B     M
	// 0.00  0.16  0.33  0.49  0.67  0.84  1.00
	// _|_  _|_   _|     |     |     |    _|_
	//  |    |     |  \ _|_   _|_   _|_ /  |

	// |_    |    _|_   _|_   _|_    |     |
	// |  \ _|_ /  |     |     |  \ _|_   _|_

	// |_    |     |     |    _|_   _|_   _|_
	// |  \ _|_   _|_   _|_ /  |     |     |

	// bias below 1.0 should darken, bias above 1.0 should "desaturate"
	return vec3(1.0 - (((clamp(c_hue, 0.33, 0.49) - 0.33) - (max(c_hue, 0.84) - 0.84)) / 0.16),
				1.0 - ((min(c_hue, 0.16) - (clamp(c_hue, 0.16, 0.32) - 0.16)) / 0.16) - ((clamp(c_hue, 0.67, 0.83) - 0.67) / 0.16),
				1.0 - ((min(c_hue, 0.16) - (clamp(c_hue, 0.49, 0.67) - 0.49)) / 0.16)) * max(c_bias, 1.0);
}
