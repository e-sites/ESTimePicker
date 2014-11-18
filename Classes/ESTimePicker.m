//
//  ESTimePicker.m
//  ios-library
//
//  Created by Bas van Kuijck on 20-01-14.
//
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
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import <QuartzCore/QuartzCore.h>
#import "ESTimePicker.h"
#import "ESMathUtils.h"

#if !__has_feature(objc_arc)
#define mrcRelease(obj) [obj release]
#else
#define mrcRelease(obj)
#endif

// ######################################################################################################

// _ESTimePickerLineView

// ######################################################################################################

@interface _ESTimePickerLineView : UIView
{
    CGPoint _point;
}
@property (nonatomic, assign) ESTimePicker *timerPicker;

- (void)setPosition:(CGPoint)point;
@end

@implementation _ESTimePickerLineView
@synthesize timerPicker;

- (void)setPosition:(CGPoint)point
{
    _point = point;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    if (CGPointEqualToPoint(_point, CGPointZero)) { return; }
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, self.timerPicker.highlightColor.CGColor);
    
    CGContextSetLineWidth(context, 1.0);
    
    CGContextMoveToPoint(context, CGRectGetMidX(self.timerPicker.bounds), CGRectGetMidY(self.timerPicker.bounds));
    
    CGContextAddLineToPoint(context, _point.x, _point.y);
    
    CGContextStrokePath(context);
    
    CGContextSetFillColorWithColor(context, self.timerPicker.highlightColor.CGColor);
    
    const CGFloat w = 6;
    rect.origin.x = CGRectGetMidX(rect) - w / 2;
    rect.origin.y = CGRectGetMidY(rect) - w / 2;
    rect.size = CGSizeMake(w, w);
    CGContextAddEllipseInRect(context, rect);
    CGContextDrawPath(context, kCGPathFill);
    
    UIGraphicsEndImageContext();
}

#if !__has_feature(objc_arc)

- (void)dealloc
{
    self.timerPicker = nil;
    [super dealloc];
}

#endif
@end

// ######################################################################################################

// _ESTimePickerUILabel

// ######################################################################################################

@interface _ESTimePickerUILabel : UILabel
@property (nonatomic, readwrite) int ringNumber;
@property (nonatomic, readwrite, getter=shouldSnap) BOOL snap;
@end

@implementation  _ESTimePickerUILabel
@synthesize ringNumber,snap;
@end

// ######################################################################################################

// ESTimePicker

// ######################################################################################################

@interface ESTimePicker ()
{
    _ESTimePickerLineView *_lineView;
    BOOL _shouldMoveBack;
    UIView *_midDot;
    UIButton *_amButton;
    BOOL _pm;
    UIButton *_pmButton;
    BOOL _initialized;
    UITapGestureRecognizer *_tapGestureRecognizer;
    UIPanGestureRecognizer *_panGestureRecognizer;
    UIView *_container;
    BOOL _animating;
}
- (void)_init;
- (void)_touch:(CGPoint)point;
- (void)_positionTo:(_ESTimePickerUILabel *)lbl;
- (void)_refresh;
- (void)_refreshAMPM;
@end


@implementation ESTimePicker
@synthesize wheelColor=_wheelColor,notation24Hours=_notation24Hours,type=_type,highlightColor=_highlightColor,delegate,minuteSnap,selectColor=_selectColor,font=_font,hours=_hours,minutes=_minutes,textColor=_textColor,automaticallySwitch,time,seconds=_seconds;

static CGFloat const kScaleFactor = 0.2f;
static double const kAnimationSpeed = 0.25f;

#pragma mark - Constructor
// ____________________________________________________________________________________________________________________

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self _init];
    }
    return self;
}

- (id)init
{
    if (self = [super init]) {
        [self _init];
    }
    return self;
}


- (id)initWithDelegate:(id<ESTimePickerDelegate>)aDelegate
{
    if (self = [super init]) {
        [self setDelegate:aDelegate];
        [self _init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self _init];
    }
    return self;
}

