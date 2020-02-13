#import "CalmParametricBlocks.h"

@implementation CalmParametricBlocks

#pragma mark - bezier helpers

double bezier(double time, double A, double B, double C) {
    return time * (C + time * (B + time * A)); //A t^3 + B t^2 + C t
}

double bezier_der(double time, double A, double B, double C) {
    return C + time * (2 * B + time * 3 * A); //3 A t^2 + 2 B t + C
}

double xForTime(double time, double ctx1, double ctx2) {
    double x = time, z;

    double C = 3 * ctx1;
    double B = 3 * (ctx2 - ctx1) - C;
    double A = 1 - C - B;

    NSInteger i = 0;
    while (i < 5) {
        z = bezier(x, A, B, C) - time;
        if (fabs(z) < 0.001) {
            break;
        }

        x = x - z / bezier_der(x, A, B, C);
        i++;
    }

    return x;
}

const double (^kParametricAnimationBezierEvaluator)(double, CGPoint, CGPoint) = ^(double time, CGPoint ct1, CGPoint ct2) {
    double Cy = 3 * ct1.y;
    double By = 3 * (ct2.y - ct1.y) - Cy;
    double Ay = 1 - Cy - By;

    return bezier(xForTime(time, ct1.x, ct2.x), Ay, By, Cy);
};


#pragma mark - time blocks

const ParametricTimeBlock kParametricTimeBlockLinear = ^(double time) {
    return time;
};

const ParametricTimeBlock kParametricTimeBlockAppleIn = ^(double time) {
    CGPoint ct1 = CGPointMake(0.42, 0.0), ct2 = CGPointMake(1.0, 1.0);
    return kParametricAnimationBezierEvaluator(time, ct1, ct2);
};
const ParametricTimeBlock kParametricTimeBlockAppleOut = ^(double time) {
    CGPoint ct1 = CGPointMake(0.0, 0.0), ct2 = CGPointMake(0.58, 1.0);
    return kParametricAnimationBezierEvaluator(time, ct1, ct2);
};

const ParametricTimeBlock kParametricTimeBlockAppleInOut = ^(double time) {
    CGPoint ct1 = CGPointMake(0.42, 0.0), ct2 = CGPointMake(0.58, 1.0);
    return kParametricAnimationBezierEvaluator(time, ct1, ct2);
};

const ParametricTimeBlock kParametricTimeBlockEaseOutDramatic = ^(double time) {
    CGPoint ct1 = CGPointMake(0.2, 0.7), ct2 = CGPointMake(0.2, 1.0);
    return kParametricAnimationBezierEvaluator(time, ct1, ct2);
};

const ParametricTimeBlock kParametricTimeBlockBackIn = ^(double time) {
    CGPoint ct1 = CGPointMake(0.6, -0.28), ct2 = CGPointMake(0.735, 0.045);
    return kParametricAnimationBezierEvaluator(time, ct1, ct2);
};

const ParametricTimeBlock kParametricTimeBlockEaseInBackOut = ^(double time) {
    CGPoint ct1 = CGPointMake(0.43, 0.095), ct2 = CGPointMake(0.375, 1.23);
    return kParametricAnimationBezierEvaluator(time, ct1, ct2);
};

const ParametricTimeBlock kParametricTimeBlockBackOut = ^(double time) {
    CGPoint ct1 = CGPointMake(0.175, 0.885), ct2 = CGPointMake(0.32, 1.275);
    return kParametricAnimationBezierEvaluator(time, ct1, ct2);
};

const ParametricTimeBlock kParametricTimeBlockBackInOut = ^(double time) {
    CGPoint ct1 = CGPointMake(0.68, -0.55), ct2 = CGPointMake(0.265, 1.55);
    return kParametricAnimationBezierEvaluator(time, ct1, ct2);
};

const ParametricTimeBlock kParametricTimeBlockQuadraticIn = ^(double time) {
    return pow(time, 2);
};

