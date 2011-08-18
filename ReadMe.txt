
### PhotoLocations ###

===========================================================================
DESCRIPTION:

This sample illustrates an iOS application that uses Mobile Couchbase to store local data, including binary attachments. It is adapted from Apple's PhotoLocations sample app, with the CoreData model code replaced by CouchCocoa API calls.

The first screen displays a table view of events, which encapsulate a time stamp, a geographical location expressed in latitude and longitude, and the thumbnail of a picture for the event. The user can add and remove events using the first screen.

The data model is simple: Each event is a CouchDB document with attributes for the time stamp and location. The picture is stored as an attachment, so it can be retrieved separately from the document; but a small thumbnail is stored inline in the document (as a base64-encoded string) since it's needed whenever the event is shown.


===========================================================================
BUILD REQUIREMENTS:

Mac OS X v10.6.8 or later; Xcode 4.0 or later; iOS 4.0 or later.
Couchbase.framework (download from https://github.com/couchbaselabs/iOS-Couchbase)
CouchCocoa.framework (build from https://github.com/couchbaselabs/CouchCocoa)

Before building the app, copy Couchbase.framework and CouchCocoa.framework into the "Frameworks" subfolder.

===========================================================================
RUNTIME REQUIREMENTS:

iOS 4.0 or later.

===========================================================================
PACKAGING LIST:

View Controllers
----------------

RootViewController.{h,m}
The table view controller responsible for displaying the list of events, supporting additional functionality:
 * Addition of new new events;
 * Deletion of existing events using UITableView's tableView:commitEditingStyle:forRowAtIndexPath: method.


EventDetailViewController.{h,m}
EventDetailViewController.xib
The table view controller responsible for displaying the time, coordinates, and photo of an event, and allowing the user to select a photo for the event, or delete the existing photo.


Model
-----

Event.{h,m}
A class to represent an event containing geographical coordinates, a time stamp, and an image.


Application configuration
-------------------------

LocationsAppDelegate.{h,m}
Configures Mobile Couchbase and the first view controller.

MainWindow.xib
Loaded automatically by the application. Creates the application's delegate and window.
