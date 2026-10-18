// Focused host-side checks of the actual portable mapping header, not an iOS test.
#include "../ABSMapping.h"
#include <assert.h>
#include <stdio.h>

int main(void) {
    const float thresholds[] = {0.1f, 0.3f, 0.9f};
    unsigned cases = 0;
    for (unsigned t = 0; t < sizeof(thresholds) / sizeof(thresholds[0]); ++t) {
        float threshold = thresholds[t];
        const float boundaries[] = {0.f, nextafterf(threshold, 0.f), threshold,
                                    nextafterf(threshold, 1.f), 1.f};
        for (unsigned j = 0; j < 10006; ++j) {
            float p = j < 5 ? boundaries[j] : (j - 5) / 10000.f;
            float b, inverse;
            double intensity;
            bool wp;
            assert(ABSMapPosition(p, threshold, &b, &intensity, &wp));
            assert(b >= 0.f && b <= 1.f && intensity >= 0.25 && intensity <= 1.0);
            assert(wp == (p < threshold));
            if (wp) assert(b == 0.f);
            assert(ABSInversePosition(b, wp, intensity, threshold, &inverse));
            assert(fabsf(p - inverse) < 0.000001f);
            ++cases;
        }
    }
    const float invalid[] = {NAN, INFINITY, -INFINITY, -1.f, 0.f, 1.f, 2.f};
    for (unsigned i = 0; i < sizeof(invalid) / sizeof(invalid[0]); ++i) {
        float b = 42.f, p = 42.f;
        double intensity = 42.;
        bool wp = true;
        assert(!ABSValidThreshold(invalid[i]));
        assert(!ABSMapPosition(0.5f, invalid[i], &b, &intensity, &wp));
        assert(b == 42.f && intensity == 42. && wp);
        assert(!ABSInversePosition(0.5f, false, 0.8, invalid[i], &p));
        assert(p == 42.f);
    }
    for (unsigned i = 0; i < 3; ++i) {
        float b = 42.f, p = 42.f;
        double intensity = 42.;
        bool wp = true;
        assert(!ABSMapPosition(invalid[i], 0.3f, &b, &intensity, &wp));
        assert(b == 42.f && intensity == 42. && wp);
        assert(!ABSInversePosition(invalid[i], false, 0.8, 0.3f, &p));
        assert(p == 42.f);
    }
    float b, p;
    double intensity;
    bool wp;
    assert(ABSMapPosition(-1.f, 0.3f, &b, &intensity, &wp) && b == 0 && wp && intensity == 1);
    assert(ABSMapPosition(2.f, 0.3f, &b, &intensity, &wp) && b == 1 && !wp);
    assert(ABSInversePosition(0.f, true, 1., 0.3f, &p) && p == 0.f);
    assert(ABSInversePosition(0.f, true, 0.25, 0.3f, &p) && p == 0.3f);
    // Outside the image of the mapping: represent ordinary brightness, do not repair settings.
    assert(ABSInversePosition(0.5f, true, 0.8, 0.3f, &p) && fabsf(p - 0.65f) < 0.000001f);
    assert(ABSInversePosition(0.f, true, NAN, 0.3f, &p) && p == 0.3f);
    assert(ABSInversePosition(0.f, true, 0.2, 0.3f, &p) && p == 0.3f);
    assert(ABSInversePosition(0.f, false, 0.8, 0.3f, &p) && p == 0.3f);
    assert(ABSValidThreshold(nextafterf(0.f, 1.f)));
    assert(ABSValidThreshold(nextafterf(1.f, 0.f)));
    printf("PASS %u mapped round trips, boundaries, invalid inputs, clamping, and external-state representation\n", cases);
    return 0;
}
