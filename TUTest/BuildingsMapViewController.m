//
//  BuildingsMapViewController.m
//  TUTest
//
//  Created by Martijn de Vos on 19-03-13.
//  Copyright (c) 2013 Martijn de Vos. All rights reserved.
//

#import "BuildingsMapViewController.h"
#import <MapKit/MapKit.h>

@interface BuildingsMapViewController ()

@property (nonatomic, weak) IBOutlet UINavigationBar *navigationBar;

@end

@implementation BuildingsMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)cancelPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)zoomMapViewToFitAnnotations:(MKMapView *)mapView animated:(BOOL)animated
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // set the bar at the right place
    [_navigationBar setFrame:CGRectMake(0, 0, 320, 44)];
    
    // create the map
    CGRect screen = [[UIScreen mainScreen] bounds];
    MKMapView *mv = [[MKMapView alloc] initWithFrame:CGRectMake(0, 44, 320, screen.size.height - 44)];
    [self.view addSubview:mv];
    
    // zoom the map
    CLLocationCoordinate2D centerLocation =
    CLLocationCoordinate2DMake(52.0, 4.37501);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.02, 0.02);
    MKCoordinateRegion region = MKCoordinateRegionMake(centerLocation, span);
    NSLog(@"hereee");
    [mv setRegion:region animated:NO];
    
    // load the buildings on the map
    [_buildings enumerateObjectsUsingBlock:^(NSDictionary *building, NSUInteger idx, BOOL *stop)
     {
         NSDictionary *address = building[@"fysiekAdres"][@"binnenlandsAdres"];
         NSString *addressString = [NSString stringWithFormat:@"%@ %@ %@", address[@"straat"], address[@"huisnummer"], address[@"plaats"]];
         
         CLGeocoder *geocoder = [[CLGeocoder alloc] init];
         [geocoder geocodeAddressString:addressString completionHandler:^(NSArray *placemarks, NSError *error)
          {
              for(CLPlacemark *placemark in placemarks)
              {
                  MKPlacemark *mkPlacemark = [[MKPlacemark alloc] initWithPlacemark:placemark];
                  MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
                  point.coordinate = mkPlacemark.coordinate;
                  point.title = building[@"naamEN"];
                  [mv addAnnotation:point];
              }
          }];
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
