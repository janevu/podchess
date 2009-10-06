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
#import "CChessGame.h"
#import "AudioHelper.h"

@interface ChessBoardViewController : UIViewController {
    
    IBOutlet UIButton *home;
    IBOutlet UIButton *reset;
    
    IBOutlet UITextField *self_time;
    IBOutlet UITextField *opn_time;
    
    IBOutlet UIActivityIndicatorView *activity;
    
    /*move review UI*/
    IBOutlet UISlider *moveSlider;
    IBOutlet UILabel *moveLabel;
    IBOutlet UIButton *moveForward;
    IBOutlet UIButton *moveBackward;
    IBOutlet UIButton *firstMove;
    IBOutlet UIButton *lastMove;
    
    NSTimer *_timer;

    NSThread *robot;

    AudioHelper *_audioHelper;
    
    /* Members to keep track of (H)igh(L)ight moves (e.g., move-hints). */
    int    _hl_moves[MAX_GEN_MOVES];
    int    _hl_nMoves;

    Piece *_selectedPiece;
    
    CChessGame *_game;

    int _initialTime; /* The initial time (in seconds) */
    int _redTime;     /* RED   time (in seconds)       */
    int _blackTime;   /* BLACK time (in seconds)       */
    
    NSMutableArray *_moves;  /* MOVE history    */
}

@property (nonatomic, retain) IBOutlet UIButton *home;
@property (nonatomic, retain) IBOutlet UIButton *reset;

@property (nonatomic, retain) IBOutlet UITextField *self_time;
@property (nonatomic, retain) IBOutlet UITextField *opn_time;

@property (nonatomic, retain) IBOutlet UISlider *moveSlider;
@property (nonatomic, retain) IBOutlet UILabel *moveLabel;
@property (nonatomic, retain) IBOutlet UIButton *moveForward;
@property (nonatomic, retain) IBOutlet UIButton *moveBackward;
@property (nonatomic, retain) IBOutlet UIButton *firstMove;
@property (nonatomic, retain) IBOutlet UIButton *lastMove;

- (IBAction)homePressed:(id)sender;
- (IBAction)resetPressed:(id)sender;
- (IBAction)moveForwardPressed:(id)sender;
- (IBAction)moveBackwardPressed:(id)sender;
- (IBAction)firstMovePressed:(id)sender;
- (IBAction)lastMovePressed:(id)sender;
- (IBAction)sliderAction:(id)sender;

- (void) saveGame;

- (void) _resetBoard;
- (id)   _initSoundSystem;

@end
