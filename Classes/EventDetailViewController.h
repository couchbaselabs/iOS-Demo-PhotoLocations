
/*
     File: EventDetailViewController.h
 Abstract: The table view controller responsible for displaying the time, coordinates, and photo of an event, and allowing the user to select a photo for the event, or delete the existing photo.
 
  Version: 1.1
 */

@class Event;

@interface EventDetailViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
	Event *event;
	UILabel *timeLabel;
	UILabel *coordinatesLabel;
	UIButton *deletePhotoButton;
	UIImageView *photoImageView;
}

@property (nonatomic, retain) Event *event;

@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UILabel *coordinatesLabel;
@property (nonatomic, retain) IBOutlet UIButton *deletePhotoButton;
@property (nonatomic, retain) IBOutlet UIImageView *photoImageView;

- (IBAction)choosePhoto;
- (IBAction)deletePhoto;
- (void)updatePhotoInfo;

@end
