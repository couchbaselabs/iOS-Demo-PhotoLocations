
/*
     File: RootViewController.h
 Abstract: The table view controller responsible for displaying the list of events, supporting additional functionality:
 * Addition of new new events;
 * Deletion of existing events using UITableView's tableView:commitEditingStyle:forRowAtIndexPath: method.
 
  Version: 1.1 
 */

#import <CoreLocation/CoreLocation.h>
@class CouchDatabase;

@interface RootViewController : UITableViewController <CLLocationManagerDelegate> {
	
    NSMutableArray *eventsArray;
	CouchDatabase *database;	    

    CLLocationManager *locationManager;
    UIBarButtonItem *addButton;
}

@property (nonatomic, retain) NSMutableArray *eventsArray;
@property (nonatomic, retain) CouchDatabase *database;	    

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) UIBarButtonItem *addButton;

- (void)addEvent;

@end
