
/*
     File: LocationsAppDelegate.h
 Abstract: Application delegate to set up the Core Data stack and configure the view and navigation controllers.
  Version: 1.1
 */

#import <Couchbase/CouchbaseEmbeddedServer.h>
@class RootViewController, CouchServer;

@interface LocationsAppDelegate : NSObject <UIApplicationDelegate, CouchbaseDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
    RootViewController *rootViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) RootViewController *rootViewController;
@property (nonatomic, retain) UINavigationController *navigationController;

@property (nonatomic, retain) CouchServer *server;

@end
