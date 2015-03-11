//
//  ESMathUtils.h
//  iOS.Library
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
//  Created by Bas van Kuijck on 30-09-13.
//
//  [ v1.1 ]
//  - Added class method 'getDateFromSeconds'
//  - Added class method 'prefixNumberBelowTen'

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

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