- (void)_init
{
    if (_initialized) { return; }
    _amButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _pmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setAutomaticallySwitch:YES];
    [self setMinuteSnap:1];
    [self setSecondSnap:1];
    self.type = ESTimePickerTypeHours;
    
    // 24 hour notation
    NSDate *date = [NSDate date];
    NSDateFormatter *fm = [[NSDateFormatter alloc] init];
    [fm setDateFormat:@"a"];
    NSString *formatStringForHours = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    _pm = NO;
    _notation24Hours = NO;
    if ([formatStringForHours rangeOfString:@"a"].location != NSNotFound) {
        _pm = [[fm stringFromDate:date] isEqualToString:@"PM"];
        
    } else {
        _notation24Hours = YES;
        [_pmButton setHidden:YES];
        [_amButton setHidden:YES];
    }
    [fm setDateFormat:@"H"];
    _hours = (int)[[fm stringFromDate:date] integerValue];
    [fm setDateFormat:@"m"];
    _minutes = (int)[[fm stringFromDate:date] integerValue];
    mrcRelease(fm);
    
    _textColor = [UIColor colorWithWhite:0.4 alpha:1];
    _font = [UIFont systemFontOfSize:16];
    _wheelColor = [UIColor whiteColor];
    _selectColor = [UIColor colorWithRed:54.0f / 255.0f green:181.0f / 255.0f blue:229.0f / 251.0f alpha:1];
    _highlightColor = [UIColor colorWithRed:213.0f / 255.0f green:240.0f / 255.0f blue:255.0f / 251.0f alpha:1];
#if !__has_feature(objc_arc)
    [_textColor retain];
    [_font retain];
    [_wheelColor retain];
    [_selectColor retain];
    [_highlightColor retain];
#endif
    [self setBackgroundColor:[UIColor clearColor]];
    
    
    // Line
    _lineView = [[_ESTimePickerLineView alloc] initWithFrame:self.bounds];
    _lineView.timerPicker = self;
    [_lineView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_lineView];
    mrcRelease(_lineView);
    
    // Container
    _container = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:_container];
    mrcRelease(_container);
    
    _midDot = [[UIView alloc] init];
    [self addSubview:_midDot];
    mrcRelease(_midDot);
    
    // AM/PM
    [self addSubview:_amButton];
    [_amButton setTitleColor:_textColor forState:UIControlStateNormal];
    [_amButton setTitle:@"AM" forState:UIControlStateNormal];
    
    [self addSubview:_pmButton];
    [_pmButton setTitleColor:_textColor forState:UIControlStateNormal];
    [_pmButton setTitle:@"PM" forState:UIControlStateNormal];
    
    
    [_amButton setBackgroundColor:_wheelColor];
    [_pmButton setBackgroundColor:_wheelColor];
    
    [_amButton addTarget:self action:@selector(_over:) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
    [_pmButton addTarget:self action:@selector(_over:) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
    
    [_amButton addTarget:self action:@selector(_out:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchDragExit];
    [_pmButton addTarget:self action:@selector(_out:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchDragExit];
    
    [_amButton addTarget:self action:@selector(_up:) forControlEvents:UIControlEventTouchUpInside];
    [_pmButton addTarget:self action:@selector(_up:) forControlEvents:UIControlEventTouchUpInside];
    
    _initialized = YES;
    [self _refreshAMPM];
    [self setNeedsDisplay];
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapPan:)];
    [_tapGestureRecognizer setNumberOfTapsRequired:1];
    [self addGestureRecognizer:_tapGestureRecognizer];
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_tapPan:)];
    [_panGestureRecognizer setMaximumNumberOfTouches:1];
    [self addGestureRecognizer:_panGestureRecognizer];

#if !__has_feature(objc_arc)
    [_tapGestureRecognizer release];
    [_panGestureRecognizer release];
#endif
}

- (void)setFrame:(CGRect)frame
{
    if (frame.size.width > frame.size.height) {
        frame.origin.x += (frame.size.width - frame.size.height) / 2;
        frame.size.width = frame.size.height;
        
    } else if (frame.size.width < frame.size.height) {
        frame.origin.y += (frame.size.height - frame.size.width) / 2;
        frame.size.height = frame.size.width;
    }
    
    [super setFrame:frame];
    [self setNeedsDisplay];
    [self _refresh];
}

#pragma mark - Events
// ____________________________________________________________________________________________________________________

- (void)_over:(UIControl *)control
{
    [control setBackgroundColor:self.selectColor];
}

