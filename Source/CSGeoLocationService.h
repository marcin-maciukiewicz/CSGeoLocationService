//
//  FetchLocation.h
//
//	Copyright 2009 Marcin Maciukiewicz (mm@csquirrel.com)
//
//	Licensed under the Apache License, Version 2.0 (the "License");
//	you may not use this file except in compliance with the License.
//	You may obtain a copy of the License at
//
//	http://www.apache.org/licenses/LICENSE-2.0
//
//	Unless required by applicable law or agreed to in writing, software
//	distributed under the License is distributed on an "AS IS" BASIS,
//	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//	See the License for the specific language governing permissions and
//	limitations under the License.
//

#import <CoreLocation/CoreLocation.h>

#pragma mark -
/**
 * Receiver for the events from the GeoLocationService.
 */
@protocol CSGeoLocationServiceDelegate <NSObject>
	@required
	/** New GPS location. */
	-(void)locationUpdate:(CLLocation *)newLocation;
@optional
	/** Error while acquiring location. */
	-(void)locationError:(NSError*)error;
	/** Location serice is not available. */
	-(void)locationServiceDisabled;
	/** */
	-(void)locationTimedOut;
@end


#pragma mark -
/**
 * Geo location service singleton.
 * Provides access to geographical location details.
 */
@interface CSGeoLocationService : NSObject <CLLocationManagerDelegate> {
	CLLocationManager			*_locationManager;
	CLLocation					*_currentLocation;
	NSOperationQueue			*_operationQueue;
	NSMutableArray				*_pendingDelegates;
	NSDate						*_lastUpdate;
	NSUInteger					_attempts;
	BOOL						_locationChanged;
	
	@public
	//! Fake location. Use it for debugging purposes only.
	CLLocation					*fakeLocation;	
	//! Current GPS location or nil if unknown.
	CLLocation					*currentLocation;
	//! Desired accuracy (see: CLLocationManager.desiredAccuracy)
	CLLocationAccuracy			desiredAccuracy;
	//! Distance filter (see: CLLocationManager.distanceFilter)
	CLLocationDistance			distanceFilter;
	//!
//	double						timeout;
	
	CLLocation					*_bestEffortAtLocation;
}

	@property (nonatomic, assign)		CLLocationManager	*_locationManager;
	@property (nonatomic, assign)		CLLocation			*_currentLocation;
	@property (nonatomic, assign)		NSDate				*_lastUpdate;
	@property (nonatomic, assign)		NSOperationQueue	*_operationQueue;
	@property (nonatomic, assign)		NSMutableArray		*_pendingDelegates;
//
	@property (nonatomic, retain)		CLLocation			*fakeLocation;
	@property (nonatomic, readonly)		CLLocation			*currentLocation;
	@property							CLLocationAccuracy	desiredAccuracy;
	@property							CLLocationDistance	distanceFilter;
//	@property							double				timeout;
	@property (nonatomic, retain)		CLLocation			*_bestEffortAtLocation;

	/** Provides instance of the service. */
	+(CSGeoLocationService *) sharedInstance;

	/** 
	 * Ask the service for GPS location. The callback will be called only once as soon as location is known.
	 * Useful if you want to know the current position (e.g. sending location to Twitter) not recording route.
	 */
	-(void)fetch:(id<CSGeoLocationServiceDelegate>) callback;

	/** Is the service enabled? */
	-(BOOL)serviceEnabled;

@end
