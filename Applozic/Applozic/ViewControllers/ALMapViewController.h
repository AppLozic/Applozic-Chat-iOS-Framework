//
//  ALMapViewController.h
//  ChatApp
//
//  Created by Devashish on 13/10/15.
//  Copyright © 2015 AppLogic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol ALMapViewControllerDelegate <NSObject>

@optional
-(void)sendGoogleMap:(NSString *)latLongString withCompletion:(void(^)(NSString *message, NSError *error))completion;
-(void)sendGoogleMapOffline:(NSString*)latLongString;

@end

@interface ALMapViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *sendLocationButton;
@property (strong, nonatomic) IBOutlet MKMapView *mapKitView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property  MKCoordinateRegion region;

@property(nonatomic,strong) UIImageView* mapView;

@property(nonatomic, weak) id<ALMapViewControllerDelegate>controllerDelegate;

@end
