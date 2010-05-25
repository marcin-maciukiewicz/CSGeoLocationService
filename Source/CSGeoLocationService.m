//
//  FetchLocation.m
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

#import "CSGeoLocationService.h"
#import "GTMObjectSingleton.h"


@interface CSGeoLocationService (PrivateMethods)
	- (void)stopUpdatingLocation:(NSString *)state;
@end

#pragma mark -
@implementation CSGeoLocationService

static const double kCSGeoLocDefaultTimeout=15.0;
static const CLLocationDistance kCSGeoLocDefaultDistanceFilter=100;

@synthesize _locationManager;
@synthesize _currentLocation;
@synthesize _lastUpdate;
@synthesize _operationQueue;
@synthesize _pendingDelegates;
@synthesize fakeLocation;
//@synthesize timeout;
@synthesize _bestEffortAtLocation;

@dynamic	currentLocation;
@dynamic	desiredAccuracy;
@dynamic	distanceFilter;

#pragma mark -
#pragma mark Singleton definition
GTMOBJECT_SINGLETON_BOILERPLATE(CSGeoLocationService, sharedInstance);

#pragma mark -
#pragma mark Constructor and destructor
- (id) init {
	self = [super init];
	if (self != nil) {
		self._lastUpdate=[[NSDate alloc] init];
		self._locationManager = [[CLLocationManager alloc] init];
		self._locationManager.delegate=self;
		_locationManager.desiredAccuracy=kCLLocationAccuracyHundredMeters;
		_locationManager.distanceFilter=kCSGeoLocDefaultDistanceFilter;
		self._operationQueue=[[NSOperationQueue alloc] init];
		self._pendingDelegates=[[NSMutableArray alloc] init];
		
		[_locationManager startUpdatingLocation];
		[self performSelector:@selector(stopUpdatingLocation:) withObject:@"TimedOut" afterDelay:kCSGeoLocDefaultTimeout];
	}
	return self;
}

-(void)dealloc {
	[_locationManager release];
	[_currentLocation release];
	[_lastUpdate release];
	[_operationQueue release];
	[_pendingDelegates release];
	[fakeLocation release];
	[_bestEffortAtLocation release];
	
	[super dealloc];
}

#pragma mark -
-(BOOL)serviceEnabled {
	return _locationManager.locationServicesEnabled;
}

-(void)fetch:(id<CSGeoLocationServiceDelegate>) aDelegate {
	if(_currentLocation==nil){
		// use fake location if any
		self._currentLocation=fakeLocation;
	}
	
	if(_currentLocation!=nil){
		CLLocation *newLoc=[_currentLocation copy];
		[aDelegate performSelector:@selector(locationUpdate:) withObject:newLoc];
	} else {
		BOOL isEnabled=_locationManager.locationServicesEnabled;
		if(isEnabled){
			[_locationManager startUpdatingLocation];
			[_pendingDelegates addObject:aDelegate];			
		}else{
			[aDelegate locationServiceDisabled];
		}
	}
}

#pragma mark -
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    // test the age of the location measurement to determine if the measurement is cached
    // in most cases you will not want to rely on cached measurements
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return;
    // test that the horizontal accuracy does not indicate an invalid measurement
    if (newLocation.horizontalAccuracy < 0) return;
    // test the measurement to see if it is more accurate than the previous measurement
    if (_bestEffortAtLocation == nil || _bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
        // store the location as the "best effort"
        self._bestEffortAtLocation = newLocation;
        // test the measurement to see if it meets the desired accuracy
        //
        // IMPORTANT!!! kCLLocationAccuracyBest should not be used for comparison with location coordinate or altitidue 
        // accuracy because it is a negative value. Instead, compare against some predetermined "real" measure of 
        // acceptable accuracy, or depend on the timeout to stop updating. This sample depends on the timeout.
        //
        if (newLocation.horizontalAccuracy <= _locationManager.desiredAccuracy) {
            // we have a measurement that meets our requirements, so we can stop updating the location
            // 
            // IMPORTANT!!! Minimize power usage by stopping the location manager as soon as possible.
            //
            [self stopUpdatingLocation:@"GotLocation"];
            // we can also cancel our previous performSelector:withObject:afterDelay: - it's no longer necessary
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:@"TimedOut"];
			
			self._currentLocation=self._bestEffortAtLocation;
			// flush all the pending delegates
			for(id<CSGeoLocationServiceDelegate> delegate in _pendingDelegates) {
				@try {
					[delegate locationUpdate:_currentLocation];
				} @catch (NSException * exception) {
					NSLog(@"GeoLocFetchLocation: Caught exception: %@ %@",exception.name, exception.reason);
				}
			}
			[_pendingDelegates removeAllObjects];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // The location "unknown" error simply means the manager is currently unable to get the location.
    // We can ignore this error for the scenario of getting a single location fix, because we already have a 
    // timeout that will stop the location manager to save power.
    if ([error code] != kCLErrorLocationUnknown) {
        [self stopUpdatingLocation:@"Error"];
		
		// flush all the pending delegates
		for(id<CSGeoLocationServiceDelegate> delegate in _pendingDelegates) {
			@try {
				if([delegate respondsToSelector:@selector(locationError:)]){
					[delegate locationError:error];
				}
			} @catch (NSException * exception) {
				NSLog(@"GeoLocFetchLocation: Caught exception: %@ %@",exception.name, exception.reason);
			}
		}
		[_pendingDelegates removeAllObjects];
    }
}

