Superscript
===========

An NSAttributedString category for iOS (with a performance testing project) to convert an NSString with ```<sup>``` and ```<sub>``` HTML tags denoting superscript and subscript text into an NSAttributedString. It is up to 74.5 times faster than using NSAttributedString's ```initWithData:options:documentAttributes:error:``` initializer and can be executed on a background thread. 

Suggested usage:

	NSAttributedString *attributedString = [NSAttributedString JAM_AttributedStringFromString:string withMainFont:mainFont superscriptAndSubscriptFont:subscriptFont];
	

For more detailed info, read this [Wiki](https://github.com/amayers/superscript/wiki/).