- (void)_out:(UIControl *)control
{
    [control setBackgroundColor:control.isSelected?self.highlightColor:self.wheelColor];
}

- (void)_up:(UIControl *)control
{
    BOOL pm = [control isEqual:_pmButton];
    if (pm == _pm) { return; }
    _pm = pm;
    [self _refreshAMPM];
    [self _refresh];
    if (!pm) {
        _hours -= 12;
        if (_hours == -12) {
            _hours = 12;
        }
    } else {
        _hours += 12;
        if (_hours == 24) {
            _hours = 0;
        }
    }
    if (self.type == ESTimePickerTypeHours && [self.delegate respondsToSelector:@selector(timePickerHoursChanged:toHours:)]) {
        [self.delegate timePickerHoursChanged:self toHours:self.hours];
    }
}

#pragma mark - Properties
// ____________________________________________________________________________________________________________________

- (void)setWheelColor:(UIColor *)wheelColor
{
    mrcRelease(_wheelColor);
    _wheelColor = wheelColor;
#if !__has_feature(objc_arc)
    [_wheelColor retain];
#endif
    [self _refreshAMPM];
    [self setNeedsDisplay];
}

- (void)setFont:(UIFont *)font
{
    mrcRelease(_font);
    _font = font;
#if !__has_feature(objc_arc)
    [_font retain];
#endif
    for (_ESTimePickerUILabel *lbl in _container.subviews) {
        [lbl setFont:font];
    }
}

- (void)setTextColor:(UIColor *)textColor
{
    mrcRelease(_textColor);
    _textColor = textColor;
#if !__has_feature(objc_arc)
    [_textColor retain];
#endif
    for (_ESTimePickerUILabel *lbl in _container.subviews) {
        [lbl setTextColor:textColor];
    }
    [_amButton setTitleColor:textColor forState:UIControlStateNormal];
    [_pmButton setTitleColor:textColor forState:UIControlStateNormal];
}

- (void)setNotation24Hours:(BOOL)notation24Hours
{
    _notation24Hours = notation24Hours;
    [self _refreshAMPM];
    [self _refresh];
}

- (void)setSelectColor:(UIColor *)selectColor
{
    mrcRelease(_selectColor);
    _selectColor = selectColor;
#if !__has_feature(objc_arc)
    [_selectColor retain];
#endif
    [_midDot setBackgroundColor:_selectColor];
}

- (void)setHighlightColor:(UIColor *)highlightColor
{
    mrcRelease(_highlightColor);
    _highlightColor = highlightColor;
    
#if !__has_feature(objc_arc)
    [_highlightColor retain];
#endif
    [self _refreshAMPM];
    [_lineView setNeedsDisplay];
}

- (void)setHours:(int)hours
{
    if (!_notation24Hours) {
        hours %= 12;
    }
    _hours = hours;
    if (self.type == ESTimePickerTypeHours) {
        [self _selectViewWithValue:self.hours];
    }
}

- (void)setMinutes:(int)minutes
{
    _minutes = minutes;
    if (self.type == ESTimePickerTypeMinutes) {
        [self _selectViewWithValue:self.minutes];
    }
}

- (void)setSeconds:(int)seconds
{
    _seconds = seconds;
    if (self.type == ESTimePickerTypeSeconds) {
        [self _selectViewWithValue:self.seconds];
    }
}

- (void)setType:(ESTimePickerType)newType
{
    [self setType:newType animated:NO];
}

- (void)setType:(ESTimePickerType)newType animated:(BOOL)animated
{
    if (newType == _type || _animating) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(timePickerChangedType:toView:)]) {
        [self.delegate timePickerChangedType:self toView:newType];
    }
    
    if (!animated) {
        _type = newType;
        [self _refreshAMPM];
        [self _refresh];
        return;
    }
    
    [_midDot setHidden:YES];
    _animating = YES;
    [_lineView setHidden:YES];
    UIGraphicsBeginImageContextWithOptions(_container.bounds.size, NO, 0.0);
    [_container.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageView *imageView = [[UIImageView alloc] initWithImage:img];
    [imageView setFrame:_container.frame];
    [self addSubview:imageView];
    mrcRelease(imageView);
    _shouldMoveBack = YES;
    ESTimePickerType oldType = _type;
    _type = newType;
    [self _refreshAMPM];
    [self _refresh];
    
    [UIView animateWithDuration:kAnimationSpeed
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:(void (^)(void)) ^{
                         imageView.alpha = 0;
                         if (newType > oldType) {
                             imageView.transform = CGAffineTransformMakeScale(1.0 + kScaleFactor, 1.0 + kScaleFactor);
                         } else {
                             imageView.transform = CGAffineTransformMakeScale(1.0 - kScaleFactor, 1.0 - kScaleFactor);
                         }
                     }
                     completion:^(BOOL finished){
                         _animating = NO;
                         [imageView removeFromSuperview];
                     }];
}

