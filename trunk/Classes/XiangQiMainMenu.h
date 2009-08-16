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


@interface XiangQiMainMenu : UIViewController {
    IBOutlet UIButton *new_game;
    IBOutlet UIButton *about;
    IBOutlet UIButton *setting;
    
    IBOutlet UIImageView *bg_view;
}

@property(nonatomic,retain) IBOutlet UIButton *new_game;
@property(nonatomic,retain) IBOutlet UIButton *about;
@property(nonatomic,retain) IBOutlet UIButton *setting;
@property(nonatomic,retain) IBOutlet UIImageView *bg_view;

- (IBAction)newGamePressed:(id)sender;
- (IBAction)aboutPressed:(id)sender;
- (IBAction)settingPressed:(id)sender;

@end
