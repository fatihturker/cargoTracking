//
//  KargoTakipViewController.m
//  KargoTakip
//
//  Created by Fatih Türker on 04.07.2012.
//  Copyright (c) 2012 fatih__turker@hotmail.com. All rights reserved.
//

#import "KargoTakipViewController.h"
#import "TeslimatViewController.h"
#import "DagitimViewController.h"
#import "SendDatasViewController.h"
@interface KargoTakipViewController ()

@end

@implementation KargoTakipViewController
@synthesize veriler;
@synthesize OperasyonTitleChange;
@synthesize paketUyari;
@synthesize toplamPaket;
@synthesize redGreenImage;
@synthesize locationManager;
@synthesize stopOperation_2,baslangicdateString, myTimer;
- (void)viewDidLoad
{
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = [dirPaths objectAtIndex:0];
    
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"kargoTakipVerileri.sqlite"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
		const char *dbpath = [databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS Operation(op_id integer PRIMARY KEY AUTOINCREMENT, baslangic_time text, bitis_time text, toplam_paket text)";
            
            if (sqlite3_exec(contactDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                //status.text = @"Failed to create table";
            }
            const char *sql_stmt2 = "CREATE TABLE IF NOT EXISTS Location(loc_id integer PRIMARY KEY AUTOINCREMENT, op_id integer, long text, lat text,FOREIGN KEY(op_id) REFERENCES Operation(op_id))";
            
            if (sqlite3_exec(contactDB, sql_stmt2, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                //status.text = @"Failed to create table";
            }
            
            const char *sql_stmt3 = "CREATE TABLE IF NOT EXISTS Delivery(del_id integer PRIMARY KEY AUTOINCREMENT, loc_id integer, kalan_paket text, quant_received text, status integer, FOREIGN KEY(loc_id) REFERENCES Location(loc_id))";
            
            if (sqlite3_exec(contactDB, sql_stmt3, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                //status.text = @"Failed to create table";
            }
            
            const char *sql_stmt4 = "CREATE TABLE IF NOT EXISTS Break(break_id integer PRIMARY KEY AUTOINCREMENT, op_id integer, baslangic_time text, bitis_time text,long text, lat text, FOREIGN KEY(op_id) REFERENCES Operation(op_id))";
            
            if (sqlite3_exec(contactDB, sql_stmt4, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                //status.text = @"Failed to create table";
            }
            
            sqlite3_close(contactDB);
            
        } else {
            // status.text = @"Failed to open/create database";
        }
            
    }
    
    self.navigationController.navigationBar.tintColor = [UIColor blueColor];
     self.navigationItem.hidesBackButton = YES;
  
   
    [super viewDidLoad];

	// Do any additional setup after loading the view, typically from a nib.
}


-(IBAction) sendDatas{
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"artikPaket"];
    SendDatasViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"sendData"];
    [self.navigationController pushViewController:detail animated:YES];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != 1) {
      
        [toplamPaket resignFirstResponder];
        NSCharacterSet *nonNumberSet = [NSCharacterSet symbolCharacterSet];
        NSCharacterSet *nonNumberSet2 = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSCharacterSet *nonNumberSet3 = [NSCharacterSet letterCharacterSet];
        NSCharacterSet *nonNumberSet4 = [NSCharacterSet punctuationCharacterSet];
        NSCharacterSet *nonNumberSet5 = [NSCharacterSet decimalDigitCharacterSet];
        if([toplamPaket.text rangeOfCharacterFromSet:nonNumberSet].location == NSNotFound &&[toplamPaket.text rangeOfCharacterFromSet:nonNumberSet2].location == NSNotFound&&[toplamPaket.text rangeOfCharacterFromSet:nonNumberSet3].location == NSNotFound && [toplamPaket.text rangeOfCharacterFromSet:nonNumberSet4].location == NSNotFound&&[toplamPaket.text rangeOfCharacterFromSet:nonNumberSet5].location != NSNotFound){
            paketUyari.text = @"";
            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"artikPaket"];
            int tumpaketler= [toplamPaket.text integerValue] + [[self artikPaket] integerValue];
            NSString *sumPackage = [NSString stringWithFormat:@"%i",tumpaketler];
            NSLog(@"%@",[self artikPaket]);
            toplamPaket.text=sumPackage;
            [[NSUserDefaults standardUserDefaults] setObject:sumPackage forKey:@"toplamPaketString"];
            NSDateFormatter *formatter;
            
            formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"dd-MM-yyyy_HH:mm:ss"];
            
            baslangicdateString = [formatter stringFromDate:[NSDate date]];
            [[NSUserDefaults standardUserDefaults] setObject:baslangicdateString forKey:@"bDateString"];
            
            //DataBase Operation
            const char *dbpath = [databasePath UTF8String];
            sqlite3_stmt    *statement;
            
            if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
            {
                NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO Operation(baslangic_time, toplam_paket) VALUES (\"%@\",\"%@\")",baslangicdateString, sumPackage];
                // NSLog(@"%@",insertSQL);
                const char *query_stmt = [insertSQL UTF8String];
                
                sqlite3_prepare_v2(contactDB, query_stmt, -1, &statement, NULL);
                
                if (sqlite3_step(statement) == SQLITE_DONE)
                {
                    // NSLog(@"Islem Tamam");
                    
                } else {
                    // NSLog(@"Islem Gerceklestirilemiyor");
                    
                }
                sqlite3_finalize(statement);
                sqlite3_close(contactDB);
            }
            
            stopOperation_2 = @"10";
            NSString *kp = @"-1";
            [[NSUserDefaults standardUserDefaults] setObject:stopOperation_2 forKey:@"stopOperation2String"];
            [[NSUserDefaults standardUserDefaults] setObject:kp forKey:@"kalanPaketString"];
            
            redGreenImage.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"park-23965_640" ofType:@"png"]];
            [[NSUserDefaults standardUserDefaults] setObject:stopOperation_2 forKey:@"flagString"];
            [self.OperasyonTitleChange setTitle: @"Dağıtım Başladı" forState: UIControlStateNormal];
            
            locationManager = [[CLLocationManager alloc] init];
            locationManager.delegate = self;
            locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
            [locationManager startUpdatingLocation];
            //[locationManager startMonitoringSignificantLocationChanges];
            // Adding values to DB after 15 Sec.
            
            myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(DBLocation) userInfo:nil repeats:YES];
            
        }else {
            paketUyari.text = @"Lütfen Toplam Paket Adedini Doğru Giriniz!!";
        }
    }else{
        [toplamPaket resignFirstResponder];
        NSCharacterSet *nonNumberSet = [NSCharacterSet symbolCharacterSet];
        NSCharacterSet *nonNumberSet2 = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSCharacterSet *nonNumberSet3 = [NSCharacterSet letterCharacterSet];
        NSCharacterSet *nonNumberSet4 = [NSCharacterSet punctuationCharacterSet];
        NSCharacterSet *nonNumberSet5 = [NSCharacterSet decimalDigitCharacterSet];
        if([toplamPaket.text rangeOfCharacterFromSet:nonNumberSet].location == NSNotFound &&[toplamPaket.text rangeOfCharacterFromSet:nonNumberSet2].location == NSNotFound&&[toplamPaket.text rangeOfCharacterFromSet:nonNumberSet3].location == NSNotFound && [toplamPaket.text rangeOfCharacterFromSet:nonNumberSet4].location == NSNotFound&&[toplamPaket.text rangeOfCharacterFromSet:nonNumberSet5].location != NSNotFound){
            paketUyari.text = @"";
            int tumpaketler= [toplamPaket.text integerValue] + [[self artikPaket] integerValue];
            NSString *sumPackage = [NSString stringWithFormat:@"%i",tumpaketler];
            toplamPaket.text=sumPackage;
            [[NSUserDefaults standardUserDefaults] setObject:sumPackage forKey:@"toplamPaketString"];
            NSDateFormatter *formatter;
            
            formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"dd-MM-yyyy_HH:mm:ss"];
            
            baslangicdateString = [formatter stringFromDate:[NSDate date]];
            [[NSUserDefaults standardUserDefaults] setObject:baslangicdateString forKey:@"bDateString"];
            
            //DataBase Operation
            const char *dbpath = [databasePath UTF8String];
            sqlite3_stmt    *statement;
            
            if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
            {
                NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO Operation(baslangic_time, toplam_paket) VALUES (\"%@\",\"%@\")",baslangicdateString, sumPackage];
                // NSLog(@"%@",insertSQL);
                const char *query_stmt = [insertSQL UTF8String];
                
                sqlite3_prepare_v2(contactDB, query_stmt, -1, &statement, NULL);
                
                if (sqlite3_step(statement) == SQLITE_DONE)
                {
                    // NSLog(@"Islem Tamam");
                    
                } else {
                    // NSLog(@"Islem Gerceklestirilemiyor");
                    
                }
                sqlite3_finalize(statement);
                sqlite3_close(contactDB);
            }
            
            stopOperation_2 = @"10";
            NSString *kp = @"-1";
            [[NSUserDefaults standardUserDefaults] setObject:stopOperation_2 forKey:@"stopOperation2String"];
            [[NSUserDefaults standardUserDefaults] setObject:kp forKey:@"kalanPaketString"];
            
            redGreenImage.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"park-23965_640" ofType:@"png"]];
            [[NSUserDefaults standardUserDefaults] setObject:stopOperation_2 forKey:@"flagString"];
            [self.OperasyonTitleChange setTitle: @"Dağıtım Başladı" forState: UIControlStateNormal];
            
            locationManager = [[CLLocationManager alloc] init];
            locationManager.delegate = self;
            locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
            [locationManager startUpdatingLocation];
            //[locationManager startMonitoringSignificantLocationChanges];
           
            
            myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(DBLocation) userInfo:nil repeats:YES];
            
        }else {
            paketUyari.text = @"Lütfen Toplam Paket Adedini Doğru Giriniz!!";
        }
    }

}

