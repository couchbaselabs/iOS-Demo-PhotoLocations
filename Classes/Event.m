
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


+ (Event*) eventWithDatabase:(CouchDatabase*)database 
                    latitude:(CLLocationDegrees)latitude
                   longitude:(CLLocationDegrees)longitude
                creationDate:(NSDate*)creationDate {
    NSDictionary* properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithDouble: latitude], @"latitude",
                                [NSNumber numberWithDouble: longitude], @"longitude",
                                [RESTBody JSONObjectWithDate: creationDate], @"creationDate",
                                nil];
    CouchDocument* document = [[database untitledDocument] retain];
    RESTOperation* op = [document putProperties: properties];
    if (![op wait]) {
        // TODO: report error
        NSLog(@"Creating Event document failed! %@", op.error);
        return nil;
    }
    return (Event*)[self modelForDocument:document];
}


- (void)dealloc {
    [thumbnail release];
    [super dealloc];
}


@dynamic latitude, longitude;


- (NSDate*) creationDate {
    NSString* dateString = [self getValueOfProperty: @"creationDate"];
    return [RESTBody dateWithJSONObject: dateString];
}


- (UIImage*)thumbnail {
    // The thumbnail is stored inline as Base64-encoded data, because it's small.
    if (!thumbnail) {
        NSString* thumbnailBase64 = [self getValueOfProperty: @"thumbnail"];
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
        CouchAttachment* attach = [self.document.currentRevision attachmentNamed: @"photo"];
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
    [self setValue:thumbnailData ofProperty:@"thumbnail"];
    
    // Save the photo to an attachment, asynchronously:
    CouchAttachment* attach = [self.document.currentRevision createAttachmentWithName:@"photo"
                                                                            type:@"image/png"];
    RESTOperation* op;
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
