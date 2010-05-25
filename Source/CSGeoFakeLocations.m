//
//  CSFakeLocations.m
//  GeoLocationService
//
//  Created by Marcin Maciukiewicz on 13/05/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CSGeoFakeLocations.h"
#import "GTMObjectSingleton.h"

@implementation CSGeoFakeLocations

GTMOBJECT_SINGLETON_BOILERPLATE(CSGeoFakeLocations, sharedInstance)

-(CLLocation*)createCLLocation_UK_London {
	return [[CLLocation alloc] initWithLatitude:51.508056 longitude:-0.124722];	
}

-(CLLocation*)createCLLocation_PL_Warsaw {
	return [[CLLocation alloc] initWithLatitude: 52.2323 longitude:21.008433];	
}

-(CLLocation*)createCLLocation_PL_Cracow {
	return [[CLLocation alloc] initWithLatitude:50.061389 longitude:19.938333];	
}

-(CLLocation*)createCLLocation_PL_Lodz {
	return [[CLLocation alloc] initWithLatitude:51.783333 longitude:19.466667];	
}

-(CLLocation*)createCLLocation_PL_Gdansk {
	return [[CLLocation alloc] initWithLatitude:54.366667 longitude:18.633333];	
}

-(CLLocation*)createCLLocation_PL_Wroclaw {
	return [[CLLocation alloc] initWithLatitude:51.107778 longitude:17.038333];	
}

-(CLLocation*)createCLLocation_PL_Bydgoszcz {
	return [[CLLocation alloc] initWithLatitude:53.116667 longitude:18.0];	
}

@end
