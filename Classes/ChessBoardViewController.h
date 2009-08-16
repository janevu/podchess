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


#define TOSQUARE(row, col) (16 * ((row) + 3) + ((col) + 3))
#define COLUMN(sq) ((sq) % 16 - 3)
#define ROW(sq) ((sq) / 16 - 3)

@interface ChessBoardViewController : UIViewController {
    
    IBOutlet UIButton *home;
    IBOutlet UIButton *reset;
    
    IBOutlet UITextField *self_time;
    IBOutlet UITextField *opn_time;
    
    NSTimer *ticker;
    
    NSThread *robot;
    
    float r_total_time;
    float b_total_time;
}

@property (nonatomic, retain) IBOutlet UIButton *home;
@property (nonatomic, retain) IBOutlet UIButton *reset;

@property (nonatomic, retain) IBOutlet UITextField *self_time;
@property (nonatomic, retain) IBOutlet UITextField *opn_time;

- (IBAction)homePressed:(id)sender;
- (IBAction)resetPressed:(id)sender;

- (void)reset_board;

@end
