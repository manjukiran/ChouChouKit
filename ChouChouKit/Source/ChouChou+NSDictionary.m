//
//  Dictionary+PayU.m
//  Goibibo
//
//  Created by Sourabh Verma on 28/01/14.
//  Copyright (c) 2014 ibibo Web Pvt Ltd. All rights reserved.
//

#import "ChouChou+NSDictionary.h"

@implementation NSDictionary (ChouChou)

// Construct URL encoded POST data from a dictionary
- (NSString *)postStringForNetwork{
    @try {
        NSMutableString *data = [NSMutableString string];
        
        for (NSString *key in self) {
            NSString *value = [self objectForKey:key];
            if (value == nil) {
                continue;
            }
            
            if ([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]]) {
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:value
                                                                   options:NSJSONWritingPrettyPrinted
                                                                     error:nil];
                value = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
            }
            if ([value isKindOfClass:[NSString class]]) {
                value = [self URLEncodedStringFromString:value];
            }
            
            [data appendFormat:@"%@=%@&", [self URLEncodedStringFromString:key], value];
        }
        return data;
    }
    @catch (NSException *exception) {
        return nil;
    }
}

- (NSData *)postDataForNetwork{
    return [[self postStringForNetwork] dataUsingEncoding:NSUTF8StringEncoding];
}

// This, from CSKit, is free for use:
// https://github.com/codenauts/CNSKit/blob/master/Classes/Categories/NSString%2BCNSStringAdditions.m
// NSString *encoded = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)string, NULL, CFSTR(":/?#[]@!$&’()*+,;='"), kCFStringEncodingUTF8);

- (NSString *) URLEncodedStringFromString: (NSString *)string {
    NSMutableString * output = [NSMutableString string];
    const unsigned char * source = (const unsigned char *)[string UTF8String];
    int sourceLen = (int)strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

@end


@implementation NSMutableDictionary (ChouChou)
-(void)setObjectNilHandled:(id)anObject forKey:(NSString*)aKey{
    if(aKey){
        if(anObject){
            [self setObject:anObject forKey:aKey];
        }
        else{
            [self setObject:@"" forKey:aKey];
        }
    }
    else{
        NSLog(@"Dictionary+PayU: Key cant be nil");
    }
}

-(void)setValueNilHandled:(id)value forKey:(NSString *)key{
    if(key){
        if(value){
            [super setValue:value forKey:key];
        }
        else{
            [super setValue:@"" forKey:key];
        }
    }
    else{
        NSLog(@"Dictionary+PayU: Key cant be nil");
    }
}
@end
