
/*
     File: Event.h
 Abstract: A class to represent an event containing geographical coordinates, a time stamp, and an image with a thumbnail. Every Event has a CouchDB document.
 
  Version: 1.1
 */

#import <CoreLocation/CoreLocation.h>
@class CouchDatabase, CouchDocument;

@interface Event : NSObject  {
    CouchDocument* document;
    UIImage* photo;
    UIImage* thumbnail;
    BOOL checkedForPhoto;
}

/** Creates a brand-new event and adds a document for it to the database. */
- (id)initWithDatabase:(CouchDatabase*)database
              latitude:(CLLocationDegrees)latitude
             longitude:(CLLocationDegrees)longitude
          creationDate:(NSDate*)creationDate;

/** Instantiates an Event object for an already-existing document. */
- (id)initWithDocument:(CouchDocument*)document;

/** Deletes the event's document from the database permanently. */
- (void) deleteDocument;

@property (nonatomic, readonly) NSDate *creationDate;
@property (nonatomic, readonly) NSNumber* latitude;
@property (nonatomic, readonly) NSNumber* longitude;

@property (nonatomic, retain) UIImage *photo;
@property (nonatomic, readonly) UIImage *thumbnail;

@end

