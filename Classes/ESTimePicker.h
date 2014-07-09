//
//  ESTimePicker.h
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

/**
 * A custom time picker just like the google calendar app on android
 */
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ESTimePickerType) {
    ESTimePickerTypeHours,
    ESTimePickerTypeMinutes,
    ESTimePickerTypeSeconds
};

@class ESTimePicker;

@protocol ESTimePickerDelegate <NSObject>
@required
- (void)timePickerHoursChanged:(ESTimePicker *)timePicker toHours:(int)hours;
- (void)timePickerMinutesChanged:(ESTimePicker *)timePicker toMinutes:(int)minutes;

@optional
- (void)timePickerSecondsChanged:(ESTimePicker *)timePicker toSeconds:(int)seconds;
- (void)timePickerChangedType:(ESTimePicker *)timePicker toView:(ESTimePickerType)type;
@end

@interface ESTimePicker : UIView

// __________________________________________________________________________________________

/// @name Properties

// __________________________________________________________________________________________

/*!
 * The delegate of the time picker
 * @discussion You can use the time picker delegate to perform additional actions when an hour or minute is selected
 */
@property (nonatomic, assign) id<ESTimePickerDelegate> delegate;

/**
 * The color of the round wheel (aka background color)
 * @discussion Default = white
 */
@property (nonatomic, retain) UIColor *wheelColor;

/**
 * The color if a AM/PM button is pressed or the color of the middot
 * @discussion Default = blue
 */
@property (nonatomic, retain) UIColor *selectColor;

/**
 * The color of the selected hour or minute
 * @discussion Default = light blue
 */
@property (nonatomic, retain) UIColor *highlightColor;

/**
 * The color of the text used in the picker
 * @discussion Default = gray
 */
@property (nonatomic, retain) UIColor *textColor;

/**
 * The font to be used in the picker view's labels
 * @discussion Default = system font 17pt
 */
@property (nonatomic, retain) UIFont *font;

/**
 * The current selected hours
 */
@property (nonatomic, readwrite) int hours;

/**
 * The current selected minutes
 */
@property (nonatomic, readwrite) int minutes;

/**
 * The current selected seconds
 */
@property (nonatomic, readwrite) int seconds;

/**
 * Is the picker in a 24-hour format or AM/PM
 */
@property (nonatomic, readwrite, getter=isNotation24Hours) BOOL notation24Hours;

/**
 * When an hour is selected, should the pickerview automatically go to the minute view (and also from minutes > seconds)
 */
@property (nonatomic, readwrite, getter=shouldAutomaticallySwitch) BOOL automaticallySwitch;

/**
 *  Can the picker also edit seconds
 *  @discussion Default = NO
 */
@property (nonatomic, readwrite, getter=canEditSeconds) BOOL editSeconds;

/**
 * Snaps the minutes to a specific value
 * @discussion Default = 1
 */
@property (nonatomic, readwrite) unsigned int minuteSnap;

/**
 * Snaps the seconds to a specific value
 * @discussion Default = 1
 */
@property (nonatomic, readwrite) unsigned int secondSnap;

/**
 * The type of view to show
 * @discussion <pre><code>typedef NS_ENUM(NSUInteger, ESTimePickerType) {
 *      ESTimePickerTypeHours,
 *      ESTimePickerTypeMinutes
 * }</code></pre>
 */
@property (nonatomic, readwrite) ESTimePickerType type;

/**
 * Returns the current time in the correct format
 */
@property (nonatomic, readonly, assign) NSString *time;

// __________________________________________________________________________________________

/// @name Constructor

// __________________________________________________________________________________________

/**
 * Constructor
 * @param aDelegate the delegate
 * @return a ESTimePicker instance
 */
- (id)initWithDelegate:(id<ESTimePickerDelegate>)aDelegate;

// __________________________________________________________________________________________

/// @name View manipulation

// __________________________________________________________________________________________

/**
 * Changes the type
 * @param newType ESTimePickerType
 * @param animated BOOL
 */
- (void)setType:(ESTimePickerType)newType animated:(BOOL)animated;

@end