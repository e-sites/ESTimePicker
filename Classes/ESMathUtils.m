//
//  ESMathUtils.m
//  iOS.Library
//
//  Created by Bas van Kuijck on 30-09-13.
//
//  Copyright (c) 2014, e-sites B.V. (www.e-sites.nl)
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//
//  Neither the name of the e-sites B.V. nor the
//  names of its contributors may be used to endorse or promote products
//  derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF TH

#import "ESMathUtils.h"

@implementation ESMathUtils

+(CGFloat)degreesToRadian:(CGFloat)degrees
{
    return M_PI * degrees / 180.0;
}

+(CGFloat)radiansToDegrees:(CGFloat)radians
{
    return 180.0 * radians / M_PI;
}

+(CGFloat)distanceBetween:(CGPoint)point1 and:(CGPoint)point2
{
	return sqrt(pow(point2.x - point1.x, 2) + pow(point2.y - point1.y, 2));
}

+(CGFloat)angleBetween:(CGPoint)point1 and:(CGPoint)point2
{
	CGFloat height = point2.y - point1.y;
	CGFloat width = point1.x - point2.x;
	return [self.class radiansToDegrees:atanf(height / width)];
}

+(CGFloat)angleBetweenLines:(CGPoint)line1Start line1End:(CGPoint)line1End line2Start:(CGPoint)line2Start line2End:(CGPoint)line2End
{
	CGFloat a = line1End.x - line1Start.x;
	CGFloat b = line1End.y - line1Start.y;
	CGFloat c = line2End.x - line2Start.x;
	CGFloat d = line2End.y - line2Start.y;
	
	CGFloat rads = acos(((a*c) + (b*d)) / ((sqrt(pow(a, 2) + pow(b, 2))) * (sqrt(pow(c, 2) + pow(d, 2)))));
	
	return [self.class radiansToDegrees:rads];
}

+(CGFloat)clamp:(CGFloat)val min:(CGFloat)min max:(CGFloat)max
{
    return fminf(max, fmaxf(min, val));
}

+(CGPoint)slopeFromDegrees:(CGFloat)degrees
{
    return [self.class slopeFromRadians:[self.class degreesToRadian:degrees]];
}

+(CGPoint)slopeFromRadians:(CGFloat)radians
{
    return CGPointMake(sinf(radians), -cosf(radians));
}

+(NSDictionary *)getDateFromSeconds:(NSTimeInterval)secs
{
    
    int weeks = 0;
    int days = 0;
    int hours = 0;
    int minutes = 0;
    int ds = 60 * 60 * 24 * 7;
    while (secs >= ds) {
        weeks++;
        secs -= ds;
    }
    ds = 60 * 60 * 24;
    while (secs >= ds) {
        days++;
        secs -= ds;
    }
    ds = 60 * 60;
    while (secs >= ds) {
        hours++;
        secs -= ds;
    }
    ds = 60;
    while (secs >= ds) {
        minutes++;
        secs -= ds;
    }
    
    return @{
             @"weeks": [NSNumber numberWithInteger:weeks],
             @"days": [NSNumber numberWithInteger:days],
             @"hours": [NSNumber numberWithInteger:hours],
             @"minutes": [NSNumber numberWithInteger:minutes],
             @"seconds": [NSNumber numberWithInteger:secs]
             };
}

+(NSString *)prefixNumberBelowTen:(NSInteger)num
{
    return [NSString stringWithFormat:@"%02zd", num];
}
@end