-(IBAction) teslimatArasi{
    if([[self checkFlag] integerValue]==10){
    [locationManager stopUpdatingLocation];
    [myTimer invalidate];
    myTimer = nil;
    TeslimatViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"teslimatAra"];
    [self.navigationController pushViewController:detail animated:YES];
    }else {
         paketUyari.text = @"Henüz Operasyona Başlanmadı!!";
    }
}
-(NSString*)checkFlag
{
    NSString* recoveredString = [[NSUserDefaults standardUserDefaults] objectForKey:@"flagString"];
    return recoveredString;
}

-(IBAction) operasyonaBasla{
    //Getting Current Time
    if([[self artikPaket] integerValue]!=0){
        NSString *beforeop= [NSString stringWithFormat:@"Önceki Operasyondan %@ Adet Paketiniz Kalmıştır.",[self artikPaket]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:beforeop message:@"Onları da eklemek istiyor musunuz?" delegate:self cancelButtonTitle:@"Hayır" otherButtonTitles:nil];
    [alert addButtonWithTitle:@"Evet"];
    [alert show];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Operasyon Başlatılıyor." message:@"" delegate:self cancelButtonTitle:@"" otherButtonTitles:nil];
        [alert addButtonWithTitle:@"Tamam"];
        [alert show];
    }

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

-(void) DBLocation{ 
    
    //DataBase Location (Add Time Interval)
    NSString *OpID=[[NSString alloc] init];;
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    //NSLog(@"OK");
    if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"SELECT op_id FROM Operation WHERE baslangic_time=\"%@\"",baslangicdateString];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(contactDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                const char* mevName = (const char *) sqlite3_column_text(statement, 0);
                if(mevName==nil){
                     OpID = @" ";
                }else {
                     OpID = [NSString stringWithUTF8String: mevName];
                }
                [[NSUserDefaults standardUserDefaults] setObject:OpID forKey:@"OperationIDString"];
            } 
            sqlite3_finalize(statement);
        }
        sqlite3_close(contactDB);
    }
    
    if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
    {
        NSString *longitude = [NSString stringWithFormat:@"%1.4f",locationManager.location.coordinate.longitude];
        NSString *latitude = [NSString stringWithFormat:@"%1.4f",locationManager.location.coordinate.latitude];
        veriler.text=latitude;
        NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO Location(op_id, long, lat) VALUES (\"%i\",\"%@\",\"%@\")",[OpID integerValue],longitude, latitude];
        
        const char *query_stmt = [insertSQL UTF8String];
        
        sqlite3_prepare_v2(contactDB, query_stmt, -1, &statement, NULL);
        
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"%@",insertSQL);
            
        } else {
            // NSLog(@"Islem Gerceklestirilemiyor");
            
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB); 
    }
    
    if([[self stopOperation2] integerValue]!=10){   
        if([[self stopOperation] integerValue]==10){
  
            [myTimer invalidate];
            myTimer = nil;
        }
    }
}


- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{

    if([[self stopOperation2] integerValue]!=10){
    if([[self stopOperation] integerValue]==10){
        [locationManager stopUpdatingLocation];
    }
    }
}
-(NSString*)stopOperation2
{
    NSString* recoveredString = [[NSUserDefaults standardUserDefaults] objectForKey:@"stopOperation2String"];
    return recoveredString;
}
-(NSString*)artikPaket
{
    NSString* recoveredString = [[NSUserDefaults standardUserDefaults] objectForKey:@"artikPaket"];
    return recoveredString;
}
-(NSString*)stopOperation
{
    NSString* recoveredString = [[NSUserDefaults standardUserDefaults] objectForKey:@"stopOperationString"];
    return recoveredString;
}
- (void)viewDidUnload
{

    [self setToplamPaket:nil];
    [self setRedGreenImage:nil];
    [self setPaketUyari:nil];
    [self setOperasyonTitleChange:nil];
    [self setVeriler:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
