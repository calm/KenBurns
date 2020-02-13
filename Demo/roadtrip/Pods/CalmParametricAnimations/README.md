# CalmParametricAnimations

A nice iOS extension that gives `CAKeyframeAnimation` support for all of the complex easing curves found at http://easings.net

## Installation

Add `pod 'CalmParametricAnimations'` to your `Podfile` or download the source [here](https://github.com/calm/CalmParametricAnimations)

## Curves

`CalmParametricAnimations` supports the following curves (type `ParametricTimeBlock`):

```
typedef double (^ParametricTimeBlock)(double time)

sineIn
sineOut
sineInOut
squashedSineInOut

linear

appleIn
appleOut
appleInOut

backIn
backOut
backInOut
easeInBackOut
easeOutDramatic

quadraticIn
quadraticOut

cubicIn
cubicOut
cubicInOut

circularIn
circularOut

expoIn
expoOut
expoInOut

elasticIn
elasticOut

variableElasticOut (intensity) -> ParametricTimeBlock
bezierEvaluator (time, point1, point2) -> ParametricTimeBlock
arc (radius, center) -> ParametricTimeBlock
```

These can the be evaluated directly as functions passing `double` time from 0 - 1, or by using one of the "value blocks" we’ve defined:

```
double
point
size
rect
color
transform3D
```

Each of these value blocks has a corresponding extension method on CAKeyframeAnimation that allows passing of the key-path, the time function. For example:

```
+ (instancetype)animationWithKeyPath:(NSString *)path
                             timeFxn:(ParametricTimeBlock)timeFxn
                            fromRect:(CGRect)fromValue
                              toRect:(CGRect)toValue;
```

which will producte an animation that interpolates between the two rects according to the easing curve, with the duration set after initialization.