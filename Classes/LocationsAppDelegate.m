
/*
     File: LocationsAppDelegate.m
 Abstract: Application delegate to set up Couchbase Mobile and configure the view and navigation controllers.
  Version: 1.1
 */

#import "LocationsAppDelegate.h"
#import "RootViewController.h"
#import <CouchCocoa/CouchCocoa.h>


@implementation LocationsAppDelegate

@synthesize window;
@synthesize rootViewController;
@synthesize navigationController;
@synthesize server;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	// Configure and show the window.
	
	self.rootViewController = [[[RootViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];

    // Initialize CouchDB:
    CouchbaseMobile* cb = [[CouchbaseMobile alloc] init];
    cb.delegate = self;
	if (![cb start]) {
        // TODO: Report error
        NSLog(@"OMG: Couchbase couldn't start! Exiting! Error = %@", cb.error);
        exit(1);    // Panic!
    }
	
	UINavigationController *aNavigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
	self.navigationController = aNavigationController;
	
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
	
	[aNavigationController release];
    
    return YES;
}

// This is the CouchbaseDelegate method called when the database starts up:
-(void)couchbaseMobile:(CouchbaseMobile*)cb didStart:(NSURL *)serverURL {
#ifdef DEBUG
    gCouchLogLevel = 1;  // Turn on some basic logging in CouchCocoa
#endif
    
    if (!self.server) {
        // Do this the first time the server starts, i.e. not after a wake-from-bg:
        self.server = [[[CouchServer alloc] initWithURL: serverURL] autorelease];
        CouchDatabase* database = [self.server databaseNamed: @"locations"];
        
        RESTOperation* op = [database create];
        if (![op wait] && op.httpStatus != 412) {   // 412 = Conflict; just means DB already exists
            // TODO: Report error
            NSLog(@"OMG: Couldn't create database: %@", op.error);
            exit(1);    // Panic!
        }
        rootViewController.database = database;
    }
    
    rootViewController.database.tracksChanges = YES;
}


-(void)couchbaseMobile:(CouchbaseMobile*)couchbase failedToStart:(NSError*)error {
    // TODO: Report error
    NSLog(@"OMG: Couchbase couldn't start! Exiting!");
    exit(1);    // Panic!
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Make sure all async operations complete before allowing the process to be suspended:
    [RESTOperation wait: self.server.activeOperations];
    // Stop the change tracker until wake-up
    rootViewController.database.tracksChanges = NO;
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Make sure all async operations complete before quitting:
    [RESTOperation wait: self.server.activeOperations];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	
    [server release];
    
	[navigationController release];
	[window release];
	[super dealloc];
}


@end