const ParametricTimeBlock kParametricTimeBlockQuadraticOut = ^(double time) {
    return 1 - pow(1 - time, 2);
};

const ParametricTimeBlock kParametricTimeBlockCubicIn = ^(double time) {
    return pow(time, 3);
};

const ParametricTimeBlock kParametricTimeBlockCubicOut = ^(double time) {
    return pow(time, 3);
};

const ParametricTimeBlock kParametricTimeBlockCubicInOut = ^(double time) {
    time *= 2.0;
    if (time < 1) {
        return 0.5 * pow(time, 3);
    }

    time -= 2;
    return 0.5 * pow(time, 3) + 1;
};

const ParametricTimeBlock kParametricTimeBlockExpoIn = ^(double time) {
    if (time == 0.0) {
        return 0.0;
    }
    return pow(2, 10 * (time - 1));
};

const ParametricTimeBlock kParametricTimeBlockExpoOut = ^(double time) {
    if (time == 1.0) {
        return 1.0;
    }
    return -pow(2, -10 * time) + 1;
};

const ParametricTimeBlock kParametricTimeBlockExpoInOut = ^(double time) {
    if (time == 0) {
        return 0.0;
    }
    if (time == 1) {
        return 1.0;
    }
    time *= 2;
    if (time < 1) {
        return 0.5 * pow(2, 10 * (time - 1));
    }
    --time;
    return 0.5 * (-pow(2, -10 * time) + 2);
};

const ParametricTimeBlock kParametricTimeBlockCircularIn = ^(double time) {
    return 1 - sqrt(1 - time * time);
};

const ParametricTimeBlock kParametricTimeBlockCircularOut = ^(double time) {
    return sqrt(1 - pow(time - 1, 2));
};

const ParametricTimeBlock kParametricTimeBlockSineIn = ^(double time) {
    return -cos(time * M_PI / 2) + 1;
};

const ParametricTimeBlock kParametricTimeBlockSineOut = ^(double time) {
    return -cos(time * M_PI / 2) + 1;
};

const ParametricTimeBlock kParametricTimeBlockSineInOut = ^(double time) {
    return -0.5 * cos(time * M_PI) + 0.5;
};

const ParametricTimeBlock kParametricTimeBlockSquashedSineInOut = ^(double time) {
    double squashFactor = 0.75;
    return squashFactor * (-0.5 * cos(time * M_PI) + 0.5) + 0.5 * squashFactor;
};

#define kDefaultElasticPeriod 0.3
#define kMutedElasticPeriod 0.5
#define kDefaultElasticAmplitude 1.0
#define kDefaultElasticShiftRatio 0.25
const ParametricTimeBlock kParametricTimeBlockElasticIn = ^(double time) {
    if (time <= 0.0) {
        return 0.0;
    }
    if (time >= 1.0) {
        return 1.0;
    }
    double period = kDefaultElasticPeriod;
    double amplitude = kDefaultElasticAmplitude;
    double shift = period * kDefaultElasticShiftRatio;

    double result = -amplitude * pow(2, 10 * (time - 1)) * // amplitude growth
    sin((time - 1 - shift) * 2 * M_PI / period);

    return result;
};

const ParametricTimeBlock kParametricTimeBlockElasticOut = ^(double time) {
    return kParametricTimeBlockVariableElasticOut(kDefaultElasticPeriod)(time);
};

const ParametricTimeBlock (^kParametricTimeBlockVariableElasticOut)(double) = ^(double inverseIntensity) {
    ParametricTimeBlock elasticOut = ^(double time) {
        if (time <= 0.0) {
            return 0.0;
        }
        if (time >= 1.0) {
            return 1.0;
        }
        double period = inverseIntensity;
        double amplitude = kDefaultElasticAmplitude;
        double shift = period * kDefaultElasticShiftRatio;

        double result = amplitude * pow(2, -10 * time) * // amplitude decay
        sin((time - shift) * 2 * M_PI / period) + 1;

        return result;
    };
    return elasticOut;
};

