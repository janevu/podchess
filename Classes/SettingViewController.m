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

#import "SettingViewController.h"
#import "PodChessAppDelegate.h"

@implementation SettingViewController

@synthesize difficulty_setting;
@synthesize time_setting;
@synthesize home;
@synthesize default_setting;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    time_setting.minimumValue = 30.0f;
    time_setting.maximumValue = 120.0f;
    difficulty_setting.minimumValue = 3.0f;
    difficulty_setting.maximumValue = 64.0f;
    time_setting.value = [[NSUserDefaults standardUserDefaults] floatForKey:@"time_setting"];
    difficulty_setting.value = [[NSUserDefaults standardUserDefaults] floatForKey:@"difficulty_setting"];
    [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [time_setting release];
    [difficulty_setting release];
    [home release];
    [default_setting release];
    [super dealloc];
}

#pragma mark button event
- (IBAction)homePressed:(id)sender
{
    //save the setting before we leave setting page
    [[NSUserDefaults standardUserDefaults] setFloat:[difficulty_setting value] forKey:@"difficulty_setting"];
    [[NSUserDefaults standardUserDefaults] setFloat:[time_setting value] forKey:@"time_setting"];
    [((PodChessAppDelegate*)[[UIApplication sharedApplication] delegate]).navigationController popViewControllerAnimated:YES];
}

- (IBAction)defaultSettingPressed:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setFloat:7.0f forKey:@"difficulty_setting"];
    [[NSUserDefaults standardUserDefaults] setFloat:60.0f forKey:@"time_setting"];
    difficulty_setting.value = 7.0f;
    time_setting.value = 60.0f;
}


@end
