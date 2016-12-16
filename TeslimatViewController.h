//
//  TeslimatViewController.h
//  KargoTakip
//
//  Created by Fatih Türker on 05.07.2012.
//  Copyright (c) 2012 fatih__turker@hotmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import <CoreLocation/CoreLocation.h>
@interface TeslimatViewController : UIViewController<CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
    NSString        *databasePath;
    sqlite3 *contactDB;
    NSTimer *myTimer;
}
@property (nonatomic, retain) NSTimer *myTimer;
@property (weak, nonatomic) IBOutlet UITextField *indirilenPaket;
@property (weak, nonatomic) IBOutlet UILabel *indirilenPaketUyari;
@property(copy) CLLocationManager *locationManager;
-(IBAction) teslimEdildi;
-(IBAction) teslimAlindi;
@end
