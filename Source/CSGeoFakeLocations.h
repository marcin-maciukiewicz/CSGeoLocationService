//
//  CSFakeLocations.h
//  GeoLocationService
//
//  Created by Marcin Maciukiewicz on 13/05/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>

/**
 *
 */
@interface CSGeoFakeLocations : NSObject {
	
}

+(CSGeoFakeLocations*)sharedInstance;

// London 51.508056, -0.124722 (51°30′29″N 0°7′29″W)
-(CLLocation*)createCLLocation_UK_London;
// Warsaw 52.2323, 21.008433 (52° 13′ 56.28″ N, 21° 0′ 30.36″ E)
-(CLLocation*)createCLLocation_PL_Warsaw; 
// Kraków 50.061389, 19.938333 (50° 3′ 41″ N, 19° 56′ 18″ E)
-(CLLocation*)createCLLocation_PL_Cracow;
// Łódź 51.783333, 19.466667 (51° 47′ 0″ N, 19° 28′ 0″ E)
-(CLLocation*)createCLLocation_PL_Lodz;
// Gdańsk 54.366667, 18.633333 (54° 22′ 0″ N, 18° 38′ 0″ E)
-(CLLocation*)createCLLocation_PL_Gdansk;
// Wrocław 51.107778, 17.038333 (51° 6′ 28″ N, 17° 2′ 18″ E)
-(CLLocation*)createCLLocation_PL_Wroclaw;
// Bydgoszcz 53.116667, 18 (53° 7′ 0″ N, 18° 0′ 0″ E)
-(CLLocation*)createCLLocation_PL_Bydgoszcz;

@end