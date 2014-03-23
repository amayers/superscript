//
//  JAMMainViewController.m
//  Subscript Test
//
//  Created by Jerry Mayers on 3/23/14.
//  Copyright (c) 2014 Jerry Andrew Mayers. All rights reserved.
//

#import "JAMMainViewController.h"

#import <mach/mach_time.h>
#import "NSAttributedString+Superscript.h"

@interface JAMMainViewController ()

@end

@implementation JAMMainViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    NSString *testHTML = @"E = MC<sup>2</sup> vs H<sub>2</sub>O";

    UILabel *inputLabel = [UILabel new];
    [inputLabel setNumberOfLines:0];
    [inputLabel setText:testHTML];
    [inputLabel setFrame:CGRectMake(10, 40, self.view.bounds.size.width - 20, 50)];
    [self.view addSubview:inputLabel];

    NSAttributedString *attributedString = [NSAttributedString JAM_AttributedStringFromString:testHTML withMainFont:inputLabel.font superscriptAndSubscriptFont:[UIFont fontWithName:inputLabel.font.fontName size:inputLabel.font.pointSize - 4]];

    UILabel *outputLabel = [UILabel new];
    [outputLabel setAttributedText:attributedString];
    [outputLabel setFrame:CGRectOffset(inputLabel.frame, 0, 100)];
    [self.view addSubview:outputLabel];

    [self profileAttributedStrings];

}

- (void)profileAttributedStrings {
    // There are two main scenarios that I will be testing. The first is parsing many small strings, and the second is parsing a few huge strings.

    NSString *smallTestHTML = @"E = MC<sup>2</sup> vs H<sub>2</sub>O";
    NSString *testWithoutHTML = @" Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris ligula tellus, sodales a malesuada et, laoreet eu nunc. ";
    NSString *mediumTestHTML = [testWithoutHTML stringByAppendingString:smallTestHTML];
    NSString *largeTestHTML = [smallTestHTML copy];
    for (int i = 0; i < 20; i++) {
        largeTestHTML = [largeTestHTML stringByAppendingString:smallTestHTML];
        largeTestHTML = [largeTestHTML stringByAppendingString:testWithoutHTML];
    }
    NSString *hugeTestHTML = [smallTestHTML copy];
    for (int i = 0; i < 100; i++) {
        hugeTestHTML = [hugeTestHTML stringByAppendingString:smallTestHTML];
        hugeTestHTML = [hugeTestHTML stringByAppendingString:testWithoutHTML];
    }

    NSLog(@"%lu small string length", (unsigned long)smallTestHTML.length);
    NSLog(@"%lu medium string length", (unsigned long)mediumTestHTML.length);
    NSLog(@"%lu large string length", (unsigned long)largeTestHTML.length);
    NSLog(@"%lu huge string length\n", (unsigned long)hugeTestHTML.length);

    UIFont *mainFont = [UIFont systemFontOfSize:14];
    UIFont *superscriptFont = [UIFont systemFontOfSize:10];

    // Do the huge string first so its memory can be reclaimed quickly
    [self profile:^{
        NSAttributedString *attributedString = [self attributedStringFromString:hugeTestHTML mainFont:mainFont];
    } name:@"1 huge string using initWithData" benchmark:0];

    [self profile:^{
        NSAttributedString *attributedString = [NSAttributedString JAM_AttributedStringFromString:hugeTestHTML withMainFont:mainFont superscriptAndSubscriptFont:superscriptFont];
    } name:@"1 huge string using JAM_AttributedStringFromString" benchmark:0];

    for (int numberOfRuns = 1; numberOfRuns <= 1000; numberOfRuns *= 10) {
        [self profile:^{
            for (int runNumber = 0; runNumber < numberOfRuns; runNumber++) {
                NSAttributedString *attributedString = [self attributedStringFromString:smallTestHTML mainFont:mainFont];
            }
        } name:[NSString stringWithFormat:@"%d small strings using initWithData", numberOfRuns] benchmark:0];

        [self profile:^{
            for (int runNumber = 0; runNumber < numberOfRuns; runNumber++) {
                NSAttributedString *attributedString = [NSAttributedString JAM_AttributedStringFromString:smallTestHTML withMainFont:mainFont superscriptAndSubscriptFont:superscriptFont];
            }
        } name:[NSString stringWithFormat:@"%d small strings using JAM_AttributedStringFromString", numberOfRuns] benchmark:0];

        [self profile:^{
            for (int runNumber = 0; runNumber < numberOfRuns; runNumber++) {
                NSAttributedString *attributedString = [self attributedStringFromString:mediumTestHTML mainFont:mainFont];
            }
        } name:[NSString stringWithFormat:@"%d medium strings using initWithData", numberOfRuns] benchmark:0];

        [self profile:^{
            for (int runNumber = 0; runNumber < numberOfRuns; runNumber++) {
                NSAttributedString *attributedString = [NSAttributedString JAM_AttributedStringFromString:mediumTestHTML withMainFont:mainFont superscriptAndSubscriptFont:superscriptFont];
            }
        } name:[NSString stringWithFormat:@"%d medium strings using JAM_AttributedStringFromString", numberOfRuns] benchmark:0];


        [self profile:^{
            for (int runNumber = 0; runNumber < numberOfRuns; runNumber++) {
                NSAttributedString *attributedString = [self attributedStringFromString:largeTestHTML mainFont:mainFont];
            }
        } name:[NSString stringWithFormat:@"%d large strings using initWithData", numberOfRuns] benchmark:0];

        [self profile:^{
            for (int runNumber = 0; runNumber < numberOfRuns; runNumber++) {
                NSAttributedString *attributedString = [NSAttributedString JAM_AttributedStringFromString:largeTestHTML withMainFont:mainFont superscriptAndSubscriptFont:superscriptFont];
            }
        } name:[NSString stringWithFormat:@"%d large strings using JAM_AttributedStringFromString", numberOfRuns] benchmark:0];
    }

}

/// This is using Apple's HTML -> Attributed String parsing
- (NSAttributedString *)attributedStringFromString:(NSString *)string mainFont:(UIFont *)mainFont {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithData:[string dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    [attributedString setAttributes:@{NSFontAttributeName:mainFont} range:NSMakeRange(0, attributedString.string.length)];
    return attributedString;
}

#pragma mark - Timing
// This timing code adapted from http://stackoverflow.com/questions/17567127/nsarray-vs-c-array-performance-comparison

int machTimeToMS(uint64_t machTime)
{
    const int64_t kOneMillion = 1000 * 1000;
    static mach_timebase_info_data_t s_timebase_info;

    if (s_timebase_info.denom == 0) {
        (void) mach_timebase_info(&s_timebase_info);
    }
    return (int)((machTime * s_timebase_info.numer) / (kOneMillion * s_timebase_info.denom));
}

- (int)profile:(dispatch_block_t)call name:(NSString *)name benchmark:(int)benchmark
{
    int duration;

    @autoreleasepool {
        uint64_t startTime, stopTime;
        startTime = mach_absolute_time();

        call();

        stopTime = mach_absolute_time();

        duration = machTimeToMS(stopTime - startTime);

        if (benchmark > 0) {
            NSLog(@"%@: %i (%0.1f%%)", name, duration, ((float)duration / (float)benchmark) * 100.0f);
        } else {
            NSLog(@"%@: %i", name, duration);
        }

    }
    
    return duration;
    
}

@end
