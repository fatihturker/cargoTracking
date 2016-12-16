//
//  DagitimViewController.h
//  KargoTakip
//
//  Created by Fatih Türker on 05.07.2012.
//  Copyright (c) 2012 fatih__turker@hotmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "sqlite3.h"
@interface DagitimViewController : UIViewController<CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
    NSString        *databasePath;
    sqlite3 *contactDB;
}
@property (weak, nonatomic) IBOutlet UIButton *dagitimaDevamButton;
@property (weak, nonatomic) IBOutlet UIImageView *breakImage;
@property (weak, nonatomic) IBOutlet UIImageView *dagitimImage;
@property (weak, nonatomic) IBOutlet UILabel *kalanPaketLabel;
@property (retain, nonatomic) NSString *stopOperation;
@property (weak, nonatomic) IBOutlet UILabel *teslimatUyari;
@property(copy) CLLocationManager *locationManager;
-(IBAction)teslimataDon;
-(IBAction)operasyonuBitir;
-(IBAction)mola;
-(IBAction)dagitimaDevam;
@end
