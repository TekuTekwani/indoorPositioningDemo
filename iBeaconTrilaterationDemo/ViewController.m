//
//  ViewController.m
//  iBeaconTrilaterationDemo
//
//  Created by Hemant Tekwani on 23/06/2016.
//  Copyright © 2016 Self. All rights reserved.
//


#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    
    // Estimote beacon UUID
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"7b44b47b-52a1-5381-90c2-f09b6838c5d4"];
    beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"GemTot iOS"];
    
    
    // start ranging ID
    [locationManager startMonitoringForRegion:beaconRegion];
    [locationManager startRangingBeaconsInRegion:beaconRegion];
    
    if([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [locationManager requestAlwaysAuthorization];
    }
    
    MiBeaconTrilaterator = [[MiBeaconTrilateration alloc] init];
    
    // misc UI settings
    [beaconGrid.layer setCornerRadius:10];
    [selfView.layer setCornerRadius:10];
    
    [self plotBeaconsFromPlistToGrid];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)plotBeaconsFromPlistToGrid {
    // load plist to dictionary
    if (!beaconCoordinates)
    {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *plistPath = [bundle pathForResource:@"beaconCoordinates" ofType:@"plist"];
        beaconCoordinates = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    }
    
    // determine max coordinate to calculate scalefactor
    float maxCoordinate = -MAXFLOAT;
    float minCoordinate = MAXFLOAT;
    
    for (NSString* key in beaconCoordinates) {
        NSArray *coordinates = [beaconCoordinates objectForKey:key];
        int X = [[coordinates objectAtIndex:0] intValue];
        int Y = [[coordinates objectAtIndex:1] intValue];
        
        // max & min y & x
        if (X < minCoordinate) minCoordinate = X;
        if (X > maxCoordinate) maxCoordinate = X;
        if (Y < minCoordinate) minCoordinate = Y;
        if (Y > maxCoordinate) maxCoordinate = Y;
    }
    
    scaleFactor = 290 / (maxCoordinate-minCoordinate); //290 is width/height gridView
    maxY = (maxCoordinate-minCoordinate) * scaleFactor;
    
    // loop through dictionary to plot all beacons
    for (NSString* key in beaconCoordinates) {
        NSArray *coordinates = [beaconCoordinates objectForKey:key];
        int X = [[coordinates objectAtIndex:0] intValue];
        int Y = [[coordinates objectAtIndex:1] intValue];
        
        UILabel *beaconLabel = [[UILabel alloc] initWithFrame:CGRectMake((X * scaleFactor)-10, (maxY-(Y * scaleFactor))-10, 20, 20)];
        [beaconLabel setText:key];
        
        [beaconLabel setBackgroundColor:[UIColor colorWithRed:(10/255.0) green:(140/255.0) blue:(220/255.0) alpha:1]];
        [beaconLabel setTextAlignment:NSTextAlignmentCenter];
        [beaconLabel setFont:[UIFont fontWithName:@"Helvetica-Neue Light" size:15.0f]];
        [beaconLabel setTextColor:[UIColor whiteColor]];
        [beaconLabel.layer setCornerRadius:10.0f];
        
        [beaconGrid addSubview:beaconLabel];
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    foundBeacons = [beacons copy];
    
    // put them in the tableView
    [beaconsFound setText:[NSString stringWithFormat:@"Found beacons (%lu)", (unsigned long)[foundBeacons count]]];
    [beaconsTableView reloadData];
    
    // perform trilateration
    [MiBeaconTrilaterator trilaterateWithBeacons:foundBeacons done:^(NSString *error, NSArray *coordinates) {
        if ([error isEqualToString:@""])
        {
            float x = [[coordinates objectAtIndex:0] floatValue];
            float y = [[coordinates objectAtIndex:1] floatValue];
            
            [xyResult setText:[NSString stringWithFormat:@"X: %.1f   Y: %.1f", x, y]];
            [selfView setHidden:NO];
            [selfView setFrame:CGRectMake((x * scaleFactor)-10, (maxY-(y * scaleFactor))-10, 20, 20)];
        }
        else
        {
            NSLog(@"%@", error);
            [xyResult setText:@"unable to trilaterate"];
            [selfView setHidden:YES];
        }
    }];
}


- (void) locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(nonnull CLBeaconRegion *)region withError:(nonnull NSError *)error
{
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [foundBeacons count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CLBeacon *currentBeacon = [foundBeacons objectAtIndex:indexPath.row];
    UITableViewCell *cell;
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        [cell.textLabel setTextColor:[UIColor darkGrayColor]];
        [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica-Neue Thin" size:15.0f]];
        [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
    }
    
    [cell.textLabel setText:[NSString stringWithFormat:@"%d/%d rssi:%ld dist: %.1fm", [[currentBeacon major] intValue], [[currentBeacon minor] intValue],(long)[currentBeacon rssi], [currentBeacon accuracy]]];
    
    return cell;
}

@end

