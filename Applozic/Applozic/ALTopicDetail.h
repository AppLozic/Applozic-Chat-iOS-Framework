//
//  ALTopicDetail.h
//  Applozic
//
//  Created by Devashish on 27/02/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALJson.h"
/*
 
 topicDetail = "{\"title\":\"Product on demand\",\"subtitle\":\"PID : 4398343dsjhsjdhsdj9\",\"link\":\"http://www.msupply.com/media/catalog/product/cache/1/image/400x492/9df78eab33525d08d6e5fb8d27136e95/E/L/ELEL10014724_1.jpg\",\"key1\":\"Qty\",\"value1\":\"50\",\"key2\":\"Price\",\"value2\":\"Rs.90\"}";
 topicId = product2;
 },
 
 */
@interface ALTopicDetail : ALJson

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, strong) NSString *pId;
@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) NSString *key1;
@property (nonatomic, strong) NSString *value1;
@property (nonatomic, strong) NSString *key2;
@property (nonatomic, strong) NSString *value2;
@property (nonatomic, strong) NSString *topicId;
@property (nonatomic,strong)  NSMutableArray *fallBackTemplateList;



-(id)initWithDictonary:(NSDictionary *)detailJson;

-(void)parseMessage:(id) detailJson;


@end
