//
//  HotelReviewModel.m
//  ChouChouExample
//
//  Created by Manju Kiran on 19/05/14.
//  Copyright (c) 2014 ibibo group. All rights reserved.
//

#import "HotelReviewModel.h"


@implementation NSArray(HotelReviewRatingArray)

@end

@implementation NSArray(HotelReviewRecoArray)

@end

@implementation NSArray(HotelReviewImagesArray)


@end


@implementation NSDictionary (HotelReviewContent)

-(HotelReviewRatings*) hotelreviewcontent_FactorRatings{
    return (HotelReviewRatings*)[self[@"rating"] mutableCopy];
}

-(HotelReviewRecos*) hotelreviewcontent_RecoForTravellerType{
    return (HotelReviewRecos*) [self[@"reco"] mutableCopy];
}

-(NSString*) hotelreviewcontent_Title{
    return self[@"title"];
}


-(NSString*) hotelreviewcontent_Description{
    return self[@"content"];
}


-(NSString*) hotelreviewcontent_Tips{
    return self[@"tips"];
}

-(HotelReviewImages*) hotelreviewcontent_Images{
    return (HotelReviewImages*) [self[@"pics"] mutableCopy];
}

@end



@implementation HotelReviewModel


-(HotelReviewContent*) content{
    return (HotelReviewContent*)[self.contentData[@"content"] mutableCopy];

}


+(HotelReviewModel*) createReviewForPostWithProperties : (NSString*)voyagerID
                                             entityname:(NSString*)entityname
                                               parentID:(NSString*)parentID
                                               location:(NSString*)location
                                                ownerid:(NSString*)ownerid
                                              ownername:(NSString*)ownername
                                                 source:(NSString*)source
                                                onError:(void (^)(NSDictionary*)) onError
{
    if(!voyagerID.length || !parentID.length || !location.length || !ownerid.length || !ownername.length ||!source.length){
        NSDictionary*errorDict = @{@"message": @"Insufficient Data to create Review Object"};
        onError(errorDict);
        return nil;
    }else{
        
        NSMutableDictionary *hotelReviewForPost = [[NSMutableDictionary alloc] init];
        NSDateFormatter *dictDateComparer = [[NSDateFormatter alloc] init];
        [dictDateComparer setDateFormat:@"yyyyMMddHHmmss"];
        
        NSDictionary*contentDict =  @{@"content": @{
                                              @"rating": @[
                                                      @{@"vfm": @"3"},
                                                      @{@"servqual": @"3"},
                                                      @{@"fnd":  @"3"},
                                                      @{@"loc":  @"3"},
                                                      @{@"amenities":  @"3"},
                                                      @{@"cleanliness":  @"3"}
                                                      ],
                                              @"reco" : @[
                                                      @{@"adv":[NSNumber numberWithBool:NO]},
                                                      @{@"backpack": [NSNumber numberWithBool:NO]},
                                                      @{@"buss": [NSNumber numberWithBool:NO]},
                                                      @{@"family": [NSNumber numberWithBool:NO]},
                                                      @{@"luxury": [NSNumber numberWithBool:NO]},
                                                      @{@"art": [NSNumber numberWithBool:NO]},
                                                      @{@"budget": [NSNumber numberWithBool:NO]},
                                                      @{@"green": [NSNumber numberWithBool:NO]},
                                                      @{@"history": [NSNumber numberWithBool:NO]},
                                                      @{@"local": [NSNumber numberWithBool:NO]},
                                                      @{@"foodie": [NSNumber numberWithBool:NO]},
                                                      @{@"romantic": [NSNumber numberWithBool:NO]},
                                                      ],
                                              @"title" : @"",
                                              @"content" : @"",
                                              @"tips" : @"",
                                              @"pics": @[]
                                              }
                                      };
        
        
//        [hotelReviewForPost setObject:contentDict forKey:@"content"];;
        [hotelReviewForPost setObject:[dictDateComparer stringFromDate:[NSDate date]] forKey:@"timestamp"];
        [hotelReviewForPost setObject:@"review" forKey:@"contenttype"];
        [hotelReviewForPost setObject:@"hotel"    forKey:@"entitytype"];
        
        [hotelReviewForPost setObject:voyagerID forKey:@"entityid"];
        [hotelReviewForPost setObject:entityname forKey:@"entityname"];
        [hotelReviewForPost setObject:parentID  forKey:@"parentid"];
        [hotelReviewForPost setObject:location  forKey:@"location"];
        [hotelReviewForPost setObject:ownerid  forKey:@"ownerid"];
        [hotelReviewForPost setObject:ownername  forKey:@"ownername"];
        [hotelReviewForPost setObject:source  forKey:@"source"];
        [hotelReviewForPost addEntriesFromDictionary:contentDict];
        
        HotelReviewModel * postHotelReview = [[HotelReviewModel alloc]init];
        postHotelReview.contentData = [[NSDictionary alloc] initWithDictionary:hotelReviewForPost];        
        return postHotelReview;
    }
}

@end
