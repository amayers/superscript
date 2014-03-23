//
//  NSAttributedString+Superscript.h
//  Subscript Test
//
//  Created by Jerry Mayers on 3/23/14.
//  Copyright (c) 2014 Jerry Andrew Mayers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (Superscript)

+ (NSAttributedString *)JAM_AttributedStringFromString:(NSString *)string withMainFont:(UIFont *)mainFont superscriptFont:(UIFont *)superscriptFont subscriptFont:(UIFont *)subscriptFont;
+ (NSAttributedString *)JAM_AttributedStringFromString:(NSString *)string withMainFont:(UIFont *)mainFont superscriptAndSubscriptFont:(UIFont *)superscriptAndSubscriptFont;

@end
