# ChouChouKit

ChouChouKit is Query-rich frontend service consumer iOS Client to utilize back-end app chouchou developed by goibibo available at 
https://github.com/goibibo/chouchou

This is the official iOS data commnunication framework for GoIbibo's BAAS (Backend As A Service) framework. It is ARC compatible and is functional iOS 6 onwards.The framework also extensively supports the use of Blocks for developers to make use of the callbacks of network calls. ChouChouKit uses Apple's own NSURLConnection and NSJSONSerialization classes for data communication and JSON data parsing. 

In addition to data communication, the framework also supports offline Data storage using CouchBase Lite (a derivative of CouchDB, a document based storage format) for fast parsing, search and retrieval of local offline data. The framework is already added in the sourcecode. 

In addition to the standard `NSNotification`, it uses Tony Million's Reachability framework to detect Network availablility and take appropriate decisions accordingly.


## Requirements

To add the ChouChouKit to your project, you will link to add the framework and its derivative libraries to your project.
You can achieve this in two ways

I) If you've downloaded the source code and have not customized the the sourcecode

	1) Open the source code project "ChouChouKit.xcodeproj".
	2) Set the build target to "ChouChouKit_Other" in the top left panel of Xcode.
	3) Run the project, which will produce two files
		a) libChouChouKit.a  (visible in the "Products" group of the project in the left panel)
		b) ChouChouKit.framework (right click on the 'libChouChouKit.a' file and select 'Show in Finder'. You will find this file in the same folder )
	4)	Link ChouChouKit.framework in "Link Binary with Libraries" and add "libChouChouKit.a" to your project's target dependency.

II) Linking Project's sourcecode directly to your project
	1) Drag and drop the ChouChouKit.xcodeproj file to your project directly.
	2) Modify the project/sourcecode if needed.
	3)	Link ChouChouKit.framework in "Link Binary with Libraries" and add "libChouChouKit.a" to your project's target dependency.



Once you have added the `.h/m` files to your project, simply:

* Go to the `Project->TARGETS->Build Phases->Link Binary With Libraries`.
* Press the plus in the lower left of the list.
	* Add `SystemConfiguration.framework`.
	* Add `libz.dylib`.
	* Add `Security.framework`.
	* Add `CFNetwork.framework`.
	* Add `libsqlite3.dylib`.



Boom, you're done.

## Instantiating ChouChouKit in your project

In your AppDelegate.m , you will need to instantiate ChouChouKit to set the URL where the BAAS has been deployed, the key for your app and offline storage mechanism **

## Offline Storage

Offline Storage mechanism : Currently the offline storage is available using the CouchBaseLite format. Developers can extend this further by having their own storage mediums and methods. All such classes need to derive from ChouChouKit's "OfflineDataManager" class.

## Data Objects / Documents

ChouChouKit assumes all objects it interacts with Online/Offline are documents with certain properties. Ideally, on your remote server, these documents can be stored and retrieved as JSON objects. In iOS these objects are mapped to an NSObject class called the "ChouChouManagedObject" class. The JSON data is stored in a MutableDictionary called "contentData" within a "ChouChouManagedObject".

Developers deriving their custom objects will have to subclass their objects from the "ChouChouManagedObject" class. A sample ChouChouManagedObject derived class called "SampleObject" has been provided in the example project.

## Primary Functions

As with every data communication framework, ChouChouKit provides mechanisms to run CRUD operations on every ChouChouManagedObject. These methods can be customised/overridden to suit the developers' requirements and Online-Offline-Data-Merge logic.

## Tell the world

Head over to  [Projects using ChouChouKit] (https://github.com/goibibo/ChouChouKit) and let us know how you feel about our framework and how we can enhance this.

