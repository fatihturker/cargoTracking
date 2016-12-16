//
//  KargoTakipViewController.h
//  KargoTakip
//
//  Created by Fatih Türker on 04.07.2012.
//  Copyright (c) 2012 fatih__turker@hotmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "sqlite3.h"

@interface KargoTakipViewController : UIViewController <CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
    NSTimer *myTimer;

    NSString        *databasePath;
    sqlite3 *contactDB;
    NSString *baslangicdateString;
}
@property (weak, nonatomic) IBOutlet UILabel *veriler;

@property (nonatomic, retain) NSTimer *myTimer;
@property (weak, nonatomic) IBOutlet UIButton *OperasyonTitleChange;
@property (weak, nonatomic) IBOutlet UILabel *paketUyari;
@property (weak, nonatomic) IBOutlet UITextField *toplamPaket;
@property (retain, nonatomic) NSString *stopOperation_2,*baslangicdateString;

-(IBAction) operasyonaBasla;
-(IBAction) teslimatArasi;
-(IBAction) sendDatas;
@property (weak, nonatomic) IBOutlet UIImageView *redGreenImage;

@property(copy) CLLocationManager *locationManager;
@end
