ESTimePicker
============

A custom time picker just like the Google Calendar Android App

## Example
<br>
![Example](https://raw.github.com/e-sites/ESTimePicker/master/Assets/example.gif)


## Features

- Choose your own colors (background, highlight, selection, text)
- Choose your own font
- Both 24 hour notation and AM/PM
- Snap the minute view
- Completelly usable in your own viewcontroller or view

## Implementation

    ESTimePicker *timePicker = [[ESTimePicker alloc] initWithDelegate:self];
    [timePicker setFrame:CGRectMake(10, 100, 300, 300)];
    [self.view addSubview:timePicker];