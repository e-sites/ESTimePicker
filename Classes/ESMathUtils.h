//
//  ESMathUtils.h
//  iOS.Library
//
//  Created by Bas van Kuijck on 30-09-13.
//
//  [ v1.1 ]
//  - Added class method 'getDateFromSeconds'
//  - Added class method 'prefixNumberBelowTen'

#import <Foundation/Foundation.h>

@interface ESMathUtils : NSObject


+(CGFloat)degreesToRadian:(CGFloat)degrees;
+(CGFloat)radiansToDegrees:(CGFloat)radians;
+(CGFloat)distanceBetween:(CGPoint)point1 and:(CGPoint)point2;
+(CGFloat)angleBetween:(CGPoint)point1 and:(CGPoint)point2;
+(CGFloat)angleBetweenLines:(CGPoint)line1Start line1End:(CGPoint)line1End line2Start:(CGPoint)line2Start line2End:(CGPoint)line2End;
+(CGFloat)clamp:(CGFloat)val min:(CGFloat)min max:(CGFloat)max;
+(CGPoint)slopeFromDegrees:(CGFloat)degrees;
+(CGPoint)slopeFromRadians:(CGFloat)radians;
+(NSDictionary *)getDateFromSeconds:(NSTimeInterval)secs;
+(NSString *)prefixNumberBelowTen:(NSInteger)num;
@end
