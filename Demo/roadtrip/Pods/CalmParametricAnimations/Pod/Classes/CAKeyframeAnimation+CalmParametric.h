#import <QuartzCore/QuartzCore.h>
#import "CalmParametricBlocks.h"

@interface CAKeyframeAnimation (CalmParametric)

#pragma mark - convenience constructors

/**
 * @return a CAKeyframeAnimation which animates a double between fromValue and toValue
 * @see animationWithKeyPath:timeFxn:valueFxn:fromValue:toValue:
 */
+ (instancetype)animationWithKeyPath:(NSString *)path
                             timeFxn:(ParametricTimeBlock)timeFxn
                          fromDouble:(double)fromValue
                            toDouble:(double)toValue;

/**
 * @return a CAKeyframeAnimation which animates a point between fromValue and toValue
 * @see animationWithKeyPath:timeFxn:valueFxn:fromValue:toValue:
 */
+ (instancetype)animationWithKeyPath:(NSString *)path
                             timeFxn:(ParametricTimeBlock)timeFxn
                           fromPoint:(CGPoint)fromValue
                             toPoint:(CGPoint)toValue;

/**
 * @return a CAKeyframeAnimation which animates a size between fromValue and toValue
 * @see animationWithKeyPath:timeFxn:valueFxn:fromValue:toValue:
 */
+ (instancetype)animationWithKeyPath:(NSString *)path
                             timeFxn:(ParametricTimeBlock)timeFxn
                            fromSize:(CGSize)fromValue
                              toSize:(CGSize)toValue;

/**
 * @return a CAKeyframeAnimation which animates a rect between fromValue and toValue
 * @see animationWithKeyPath:timeFxn:valueFxn:fromValue:toValue:
 */
+ (instancetype)animationWithKeyPath:(NSString *)path
                             timeFxn:(ParametricTimeBlock)timeFxn
                            fromRect:(CGRect)fromValue
                              toRect:(CGRect)toValue;

/**
 * @return a CAKeyframeAnimation which animates color between fromValue and toValue
 * @see animationWithKeyPath:timeFxn:valueFxn:fromValue:toValue:
 */
+ (instancetype)animationWithKeyPath:(NSString *)path
                             timeFxn:(ParametricTimeBlock)timeFxn
                           fromColor:(CGColorRef)fromValue
                             toColor:(CGColorRef)toValue;

/**
 * @return a CAKeyframeAnimation which animates transform between fromValue and toValue
 * @see animationWithKeyPath:timeFxn:valueFxn:fromValue:toValue:
 */
+ (instancetype)animationWithKeyPath:(NSString *)path
                             timeFxn:(ParametricTimeBlock)timeFxn
                       fromTransform:(CATransform3D)fromValue
                         toTransform:(CATransform3D)toValue;

/**
 * @param animations an array of CAKeyframeAnimations
 * @return a CAKeyframeAnimation which concatenates the animations passed in
 */
+ (instancetype)animationWithAnimations:(NSArray *)animations;


#pragma mark - generic core

/**
 * @param path the key path to animate
 * @param timeFxn the time block used to ease between fromValue and toValue
 * @param valueFxn the value block used to calculate values
 * @param fromValue a value object representing the initial value of the animation
 * @param toValue a value object representing the final value of the animation
 *
 * @return a CAKeyframeAnimation which animates from fromValue to toValue
 */
+ (instancetype)animationWithKeyPath:(NSString *)path
                             timeFxn:(ParametricTimeBlock)timeFxn
                            valueFxn:(ParametricValueBlock)valueFxn
                           fromValue:(id)fromValue
                             toValue:(id)toValue;

/**
 * @param numSteps the number of key frames to use for the animation
 *
 * @see animationWithKeyPath:timeFxn:valueFxn:fromValue:toValue:
 */
+ (instancetype)animationWithKeyPath:(NSString *)path
                             timeFxn:(ParametricTimeBlock)timeFxn
                            valueFxn:(ParametricValueBlock)valueFxn
                           fromValue:(id)fromValue
                             toValue:(id)toValue
                             inSteps:(NSUInteger)numSteps;

@end
