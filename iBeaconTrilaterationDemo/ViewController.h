//
//  ViewController.h
//  iBeaconTrilaterationDemo
//
//  Created by Hemant Tekwani on 23/06/2016.
//  Copyright © 2016 Self. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "MiBeaconTrilateration.h"

@interface ViewController : UIViewController <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>
{
    CLBeaconRegion *beaconRegion;
    CLLocationManager *locationManager;
    
    NSDictionary *beaconCoordinates;
    float scaleFactor;
    int maxY;
    
    MiBeaconTrilateration *MiBeaconTrilaterator;
    
    NSMutableArray *foundBeacons;
    
    // UI
    IBOutlet UILabel *xyResult;
    IBOutlet UITableView *beaconsTableView;
    IBOutlet UILabel *beaconsFound;
    IBOutlet UILabel *selfView;
    IBOutlet UIView *beaconGrid;
}

@end