+ (ParametricTimeBlock)elasticParametricTimeBlockWithEaseIn:(BOOL)easeIn
                                                     period:(double)period
                                                  amplitude:(double)amplitude
{
    return [self elasticParametricTimeBlockWithEaseIn:easeIn
                                               period:period
                                            amplitude:amplitude
                                        andShiftRatio:kDefaultElasticShiftRatio];
}

+ (ParametricTimeBlock)elasticParametricTimeBlockWithEaseIn:(BOOL)easeIn
                                                     period:(double)period
                                                  amplitude:(double)amplitude
                                                    bounded:(BOOL)bounded
{
    return [self elasticParametricTimeBlockWithEaseIn:easeIn
                                               period:period
                                            amplitude:amplitude
                                        andShiftRatio:kDefaultElasticShiftRatio
                                              bounded:bounded];
}

+ (ParametricTimeBlock)elasticParametricTimeBlockWithEaseIn:(BOOL)easeIn
                                                     period:(double)period
                                                  amplitude:(double)amplitude
                                              andShiftRatio:(double)shiftRatio
{
    return [self elasticParametricTimeBlockWithEaseIn:easeIn
                                               period:period
                                            amplitude:amplitude
                                        andShiftRatio:shiftRatio
                                              bounded:NO];
}

+ (ParametricTimeBlock)elasticParametricTimeBlockWithEaseIn:(BOOL)easeIn
                                                     period:(double)period
                                                  amplitude:(double)amplitude
                                              andShiftRatio:(double)shiftRatio
                                                    bounded:(BOOL)bounded
{
    ParametricTimeBlock elasticBlock = ^(double time) {
        if (time <= 0) {
            return 0.0;
        }
        if (time >= 1) {
            return 1.0;
        }
        double shift = period * shiftRatio;

        double result;
        if (easeIn) { // amplitude growth
            result = -amplitude * pow(2, 10 * (time - 1)) * sin((time - 1 - shift) * 2 * M_PI / period);
        } else { // amplitude decay
            result = amplitude * pow(2, -10 * time) * sin((time - shift) * 2 * M_PI / period) + 1;
        }

        return bounded ? MAX(0.0, MIN(1.0, result)) : result;
    };

    return [elasticBlock copy];
}


#pragma mark - value blocks

const ParametricValueBlock kParametricValueBlockDouble = ^(double progress, id fromValue, id toValue) {
    NSValue *value;
    double from, to;
    [fromValue getValue:&from];
    [toValue getValue:&to];
    value = @(from + (to - from) * progress);
    return value;
};

const ParametricValueBlock kParametricValueBlockPoint = ^(double progress, id fromValue, id toValue) {
    NSValue *value;
    CGPoint from, to;
    [fromValue getValue:&from];
    [toValue getValue:&to];
    value = [NSValue valueWithCGPoint:CGPointMake((from.x + (to.x - from.x) * progress), (from.y + (to.y - from.y) * progress))];
    return value;
};

const ParametricValueBlock kParametricValueBlockSize = ^(double progress, id fromValue, id toValue) {
    NSValue *value;
    CGSize from, to;
    [fromValue getValue:&from];
    [toValue getValue:&to];
    value = [NSValue valueWithCGSize:CGSizeMake((from.width + (to.width - from.width) * progress), (from.height + (to.height - from.height) * progress))];
    return value;
};

const ParametricValueBlock kParametricValueBlockRect = ^(double progress, id fromValue, id toValue) {
    NSValue *value;
    CGRect from, to;
    [fromValue getValue:&from];
    [toValue getValue:&to];

    NSValue *fromOrigin = [NSValue valueWithCGPoint:from.origin];
    NSValue *toOrigin = [NSValue valueWithCGPoint:to.origin];
    NSValue *fromSize = [NSValue valueWithCGSize:from.size];
    NSValue *toSize = [NSValue valueWithCGSize:to.size];

    CGPoint origin;
    CGSize size;
    [kParametricValueBlockPoint(progress, fromOrigin, toOrigin) getValue:&origin];
    [kParametricValueBlockSize(progress, fromSize, toSize) getValue:&size];

    value = [NSValue valueWithCGRect:CGRectMake(origin.x, origin.y, size.width, size.height)];
    return value;
};

