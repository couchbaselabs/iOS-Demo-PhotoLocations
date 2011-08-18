
/*
     File: EventDetailViewController.m
 Abstract: The table view controller responsible for displaying the time, coordinates, and photo of an event, and allowing the user to select a photo for the event, or delete the existing photo.
 
  Version: 1.1
 */

#import "EventDetailViewController.h"
#import "Event.h"


@implementation EventDetailViewController

@synthesize event, timeLabel, coordinatesLabel, deletePhotoButton, photoImageView;


#pragma mark -
#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// A date formatter for the creation date.
    static NSDateFormatter *dateFormatter = nil;
	if (dateFormatter == nil) {
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	}
	
	static NSNumberFormatter *numberFormatter;
	if (numberFormatter == nil) {
		numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[numberFormatter setMaximumFractionDigits:3];
	}
	
	timeLabel.text = [dateFormatter stringFromDate:[event creationDate]];
	
	NSString *coordinatesString = [[NSString alloc] initWithFormat:@"%@, %@",
							 [numberFormatter stringFromNumber:[event latitude]],
							 [numberFormatter stringFromNumber:[event longitude]]];
	coordinatesLabel.text = coordinatesString;
	[coordinatesString release];
	
	[self updatePhotoInfo];
}


- (void)viewDidUnload {
	
	self.timeLabel = nil;
	self.coordinatesLabel = nil;
	self.deletePhotoButton = nil;
	self.photoImageView = nil;
}


#pragma mark -
#pragma mark Editing the photo

- (IBAction)deletePhoto {
    [event setPhoto:nil];
	
	// Update the user interface appropriately.
	[self updatePhotoInfo];
}


- (IBAction)choosePhoto {
	
	// Show an image picker to allow the user to choose a new photo.
	
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	[self presentModalViewController:imagePicker animated:YES];
	[imagePicker release];
}



- (void)updatePhotoInfo {
	
	// Synchronize the photo image view and the text on the photo button with the event's photo.
	UIImage *image = event.photo;

	photoImageView.image = image;
	deletePhotoButton.enabled = (image != nil);
}


#pragma mark -
#pragma mark Image picker delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)selectedImage editingInfo:(NSDictionary *)editingInfo {
    // Update the database.
	event.photo = selectedImage;	
	// Update the user interface appropriately.
	[self updatePhotoInfo];

    [self dismissModalViewControllerAnimated:YES];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	// The user canceled -- simply dismiss the image picker.
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	
	[event release];
	[timeLabel release];
	[coordinatesLabel release];
	[deletePhotoButton release];
	[photoImageView release];

    [super dealloc];
}


@end