- (NSString *)time
{
    if (self.isNotation24Hours) {
        return [NSString stringWithFormat:@"%@:%@", [ESMathUtils prefixNumberBelowTen:self.hours], [ESMathUtils prefixNumberBelowTen:self.minutes]];
    }
    return [NSString stringWithFormat:@"%i:%@ %@", self.hours, [ESMathUtils prefixNumberBelowTen:self.minutes], _pm ? @"PM": @"AM"];
}

#pragma mark - Drawing
// ____________________________________________________________________________________________________________________

- (void)_refreshAMPM
{
    [_amButton setSelected:!_pm];
    [_pmButton setSelected:_pm];
    [_amButton setBackgroundColor:_amButton.isSelected ? _highlightColor : _wheelColor];
    [_pmButton setBackgroundColor:_pmButton.isSelected ? _highlightColor : _wheelColor];
    [_amButton setHidden:_notation24Hours || self.type == ESTimePickerTypeMinutes || self.type == ESTimePickerTypeSeconds];
    [_pmButton setHidden:_notation24Hours || self.type == ESTimePickerTypeMinutes || self.type == ESTimePickerTypeSeconds];
}

- (void)drawRect:(CGRect)rect
{
    [_container setFrame:self.bounds];
    [_lineView setFrame:self.bounds];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, self.wheelColor.CGColor);
    
    CGContextAddEllipseInRect(context, rect);
    CGContextDrawPath(context, kCGPathFill);
    
    UIGraphicsEndImageContext();
}