const ParametricValueBlock kParametricValueBlockTransform3D = ^(double progress, id fromValue, id toValue) {
    CATransform3D from, to;
    [fromValue getValue:&from];
    [toValue getValue:&to];

    CGFloat m11, m12, m13, m14;
    CGFloat m21, m22, m23, m24;
    CGFloat m31, m32, m33, m34;
    CGFloat m41, m42, m43, m44;
    m11 = from.m11 + progress * (to.m11 - from.m11);
    m12 = from.m12 + progress * (to.m12 - from.m12);
    m13 = from.m13 + progress * (to.m13 - from.m13);
    m14 = from.m14 + progress * (to.m14 - from.m14);
    m21 = from.m21 + progress * (to.m21 - from.m21);
    m22 = from.m22 + progress * (to.m22 - from.m22);
    m23 = from.m23 + progress * (to.m23 - from.m23);
    m24 = from.m24 + progress * (to.m24 - from.m24);
    m31 = from.m31 + progress * (to.m31 - from.m31);
    m32 = from.m32 + progress * (to.m32 - from.m32);
    m33 = from.m33 + progress * (to.m33 - from.m33);
    m34 = from.m34 + progress * (to.m34 - from.m34);
    m41 = from.m41 + progress * (to.m41 - from.m41);
    m42 = from.m42 + progress * (to.m42 - from.m42);
    m43 = from.m43 + progress * (to.m43 - from.m43);
    m44 = from.m44 + progress * (to.m44 - from.m44);

    CATransform3D final = CATransform3DIdentity;
    final.m11 = m11;
    final.m12 = m12;
    final.m13 = m13;
    final.m14 = m14;
    final.m21 = m21;
    final.m22 = m22;
    final.m23 = m23;
    final.m24 = m24;
    final.m31 = m31;
    final.m32 = m32;
    final.m33 = m33;
    final.m34 = m34;
    final.m41 = m41;
    final.m42 = m42;
    final.m43 = m43;
    final.m44 = m44;

    return [NSValue valueWithCATransform3D:final];
};

const ParametricValueBlock kParametricValueBlockColor = ^(double progress, id fromValue, id toValue) {
    id value = nil;
    CGColorRef from = (__bridge CGColorRef)fromValue;
    CGColorRef to = (__bridge CGColorRef)toValue;

    const CGFloat *fromComponents = CGColorGetComponents(from);
    const CGFloat *toComponents = CGColorGetComponents(to);

    CGFloat fromAlpha, toAlpha, r, g, b, a;
    fromAlpha = CGColorGetAlpha(from);
    toAlpha = CGColorGetAlpha(to);

    r = fromComponents[0] + (toComponents[0] - fromComponents[0]) * progress;
    g = fromComponents[1] + (toComponents[1] - fromComponents[1]) * progress;
    b = fromComponents[2] + (toComponents[2] - fromComponents[2]) * progress;
    a = fromAlpha + (toAlpha - fromAlpha) * progress;

    value = (id)[UIColor colorWithRed:r
                                green:g
                                 blue:b
                                alpha:a].CGColor;
    return value;
};

+ (ParametricValueBlock)arcPathParametricValueBlockWithRadius:(CGFloat)radius
                                                    andCenter:(CGPoint)center
{
    const ParametricValueBlock arcAnimationHelperBlock = ^(double progress, id fromAngle, id toAngle) {
        NSValue *value;
        CGFloat start, end;
        [fromAngle getValue:&start];
        [toAngle getValue:&end];

        CGFloat angle = start + progress * (end - start);
        value = [NSValue valueWithCGPoint:CGPointMake(center.x + radius * sinf(angle), center.y + radius * cosf(angle))];
        
        return value;
    };
    
    return [arcAnimationHelperBlock copy];
}

@end