//
//  Dictionary+PayU.h
//  Goibibo
//
//  Created by Sourabh Verma on 28/01/14.
//  Copyright (c) 2014 ibibo Web Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (ChouChou)
- (NSString *)postStringForNetwork;
- (NSData *)postDataForNetwork;
@end


@interface NSMutableDictionary (ChouChou)
-(void)setValueNilHandled:(id)value forKey:(NSString *)key;
-(void)setObjectNilHandled:(id)anObject forKey:(NSString*)aKey;
@end