- (void)stopUpdatingLocation:(NSString *)state {
	NSLog(@"stopUpdatingLocation: %@",state);
    [_locationManager stopUpdatingLocation];
    _locationManager.delegate = nil;
	
	if([state isEqualToString:@"TimedOut"]){
		// flush all the pending delegates
		for(id<CSGeoLocationServiceDelegate> delegate in _pendingDelegates) {
			@try {
				if([delegate respondsToSelector:@selector(locationTimedOut)]){
					[delegate locationTimedOut];
				}
			} @catch (NSException * exception) {
				NSLog(@"GeoLocFetchLocation: Caught exception: %@ %@",exception.name, exception.reason);
			}
		}
		[_pendingDelegates removeAllObjects];
	}
}

//- (void)locationManager:(CLLocationManager *)manager
//	didUpdateToLocation:(CLLocation *)newLocation
//		   fromLocation:(CLLocation *)oldLocation {
//	NSDate* eventDate = newLocation.timestamp;
//	NSTimeInterval howRecent = abs([eventDate timeIntervalSinceNow]);
//	_attempts++;    
//	
//	// is the location newer or not?
//	if((newLocation.coordinate.latitude != oldLocation.coordinate.latitude) && (newLocation.coordinate.longitude != oldLocation.coordinate.longitude))
//		_locationChanged = YES;
//	else
//		_locationChanged = NO;
//	
//#ifdef __i386__
//	// Don't care about simulator. It always points to the Apple HQ
//	if (howRecent < 5.0) {
//#else
//	// case 1: GPS sends at start 3 fast updates. Only the last one is accurate.
//	if((_locationChanged && (howRecent < 5.0) && _attempts==3) || 
//	   // case 2: this is position update when user moves. normal work.
//	   (_locationChanged && _attempts>=3)){
//#endif   
//		// use fake location?
//		if(fakeLocation){
//			self._currentLocation=fakeLocation;
//		} else {
//			self._currentLocation=newLocation;			
//		}
//
//		// flush all the waiting delegates
//		for(id<CSGeoLocationServiceDelegate> delegate in _pendingDelegates) {
//			@try {
//				[delegate locationUpdate:_currentLocation];
//			} @catch (NSException * exception) {
//				NSLog(@"GeoLocFetchLocation: Caught exception: %@ %@",exception.name, exception.reason);
//			}
//		}
//		[_locationManager stopUpdatingLocation];
//	}
//}

//- (void)locationManager:(CLLocationManager *)manager
//	   didFailWithError:(NSError *)error {
//		   
//   BOOL serviceEnabled=_locationManager.locationServicesEnabled;
//   if(serviceEnabled){
//	   NSLog(@"test");
//   }
//	// flush the pending operations
//	NSEnumerator *enumerator=[[NSArray arrayWithArray:_pendingDelegates] objectEnumerator];
//	[_pendingDelegates removeAllObjects];
//	id<CSGeoLocationServiceDelegate> delegate;
//	while(delegate=[enumerator nextObject]){
//		if([delegate respondsToSelector:@selector(locationError:)]){
//			[delegate locationError:error];
//		}
//	}	
//}

#pragma mark -
#pragma mark Dynamic accessors
-(CLLocation*)currentLocation {
	return _currentLocation;
}
	
-(CLLocationAccuracy)desiredAccuracy {
	return _locationManager.desiredAccuracy;
}

-(void)setDesiredAccuracy:(CLLocationAccuracy)newAccuracy {
	if(newAccuracy==_locationManager.desiredAccuracy) return;
	_locationManager.desiredAccuracy=newAccuracy;
}
	
	
-(CLLocationDistance)distanceFilter {
	return _locationManager.distanceFilter;
}
	
-(void)setDistanceFilter:(CLLocationDistance)newDistanceFilter {
	if(newDistanceFilter==_locationManager.distanceFilter) return;
	_locationManager.distanceFilter=newDistanceFilter;
}
	
@end
