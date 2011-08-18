
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
    CouchbaseEmbeddedServer* cb = [[CouchbaseEmbeddedServer alloc] init];
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
-(void)couchbaseDidStart:(NSURL *)serverURL {
    if (!serverURL) {
        // TODO: Report error
        NSLog(@"OMG: Couchbase couldn't start! Exiting!");
        exit(1);    // Panic!
    }
    
#ifdef DEBUG
	NSLog(@"CouchDB is ready, go!");
    gRESTLogLevel = kRESTLogRequestHeaders;
#endif
    
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


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Make sure all async operations complete before allowing the process to be suspended:
    [RESTOperation wait: rootViewController.database.activeOperations];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Make sure all async operations complete before quitting:
    [RESTOperation wait: rootViewController.database.activeOperations];
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
