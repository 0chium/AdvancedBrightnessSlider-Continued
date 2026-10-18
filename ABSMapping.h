// AdvancedBrightnessSlider mapping, derived from Jonas Schiefner's ABSManager.
// Distributed under the project's GPL-3.0 license; see LICENSE.
#ifndef ABS_MAPPING_H
#define ABS_MAPPING_H

#include <math.h>
#include <stdbool.h>

static inline bool ABSValidThreshold(float threshold) {
    return isfinite(threshold) && threshold > 0.f && threshold < 1.f;
}

static inline float ABSClamp(float value) {
    return fminf(1.f, fmaxf(0.f, value));
}

static inline bool ABSMapPosition(float position, float threshold,
                                  float *brightness, double *intensity, bool *whitePoint) {
    if (!isfinite(position) || !ABSValidThreshold(threshold)) return false;
    position = ABSClamp(position);
    *whitePoint = position < threshold;
    *brightness = *whitePoint ? 0.f : (position - threshold) / (1.f - threshold);
    *intensity = *whitePoint ? 1.0 - 0.75 * position / threshold : 0.25;
    return true;
}

static inline bool ABSInversePosition(float brightness, bool whitePoint, double intensity,
                                      float threshold, float *position) {
    if (!isfinite(brightness) || !ABSValidThreshold(threshold)) return false;
    brightness = ABSClamp(brightness);
    // An external non-minimum brightness + White Point combination has no exact
    // inverse. Represent physical brightness in the upper section; never fix it
    // by writing system settings. Allow small brightness readback quantization.
    if (whitePoint && brightness <= 0.0001f && isfinite(intensity)
        && intensity >= 0.25 && intensity <= 1.0) {
        *position = (float)(threshold * (1.0 - intensity) / 0.75);
    } else {
        *position = threshold + (1.f - threshold) * brightness;
    }
    return true;
}

#endif
