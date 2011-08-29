
/*
     File: RootViewController.m
 Abstract: The table view controller responsible for displaying the list of events, supporting additional functionality:
 * Addition of new new events;
 * Deletion of existing events using UITableView's tableView:commitEditingStyle:forRowAtIndexPath: method.
 */

#import "RootViewController.h"
#import "LocationsAppDelegate.h"
#import "Event.h"
#import "EventDetailViewController.h"
#import <CouchCocoa/CouchCocoa.h>


@implementation RootViewController


@synthesize eventsArray, addButton, locationManager;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	// Set the title.
    self.title = @"Locations";
    
	// Configure the add and edit buttons.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addEvent)];
	addButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = addButton;
    
	// Start the location manager.
	[[self locationManager] startUpdatingLocation];
}


// Called soon after launch as soon as the Couchbase database is ready
- (void)setDatabase:(CouchDatabase *)aDatabase {
	database = [aDatabase retain];
    
    NSMutableArray *mutableFetchResults = [NSMutableArray array];
    CouchQuery* query = [database getAllDocuments];
    for (CouchQueryRow* row in [query rows]) {
        Event* event = [Event modelForDocument:row.document];
        [mutableFetchResults addObject: event];
    }
        
	// Set self's events array to the mutable array, then clean up.
	[self setEventsArray:mutableFetchResults];
	[self.tableView reloadData];
}


- (CouchDatabase*)database {
    return database;
}


- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	[self.tableView reloadData];
}


- (void)viewDidUnload {
	// Release any properties that are loaded in viewDidLoad or can be recreated lazily.
	self.eventsArray = nil;
	self.locationManager = nil;
	self.addButton = nil;
}


#pragma mark -
#pragma mark Table view data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Only one section.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// As many rows as there are obects in the events array.
    return [eventsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	// A date formatter for the creation date.
    static NSDateFormatter *dateFormatter = nil;
	if (dateFormatter == nil) {
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
		[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	}
		
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
	// Get the event corresponding to the current index path and configure the table view cell.
	Event *event = (Event *)[eventsArray objectAtIndex:indexPath.row];
	
	cell.textLabel.text = [dateFormatter stringFromDate:[event creationDate]];
	cell.imageView.image = event.thumbnail;
    
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	EventDetailViewController *inspector = [[EventDetailViewController alloc] initWithNibName:@"EventDetailViewController" bundle:nil];
	inspector.event = [eventsArray objectAtIndex:indexPath.row];
	[self.navigationController pushViewController:inspector animated:YES];
	[inspector release];
}


/**
 Handle deletion of an event.
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		
        // Delete the managed object at the given index path.
		Event *eventToDelete = [eventsArray objectAtIndex:indexPath.row];
		eventToDelete.database = nil;  // deletes the document
		
		// Update the array and table view.
        [eventsArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
}


#pragma mark -
#pragma mark Add an event

/**
 Add an event.
 */
- (void)addEvent {
	
	// If it's not possible to get a location, then return.
	CLLocation *location = [locationManager location];
	if (!location) {
		return;
	}
	
	/*
	 Create a new event document.
	 */
    
	CLLocationCoordinate2D coordinate = [location coordinate];
#if TARGET_IPHONE_SIMULATOR
	// Location timestamp will be constant in the simulator.
	NSDate* creationDate = [NSDate date];
#else
	NSDate* creationDate = [location timestamp];
#endif
	
	Event* event = [Event eventWithDatabase:database
                                   latitude:coordinate.latitude
                                  longitude:coordinate.longitude
                               creationDate:creationDate];
	
	/*
	 Since this is a new event, and events are displayed with most recent events at the top of the list,
	 add the new event to the beginning of the events array; then redisplay the table view.
	 */
    [eventsArray insertObject:event atIndex:0];
    [self.tableView reloadData];
	[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}


#pragma mark -
#pragma mark Location manager

/**
 Return a location manager -- create one if necessary.
 */
- (CLLocationManager *)locationManager {
	
    if (locationManager != nil) {
		return locationManager;
	}
	
	locationManager = [[CLLocationManager alloc] init];
	[locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
	[locationManager setDelegate:self];
	
	return locationManager;
}


/**
 Conditionally enable the Add button:
 If the location manager is generating updates, then enable the button;
 If the location manager is failing, then disable the button.
 */
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    addButton.enabled = YES;
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    addButton.enabled = NO;
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[database release];
	[eventsArray release];
    [locationManager release];
    [addButton release];
    [super dealloc];
}


@end

