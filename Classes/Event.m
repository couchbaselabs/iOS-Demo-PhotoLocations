
/*
     File: Event.m
 Abstract: A class to represent an event containing geographical coordinates, a time stamp, and an image with a thumbnail. Every Event has a CouchDB document.
 
  Version: 1.1
 */

#import "Event.h"

#import <CouchCocoa/CouchCocoa.h>
#import <CouchCocoa/RESTBody.h>


static UIImage* MakeThumbnail(UIImage* image, CGFloat dimensions);


@implementation Event


- (id)initWithDatabase:(CouchDatabase*)database 
              latitude:(CLLocationDegrees)latitude
             longitude:(CLLocationDegrees)longitude
          creationDate:(NSDate*)creationDate {
    self = [super init];
    if (self) {
        NSDictionary* properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithDouble: latitude], @"latitude",
                                    [NSNumber numberWithDouble: longitude], @"longitude",
                                    [RESTBody JSONObjectWithDate: creationDate], @"creationDate",
                                    nil];
        document = [[database untitledDocument] retain];
        RESTOperation* op = [document putProperties: properties];
        if (![op wait]) {
            // TODO: report error
            NSLog(@"Creating Event document failed! %@", op.error);
        }
    }
    return self;
}


- (id)initWithDocument:(CouchDocument*)aDocument {
    self = [super init];
    if (self) {
        document = [aDocument retain];
    }
    return self;
}


- (void)dealloc {
    [document release];
    [thumbnail release];
    [super dealloc];
}


- (void) deleteDocument {
    [[document DELETE] start];
    [document release];
    document = nil;
}


- (NSDate*) creationDate {
    NSString* dateString = [document.properties objectForKey: @"creationDate"];
    return [RESTBody dateWithJSONObject: dateString];
}


- (NSNumber*) latitude {
    return [document.properties objectForKey: @"latitude"];
}


- (NSNumber*) longitude {
    return [document.properties objectForKey: @"longitude"];
}


- (UIImage*)thumbnail {
    // The thumbnail is stored inline as Base64-encoded data, because it's small.
    if (!thumbnail) {
        NSString* thumbnailBase64 = [document.properties objectForKey: @"thumbnail"];
        NSData* thumbnailData = [RESTBody dataWithBase64: thumbnailBase64];
        if (thumbnailData) {
            thumbnail = [[UIImage alloc] initWithData: thumbnailData];
        }
    }
    return thumbnail;
}


- (UIImage*)photo {
    // The photo is stored as an attachment, so it is fetched separately on demand.
    if (!checkedForPhoto) {
        checkedForPhoto = YES;
        CouchAttachment* attach = [document.currentRevision attachmentNamed: @"photo"];
        RESTOperation* op = [attach GET];
        if ([op isSuccessful]) {
            NSData* imageData = op.responseBody.content;
            photo = [[UIImage alloc] initWithData: imageData];
        }
    }
    return photo;
}


- (void)setPhoto:(UIImage *)newPhoto {
    if (checkedForPhoto && newPhoto == photo)
        return;
    [photo release];
    photo = [newPhoto retain];
    checkedForPhoto = YES;
    
    // Update the thumbnail image:
    [thumbnail release];
    thumbnail = nil;
    NSData* thumbnailData = nil;
    if (newPhoto) {
        thumbnail = [MakeThumbnail(newPhoto, 44) retain];
        thumbnailData = UIImageJPEGRepresentation(thumbnail, 0.5);
    }
    
    // Save the thumbnail inline:
    NSMutableDictionary* properties = [[document.properties mutableCopy] autorelease];
    [properties setValue:[RESTBody base64WithData:thumbnailData] forKey:@"thumbnail"];
    RESTOperation* op = [document putProperties:properties];
    if (![op wait]) {
        // TODO: Report error
        NSLog(@"Saving Event document failed! %@", op.error);
    }
    
    // Save the photo to an attachment, asynchronously:
    CouchAttachment* attach = [document.currentRevision createAttachmentWithName:@"photo"
                                                                            type:@"image/png"];
    if (newPhoto) {
        op = [attach PUT: UIImagePNGRepresentation(newPhoto) contentType: @"image/png"];
    } else {
        op = [attach DELETE];
    }
    [op onCompletion: ^{
        if (!op.isSuccessful) {
            // TODO: Report error
            NSLog(@"Saving Event photo attachment failed! %@", op.error);
        }
    }];
}


@end


/** Makes a shrunk-down copy of an image. */
static UIImage* MakeThumbnail(UIImage* image, CGFloat dimensions) {
    CGSize size = image.size;
    CGFloat ratio = dimensions / MAX(size.height, size.width);
    CGRect rect = CGRectMake(0.0, 0.0, ratio * size.width, ratio * size.height);
    
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage* thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return thumbnail;
}