- (void)_refresh
{
    if (!_initialized) { return; }
    while ([_container.subviews count]) {
        [_container.subviews[0] removeFromSuperview];
    }
    const CGFloat widthHeight = 40;
    const CGFloat padding = widthHeight / 2;
    
    CGRect r = _midDot.frame;
    r.size.width =
    r.size.height = widthHeight / 4;
    [_midDot setFrame:r];
    _midDot.layer.cornerRadius = widthHeight / 8;
    CGFloat radius = (CGRectGetWidth(self.bounds) - widthHeight - 5) / 2.0f;
    CGFloat centerX = CGRectGetMidX(self.bounds);
    CGFloat centerY = CGRectGetMidX(self.bounds);
    int total = (self.notation24Hours ? 24 : 12);
    int rotateTotal = 12;
    if (self.type == ESTimePickerTypeMinutes || self.type == ESTimePickerTypeSeconds) {
        rotateTotal =
        total = 60;
    }
    
    CGFloat dif = sqrtf(powf(CGRectGetWidth(self.bounds), 2) + powf(CGRectGetHeight(self.bounds), 2)) - self.bounds.size.height;
    dif *= 0.5;
    dif *= sin([ESMathUtils degreesToRadian:45]);
    
    [_amButton.layer setCornerRadius:dif / 2];
    [_amButton.titleLabel setFont:self.font];
    [_amButton setFrame:CGRectMake(0, self.bounds.size.height - dif, dif, dif)];
    
    [_pmButton.layer setCornerRadius:dif / 2];
    [_pmButton.titleLabel setFont:self.font];
    [_pmButton setFrame:CGRectMake(self.bounds.size.width - dif, self.bounds.size.height - dif, dif, dif)];
    
    int ringNumber = 0;
    for (int i = 0; i < total; i++) {
        
        CGFloat degrees = (360 / rotateTotal) * i;
        degrees -= 90;
        CGFloat radians = [ESMathUtils degreesToRadian:degrees];
        CGFloat x = (centerX + cos(radians) * radius) - padding;
        CGFloat y = (centerY + sin(radians) * radius) - padding;
        CGRect f = CGRectMake(x, y, widthHeight, widthHeight);
        _ESTimePickerUILabel *lbl = [[_ESTimePickerUILabel alloc] initWithFrame:f];
        [lbl.layer setCornerRadius:widthHeight / 2];
        [lbl setClipsToBounds:YES];
        [lbl setFont:self.font];
        [lbl setTextColor:self.textColor];
        [lbl setRingNumber:ringNumber];
        [lbl setBackgroundColor:[UIColor clearColor]];
        [lbl setTextAlignment:NSTextAlignmentCenter];
        int v = (12 + i) % 24;
        NSString *extra = @"";
        if (self.type == ESTimePickerTypeMinutes || self.type == ESTimePickerTypeSeconds) {
            if (i % 5 > 0) {
                [lbl setTextColor:[UIColor clearColor]];
            }
            if (self.type == ESTimePickerTypeMinutes) {
                [lbl setSnap:i % self.minuteSnap == 0];
            } else {
                [lbl setSnap:i % self.secondSnap == 0];
            }
            v = i;
            if (v < 10) {
                extra = @"0";
            }
        } else {
            [lbl setSnap:YES];
            if (self.notation24Hours) {
                if (i == 0) { v = 0; }
                if (i == 12) { v = 12; }
                if (v < 10) {
                    extra = @"0";
                }
            } else {
                v = i;
                if (i == 0) {
                    v = 12;
                }
            }
            if (v == 0) {
                extra = @"0";
            }
        }
        [lbl setText:[NSString stringWithFormat:@"%@%i", extra, v]];
        [_container addSubview:lbl];
        mrcRelease(lbl);
        if (i == 11 && self.type == ESTimePickerTypeHours) {
            ringNumber = 1;
            radius *= 0.7;
        }
    }
    
    if (!_shouldMoveBack) {
        if (self.type == ESTimePickerTypeHours) {
            [self _selectViewWithValue:self.hours];
            
        } else if (self.type == ESTimePickerTypeMinutes) {
            [self _selectViewWithValue:self.minutes];
            
        } else {
            [self _selectViewWithValue:self.seconds];
        }
        return;
    }
    _shouldMoveBack = NO;
    UIGraphicsBeginImageContextWithOptions(_container.bounds.size, NO, 0.0);
    [_container.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img2 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView *imageView2 = [[UIImageView alloc] initWithImage:img2];
    [imageView2 setFrame:_container.frame];
    [self addSubview:imageView2];
    mrcRelease(imageView2);
    
    [_container setHidden:YES];
    
    if (_type == ESTimePickerTypeMinutes || _type == ESTimePickerTypeSeconds) {
        imageView2.transform = CGAffineTransformMakeScale(1.0 - kScaleFactor, 1.0 - kScaleFactor);
    } else {
        imageView2.transform = CGAffineTransformMakeScale(1.0 + kScaleFactor, 1.0 + kScaleFactor);
    }
    imageView2.alpha = 0;
    [UIView animateWithDuration:kAnimationSpeed
                          delay:kAnimationSpeed / 2
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:(void (^)(void)) ^{
                         imageView2.alpha = 1;
                         imageView2.transform = CGAffineTransformMakeScale(1.0, 1.0);
                     }
                     completion:^(BOOL finished){
                         [_container setHidden:NO];
                         if (self.type == ESTimePickerTypeHours) {
                             [self _selectViewWithValue:self.hours];
                             
                         } else if (self.type == ESTimePickerTypeMinutes) {
                             [self _selectViewWithValue:self.minutes];
                             
                         } else {
                             [self _selectViewWithValue:self.seconds];
                         }
                         [imageView2 removeFromSuperview];
                     }];
    
    
}

#pragma mark - Touches
// ____________________________________________________________________________________________________________________

- (void)_end
{
    if (self.type == ESTimePickerTypeHours && self.shouldAutomaticallySwitch) {
        [self setType:ESTimePickerTypeMinutes animated:YES];
        
    } else if (self.type == ESTimePickerTypeMinutes && self.shouldAutomaticallySwitch && self.canEditSeconds) {
        [self setType:ESTimePickerTypeSeconds animated:YES];
    }
}

- (void)_tapPan:(UIGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:self];
    [self _touch:point];
    
    if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        [self _end];
        return;
    }
}

