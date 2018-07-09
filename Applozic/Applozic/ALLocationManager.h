//
//  ALLocationManager.h
//  ChatApp
//
//  Created by Adarsh on 03/10/15.
//  Copyright © 2015 Applozic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@protocol ALLocationDelegate <NSObject>

-(void)handleAddress:(NSDictionary*) dict;

@end

@interface ALLocationManager : NSObject<CLLocationManagerDelegate>

-(instancetype) initWithDistanceFilter:(int) distance;

@property(strong,nonatomic) CLLocationManager *locationManager;
@property(nonatomic) CLGeocoder *geocoder;
@property(nonatomic) CLPlacemark *placemark;
@property(nonatomic) NSString* googleURL;
@property(nonatomic) NSString* addressString;

@property(nonatomic, weak) id <ALLocationDelegate>locationDelegate;

-(void) getAddress;

@end
