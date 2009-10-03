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

#import "GenericSettingViewController.h"
#import "Enums.h"
#import "PodChessAppDelegate.h"

@implementation SettingViewController

@synthesize difficulty_setting;
@synthesize time_setting;
@synthesize default_setting;
@synthesize piece_style;
@synthesize sound_switch;

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
- (void)viewDidLoad 
{
    time_setting.minimumValue = 30.0f;
    time_setting.maximumValue = 120.0f;
    difficulty_setting.minimumValue = 1.0f;
    difficulty_setting.maximumValue = 10.0f;
    time_setting.value = (float)[[NSUserDefaults standardUserDefaults] integerForKey:@"time_setting"];
    difficulty_setting.value = (float)[[NSUserDefaults standardUserDefaults] integerForKey:@"difficulty_setting"];
    sound_switch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"toggle_sound"];
    BOOL toggleWestern = [[NSUserDefaults standardUserDefaults] boolForKey:@"toggle_western"];
    piece_style.selectedSegmentIndex = (toggleWestern ? 1 : 0);
    self.title = NSLocalizedString(@"General", @"");
    [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning 
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    [((PodChessAppDelegate*)[[UIApplication sharedApplication] delegate]).navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated 
{
    //save the setting before we leave setting page
    [[NSUserDefaults standardUserDefaults] setInteger:[difficulty_setting value] forKey:@"difficulty_setting"];
    [[NSUserDefaults standardUserDefaults] setInteger:[time_setting value] forKey:@"time_setting"];
    [[NSUserDefaults standardUserDefaults] setBool:sound_switch.on forKey:@"toggle_sound"];
    BOOL bToggleWestern = ( piece_style.selectedSegmentIndex == 1 );
    [[NSUserDefaults standardUserDefaults] setBool:bToggleWestern forKey:@"toggle_western"];
	[super viewWillDisappear:animated];
}

- (void)dealloc 
{
    [time_setting release];
    [difficulty_setting release];
    [default_setting release];
    [piece_style release];
    [sound_switch release];
    [super dealloc];
}

#pragma mark button event
- (IBAction)defaultSettingPressed:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setInteger:POC_AI_DIFFICULTY_DEFAULT forKey:@"difficulty_setting"];
    [[NSUserDefaults standardUserDefaults] setInteger:POC_GAME_TIME_DEFAULT forKey:@"time_setting"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"toggle_sound"];
    difficulty_setting.value = (float) POC_AI_DIFFICULTY_DEFAULT;
    time_setting.value = (float) POC_GAME_TIME_DEFAULT;
    sound_switch.on = YES;
    piece_style.selectedSegmentIndex = 0;
}


@end
