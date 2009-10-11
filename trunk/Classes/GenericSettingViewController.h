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

#import <UIKit/UIKit.h>


@interface SettingViewController : UITableViewController {
    IBOutlet UISlider *difficulty_setting;
    IBOutlet UISlider *time_setting;

    IBOutlet UIButton *default_setting;
    IBOutlet UISegmentedControl *piece_style;
    IBOutlet UISwitch *sound_switch;
}

@property(nonatomic,retain) IBOutlet UISlider *difficulty_setting;
@property(nonatomic,retain) IBOutlet UISlider *time_setting;

@property(nonatomic,retain) IBOutlet UIButton *default_setting;

@property(nonatomic,retain) IBOutlet UISegmentedControl *piece_style;

@property(nonatomic,retain) IBOutlet UISwitch *sound_switch;

- (IBAction)defaultSettingPressed:(id)sender;

@end
