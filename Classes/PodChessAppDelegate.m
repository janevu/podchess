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
#import "Enums.h"

@implementation PodChessAppDelegate

@synthesize window;
@synthesize navigationController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    

    // Override point for customization after application launch
    //set default preferences
    int nDifficulty = [[NSUserDefaults standardUserDefaults] integerForKey:@"difficulty_setting"];
    if (nDifficulty < 1 || nDifficulty > 10) {
        [[NSUserDefaults standardUserDefaults] setInteger:POC_AI_DIFFICULTY_DEFAULT forKey:@"difficulty_setting"];
    }
    int nGameTime = [[NSUserDefaults standardUserDefaults] integerForKey:@"time_setting"];
    if (nGameTime < 30 || nGameTime > 120) {
        [[NSUserDefaults standardUserDefaults] setInteger:POC_GAME_TIME_DEFAULT forKey:@"time_setting"];
        //this might be the first time run
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ToggleSound"];
        [[NSUserDefaults standardUserDefaults] setObject:@"AI_xqwlight" forKey:@"AI"];
    }
    
    [window addSubview:[navigationController view]];
    navigationController.navigationBarHidden = YES;
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
