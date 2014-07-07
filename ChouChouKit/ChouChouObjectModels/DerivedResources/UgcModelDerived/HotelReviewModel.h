//
//  HotelReviewModel.h
//  ChouChouExample
//
//  Created by Manju Kiran on 19/05/14.
//  Copyright (c) 2014 ibibo group. All rights reserved.
//

#import "UgcModel.h"

@interface HotelReviewRatings : NSMutableArray
@end

@interface HotelReviewRecos : NSMutableArray
@end

@interface HotelReviewImages : NSMutableArray
@end

@interface HotelReviewContent : NSMutableDictionary

@property (nonatomic,strong) HotelReviewRatings *hotelreviewcontent_FactorRatings;
@property (nonatomic,strong) HotelReviewRecos   *hotelreviewcontent_RecoForTravellerType;
@property (nonatomic,strong)  NSString          *hotelreviewcontent_Title;
@property (nonatomic,strong)  NSString          *hotelreviewcontent_Description;
@property (nonatomic,strong)  NSString          *hotelreviewcontent_Tips;
@property (nonatomic,strong) HotelReviewImages  *hotelreviewcontent_Images;

@end


@interface HotelReviewModel : UgcModel

+(HotelReviewModel*) createReviewForPostWithProperties : (NSString*)voyagerID
                                             entityname:(NSString*)entityname
                                               parentID:(NSString*)parentID
                                               location:(NSString*)location
                                                ownerid:(NSString*)ownerid
                                              ownername:(NSString*)ownername
                                                 source:(NSString*)source
                                                onError:(void (^)(NSDictionary*)) onError;
@end