- (void)_touch:(CGPoint)point
{
    [_midDot setHidden:YES];
    if (_animating) { return; }
    [_midDot setHidden:NO];
    [_lineView setHidden:NO];
    [_lineView setNeedsDisplay];
    _ESTimePickerUILabel *lbl = nil;
    CGFloat distanceFromMid = [ESMathUtils distanceBetween:point and:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))];
    CGFloat minDistance = CGFLOAT_MAX;
    int ring = 0;
    if (distanceFromMid < (self.bounds.size.width / 2) * 0.6 && self.type == ESTimePickerTypeHours && self.notation24Hours) {
        ring = 1;
    }
    for (_ESTimePickerUILabel *label in _container.subviews) {
        [label setBackgroundColor:[UIColor clearColor]];
        CGPoint labelPoint = CGPointMake(label.frame.origin.x + CGRectGetWidth(label.frame) / 2, label.frame.origin.y + CGRectGetHeight(label.frame) / 2);
        CGFloat distance = [ESMathUtils distanceBetween:point and:labelPoint];
        if (distance < minDistance && label.ringNumber == ring && label.shouldSnap) {
            lbl = label;
            minDistance = distance;
        }
    }
    [self _positionTo:lbl];
    int v = (int)[lbl.text integerValue];
    if (self.type == ESTimePickerTypeHours) {
        if (_pm && !self.isNotation24Hours) {
            if (v < 12) {
                v += 12;
            } else {
                v = 0;
            }
        }
        if (_hours == v) { return; }
        _hours = v;
        if ([self.delegate respondsToSelector:@selector(timePickerHoursChanged:toHours:)]) {
            [self.delegate timePickerHoursChanged:self toHours:v];
        }
    } else if (self.type == ESTimePickerTypeMinutes) {
        if (_minutes == v) { return; }
        _minutes = v;
        if ([self.delegate respondsToSelector:@selector(timePickerMinutesChanged:toMinutes:)]) {
            [self.delegate timePickerMinutesChanged:self toMinutes:v];
        }
        
    } else if (self.type == ESTimePickerTypeSeconds && self.canEditSeconds) {
        if (_seconds == v) { return; }
        _seconds = v;
        if ([self.delegate respondsToSelector:@selector(timePickerSecondsChanged:toSeconds:)]) {
            [self.delegate timePickerSecondsChanged:self toSeconds:v];
        }
    }
}

- (void)_positionTo:(_ESTimePickerUILabel *)lbl
{
    [_midDot setHidden:NO];
    [_lineView setHidden:NO];
    [_container sendSubviewToBack:lbl];
    CGPoint p = CGPointMake(CGRectGetMidX(lbl.frame), CGRectGetMidY(lbl.frame));
    [_lineView setPosition:p];
    CGRect r = _midDot.frame;
    r.origin.x = p.x - (r.size.width / 2);
    r.origin.y = p.y - (r.size.height / 2);
    [_midDot setFrame:r];
    [_midDot setBackgroundColor:self.selectColor];
    [lbl setBackgroundColor:self.highlightColor];
}

- (void)_selectViewWithValue:(int)value
{
    if (!_notation24Hours && self.type == ESTimePickerTypeHours) {
        value %= 12;
        if (value == 0) {
            value = 12;
        }
    }
    for (_ESTimePickerUILabel *lbl in _container.subviews) {
        if ([lbl.text integerValue] == value) {
            [self _positionTo:lbl];
        } else {
            [lbl setBackgroundColor:[UIColor clearColor]];
        }
    }
}


#pragma mark - Destructor
// ____________________________________________________________________________________________________________________

- (void)dealloc
{
    [self removeGestureRecognizer:_tapGestureRecognizer];
    [self removeGestureRecognizer:_panGestureRecognizer];
#if !__has_feature(objc_arc)
    [_font release], _font = nil;
    [_textColor release], _textColor = nil;
    [_selectColor release], _selectColor = nil;
    [_highlightColor release], _highlightColor = nil;
    [_wheelColor release], _wheelColor = nil;
    [super dealloc];
#endif
}

@end