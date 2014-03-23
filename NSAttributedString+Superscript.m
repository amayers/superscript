//
//  NSAttributedString+Superscript.m
//  Subscript Test
//
//  Created by Jerry Mayers on 3/23/14.
//  Copyright (c) 2014 Jerry Andrew Mayers. All rights reserved.
//

#import "NSAttributedString+Superscript.h"
#import <CoreText/CoreText.h>

@implementation NSAttributedString (Superscript)

+ (NSAttributedString *)JAM_AttributedStringFromString:(NSString *)string withMainFont:(UIFont *)mainFont superscriptFont:(UIFont *)superscriptFont subscriptFont:(UIFont *)subscriptFont {
    NSMutableArray *superscriptRanges = [NSMutableArray new];
    NSMutableArray *subscriptRanges = [NSMutableArray new];

    NSString *openingScriptPattern = @"(<su[+bp]>)";
    NSString *closingScriptPattern = @"(</su[+bp]>)";

    NSRegularExpression *scriptRegex = [NSRegularExpression regularExpressionWithPattern:openingScriptPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSRegularExpression *closingScriptRegex = [NSRegularExpression regularExpressionWithPattern:closingScriptPattern options:NSRegularExpressionCaseInsensitive error:nil];

    NSRange range = NSMakeRange(0, string.length);
    NSTextCheckingResult *openingResult = [scriptRegex firstMatchInString:string options:0 range:range];
    NSTextCheckingResult *closingResult = [closingScriptRegex firstMatchInString:string options:0 range:range];

    while (openingResult && closingResult && openingResult.range.location != NSNotFound && closingResult.range.location != NSNotFound) {
        NSRange finalScriptRange = NSMakeRange(openingResult.range.location, closingResult.range.location - openingResult.range.location - openingResult.range.length);
        if ([[string substringWithRange:openingResult.range] isEqualToString:@"<sub>"]) {
            [subscriptRanges addObject:[NSValue valueWithRange:finalScriptRange]];
        } else {
            [superscriptRanges addObject:[NSValue valueWithRange:finalScriptRange]];
        }

        string = [string stringByReplacingCharactersInRange:openingResult.range withString:@""];
        NSRange closingRange = NSMakeRange(closingResult.range.location - openingResult.range.length, closingResult.range.length);
        string = [string stringByReplacingCharactersInRange:closingRange withString:@""];

        range = NSMakeRange(0, string.length);
        openingResult = [scriptRegex firstMatchInString:string options:0 range:range];
        closingResult = [closingScriptRegex firstMatchInString:string options:0 range:range];
    }

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName:mainFont}];
    for (NSValue *value in superscriptRanges) {
        NSRange range = [value rangeValue];
        [attributedString addAttributes:@{NSFontAttributeName:superscriptFont, (NSString *)kCTSuperscriptAttributeName:@(1)} range:range];
    }

    for (NSValue *value in subscriptRanges) {
        NSRange range = [value rangeValue];
        [attributedString addAttributes:@{NSFontAttributeName:subscriptFont, (NSString *)kCTSuperscriptAttributeName:@(-1)} range:range];
    }
    
    return attributedString;
}

+ (NSAttributedString *)JAM_AttributedStringFromString:(NSString *)string withMainFont:(UIFont *)mainFont superscriptAndSubscriptFont:(UIFont *)superscriptAndSubscriptFont {
    return [NSAttributedString JAM_AttributedStringFromString:string withMainFont:mainFont superscriptFont:superscriptAndSubscriptFont subscriptFont:superscriptAndSubscriptFont];
}

@end
