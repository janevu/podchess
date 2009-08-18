/***************************************************************************
 *  Copyright 2009 Nevo Hua  <nevo.hua@playxiangqi.com>                    *
 *                                                                         * 
 *  This file is part of PodChess.                                         *
 *                                                                         *
 *  PodChess is free software: you can redistribute it and/or modify       *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, either version 3 of the License, or      *
 *  (at your option) any later version.                                    *
 *                                                                         *
 *  PodChess is distributed in the hope that it will be useful,            *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with PodChess.  If not, see <http://www.gnu.org/licenses/>.      *
 ***************************************************************************/


//
//  PodChessAppDelegate.m
//  PodChess
//

#import "PodChessAppDelegate.h"

@implementation PodChessAppDelegate

@synthesize window;
@synthesize navigationController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    

    // Override point for customization after application launch
    //set default preferences
    float setting = [[NSUserDefaults standardUserDefaults] floatForKey:@"difficulty_setting"];
    if(setting < 3.0f || setting > 64.0f)
        [[NSUserDefaults standardUserDefaults] setFloat:7.0f forKey:@"difficulty_setting"];
    setting = [[NSUserDefaults standardUserDefaults] floatForKey:@"time_setting"];
    if(setting < 30.0f || setting > 120.0f)
        [[NSUserDefaults standardUserDefaults] setFloat:60.0f forKey:@"time_setting"];
    
    [window addSubview:[navigationController view]];
    navigationController.navigationBarHidden = YES;
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
