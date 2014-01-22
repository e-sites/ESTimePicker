ESTimePicker
============
[![Platform](https://cocoapod-badges.herokuapp.com/p/ESTimePicker/badge.png)](http://cocoadocs.org/docsets/ESTimePicker)
[![Version](https://cocoapod-badges.herokuapp.com/v/ESTimePicker/badge.png)](http://cocoadocs.org/docsets/ESTimePicker)

A custom time picker just like the [Google Calendar Android App](https://www.google.nl/search?q=google+calendar+time+picker&espv=210&es_sm=91&source=lnms&tbm=isch&sa=X&ei=hXPeUsHwLuLCyQOP_YHICg&ved=0CAkQ_AUoAQ&biw=1756&bih=1047)

## Example
<br>
![Example](https://raw.github.com/e-sites/ESTimePicker/master/Assets/example.gif)


## Features

- Works both in ARC as in MRC
- Choose your own colors (background, highlight, selection, text)
- Choose your own font
- Both 24 hour notation and AM/PM
- Snap the minute view
- Completelly usable in your own viewcontroller or view

## Installation
Use cocoapods:

	pod 'ESTimePicker'
	
And then import the desired .h file:
	
	#import "ESTimePicker.h"

## Implementation
```objective-c
- (void)viewDidLoad
{
   	ESTimePicker *timePicker = [[ESTimePicker alloc] initWithDelegate:self]; // Delegate is optional
   	[timePicker setFrame:CGRectMake(10, 100, 300, 300)];
   	[self.view addSubview:timePicker];
}
	
- (void)timePickerHoursChanged:(ESTimePicker *)timePicker toHours:(int)hours
{
   	[hoursLabel setText:[NSString stringWithFormat:@"%i", hours]];
}

- (void)timePickerMinutesChanged:(ESTimePicker *)timePicker toMinutes:(int)minutes
{
   	[minutesLabel setText:[NSString stringWithFormat:@"%i", minutes]];
}
```

## Documentation
The official documentation can be found [here](https://rawgithub.com/e-sites/ESTimePicker/master/Documents/Classes/ESTimePicker.html).

## Dependencies
This class uses the `ESMathUtils` class (which is included)


## License
Copyright (C) 2014 e-sites, [http://e-sites.nl/](http://www.e-sites.nl/). Licensed under the BSD license.
