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

#import "ChessBoardViewController.h"
#import "Enums.h"
#import "PodChessAppDelegate.h"
#import "QuartzUtils.h"
#import "Bit.h"
#import "BitHolder.h"
#import "Grid.h"
#import "Piece.h"
#import "ChessBoardView.h"

enum _AlertViewEnum {
    POC_ALERT_END_GAME,
    POC_ALERT_RESUME_GAME
};

static BOOL layerIsBit( CALayer* layer )        {return [layer isKindOfClass: [Bit class]];}
static BOOL layerIsBitHolder( CALayer* layer )  {return [layer conformsToProtocol: @protocol(BitHolder)];}

///////////////////////////////////////////////////////////////////////////////
//
//    Private methods
//
///////////////////////////////////////////////////////////////////////////////
 
@interface ChessBoardViewController (PrivateMethods)

- (void) _setHighlightCells:(BOOL)bHighlight;
- (void) _onNewMove:(int)move fromAI:(BOOL)isAI;
- (void) _handleEndGameInUI;
- (void) _displayResumeGameAlert;
- (void) _loadPendingGame:(NSString *)sPendingGame;

@end


///////////////////////////////////////////////////////////////////////////////
//
//    Implementation of Public methods
//
///////////////////////////////////////////////////////////////////////////////

@implementation ChessBoardViewController

@synthesize home;
@synthesize reset;
@synthesize self_time;
@synthesize opn_time;
@synthesize movePrev;
@synthesize moveNext;

/**
 * The designated initializer.
 * Override if you create the controller programmatically and want to perform
 * customization that is not appropriate for viewDidLoad.
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _timer = nil;
        _audioHelper = [self _initSoundSystem];

        memset(_hl_moves, 0x0, sizeof(_hl_moves));
        _hl_nMoves = 0;
        _selectedPiece = nil;

        _game = (CChessGame*)((ChessBoardView*)self.view).game;
        _moves = [[NSMutableArray alloc] initWithCapacity: POC_MAX_MOVES_PER_GAME];

        // Restore pending game, if any.
        NSString *sPendingGame = [[NSUserDefaults standardUserDefaults] stringForKey:@"pending_game"];
        if ( sPendingGame != nil && [sPendingGame length]) {
            [self _displayResumeGameAlert];
        }
    }
    
    return self;
}


- (void)ticked:(NSTimer*)timer
{
    if ( [_game get_sdPlayer] ) {
        // The opponent is AI, playing BLACK. Do nothing for now!
    } else {
        --_redTime;
        int min = _redTime / 60;
        int sec = _redTime % 60;
        self_time.text = [NSString stringWithFormat:@"%d.%d", min, sec];
    }
}

- (void)robotThread:(void*)param
{
 	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
    robot = [NSThread currentThread];

    // Set the priority to the highest so that Robot can utilize more time to think
    [NSThread setThreadPriority:1.0f];
    
    do   // Let the run loop process things.
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
								 beforeDate:[NSDate distantFuture]];
    } while (YES);
	
    [pool release];   
}

- (void)resetRobot:(id)restart
{
    [activity stopAnimating];
    if(restart) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(ticked:) userInfo:nil repeats:YES];
    }else{
        //FIXME: in case of "resetRobot" is invoked before "AIMove", the app might crash thereafter due to the background AI 
        //       thinking is still on going. So trying to cancel the pending selector for AI thread 
        [[NSRunLoop currentRunLoop] cancelPerformSelectorsWithTarget:self];
        [((PodChessAppDelegate*)[[UIApplication sharedApplication] delegate]).navigationController popViewControllerAnimated:YES];
    }
}


/**
 * Implement viewDidLoad to do additional setup after loading the view,
 * typically from a nib.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    [activity setHidden:YES];
    [activity stopAnimating];
    [self.view bringSubviewToFront:activity];
    [self.view bringSubviewToFront:home];
    [self.view bringSubviewToFront:reset];
    [self.view bringSubviewToFront:self_time];
    [self.view bringSubviewToFront:opn_time];
    [self.view bringSubviewToFront:movePrev];
    [self.view bringSubviewToFront:moveNext];
    _initialTime = [[NSUserDefaults standardUserDefaults] integerForKey:@"time_setting"];
    _redTime = _blackTime = _initialTime * 60;
    [self_time setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:15.0]];
	[self_time setBackgroundColor:[UIColor clearColor]];
	[self_time setTextColor:[UIColor blackColor]];
    [opn_time setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:15.0]];
	[opn_time setBackgroundColor:[UIColor clearColor]];
	[opn_time setTextColor:[UIColor blackColor]];
    self_time.text = [NSString stringWithFormat:@"%.2f",(float)_initialTime];
    opn_time.text = @"Robot";
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self
                                            selector:@selector(ticked:)
                                            userInfo:nil repeats:YES];
    [NSThread detachNewThreadSelector:@selector(robotThread:) toTarget:self withObject:nil];
}

/**
 * Called when the view is about to made visible. Default does nothing
 */
- (void)viewWillAppear:(BOOL)animated
{
}

/**
 * Handle the "OK" button in the END-GAME and RESUME-GAME alert dialogs. 
 */
- (void)alertView: (UIAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    if ( alertView.tag == POC_ALERT_END_GAME ) {
        [self _resetBoard];
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(ticked:) userInfo:nil repeats:YES];
    }
    else if (    alertView.tag == POC_ALERT_RESUME_GAME
              && buttonIndex != [alertView cancelButtonIndex] ) {
        NSString *sPendingGame = [[NSUserDefaults standardUserDefaults] stringForKey:@"pending_game"];
        if ( sPendingGame != nil && [sPendingGame length]) {
            [self _loadPendingGame:sPendingGame];
        }
    }

}


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


- (void)dealloc
{
    [home release];
    [reset release];
    [self_time release];
    [opn_time release];
    [activity release];
    [movePrev release];
    [moveNext release];
    [_audioHelper release];
    [_moves release];
    [super dealloc];
}

#pragma mark Button actions

- (IBAction)homePressed:(id)sender
{
    [activity setHidden:NO];
    [activity startAnimating];
    [self performSelector:@selector(resetRobot:) onThread:robot withObject:nil waitUntilDone:NO];
    [self saveGame];
    // Not needed: [self _resetBoard];
}

- (IBAction)resetPressed:(id)sender
{
    [activity setHidden:NO];
    [activity startAnimating];
    [self performSelector:@selector(resetRobot:) onThread:robot withObject:self waitUntilDone:NO];
    [self _resetBoard];
}

- (IBAction)movePrevPressed:(id)sender
{
    NSLog(@"%s: ENTER.", __FUNCTION__);
}

- (IBAction)moveNextPressed:(id)sender
{
    NSLog(@"%s: ENTER.", __FUNCTION__);
}

#pragma mark AI move 
- (void)AIMove
{
    int move = [_game getRobotMove];
    if (move == INVALID_MOVE) {
        NSLog(@"ERROR: %s: Invalid move [%d].", __FUNCTION__, move); 
        return;
    }

    [self _onNewMove:move fromAI:YES];
}

#pragma mark Touch event handling
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Valid for single touch only
    if ([[event allTouches] count] != 1) {
        return;
    }
    
    ChessBoardView *view = (ChessBoardView*) self.view;
    GridCell *holder = nil;
    
    UITouch *touch = [[touches allObjects] objectAtIndex:0];
    CGPoint p = [touch locationInView:self.view];
    Piece *piece = (Piece*)[view hitTestPoint:p LayerMatchCallback:layerIsBit offset:NULL];
    if(piece) {
        // Generate moves for the selected piece.
        holder = (GridCell*)piece.holder;
        if(!_selectedPiece || (_selectedPiece && _selectedPiece._owner == piece._owner)) {
            int sqSrc = TOSQUARE(holder._row, holder._column);
            [self _setHighlightCells:NO]; // Clear old highlight.

            _hl_nMoves = [_game generateMoveFrom:sqSrc moves:_hl_moves];
            [self _setHighlightCells:YES];
            _selectedPiece = piece;
            [_audioHelper play_wav_sound:@"CLICK"];
            return;
        }
        
    } else {
        holder = (GridCell*)[view hitTestPoint:p LayerMatchCallback:layerIsBitHolder offset:NULL];
    }
    
    // Make a Move from the last selected cell to the current selected cell.
    if(holder && holder._highlighted && _selectedPiece != nil && _hl_nMoves > 0) {
        int sqDst = TOSQUARE(holder._row, holder._column);
        GridCell *cell = (GridCell*)_selectedPiece.holder;
        int sqSrc = TOSQUARE(cell._row, cell._column);
        int move = MOVE(sqSrc, sqDst);
        if([_game isLegalMove:move])
        {
            [_game humanMove:cell._row fromCol:cell._column toRow:ROW(sqDst) toCol:COLUMN(sqDst)];
            [self _onNewMove:move fromAI:NO];
            // AI's turn.
            if ( _game.game_result == kXiangQi_InPlay ) {
                [self performSelector:@selector(AIMove) onThread:robot withObject:nil waitUntilDone:NO];
            }
        }
    }
    
    _selectedPiece = nil; // Reset selected state.
    [self _setHighlightCells:NO]; // Clear highlighted.
    _hl_nMoves = 0;
}

- (void) _resetBoard
{
    _selectedPiece = nil;
    _hl_nMoves = 0;
    _redTime = _blackTime = _initialTime * 60;
    memset(_hl_moves, 0x0, sizeof(_hl_moves));
    self_time.text = [NSString stringWithFormat:@"%.2f",(float)_initialTime];
    opn_time.text = @"Robot";
    [_timer invalidate];
    [_game reset_game];
    [_moves removeAllObjects];
}

- (id) _initSoundSystem
{
    AudioHelper* audioHelper = [[AudioHelper alloc] init];

    if ( audioHelper != nil ) {
        NSArray *soundList = [NSArray arrayWithObjects:@"CAPTURE", @"CAPTURE2",
                              @"DRAW", @"LOSS", @"CHECK", @"CHECK2",
                              @"MOVE", @"MOVE2", @"WIN", @"ILLEGAL",
                              nil];
        for (NSString *sound in soundList) {
            [audioHelper load_wav_sound:sound];
        }
    }
    return audioHelper;
}


///////////////////////////////////////////////////////////////////////////////
//
//    Implementation of Private methods
//
///////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark Private methods

- (void) _setHighlightCells:(BOOL)bHighlight
{
    // Set (or Clear) highlighted cells.
    for(int i = 0; i < _hl_nMoves; ++i) {
        int sqDst = DST(_hl_moves[i]);
        int row = ROW(sqDst);
        int col = COLUMN(sqDst);
        if ( ! bHighlight ) {
            _hl_moves[i] = 0;
        }
        ((XiangQiSquare*)[_game._grid cellAtRow:row column:col])._highlighted = bHighlight;
    }
}

- (void) _onNewMove:(int)move fromAI:(BOOL)isAI
{
    int sqSrc = SRC(move);
    int sqDst = DST(move);

    int row1 = ROW(sqSrc);
    int col1 = COLUMN(sqSrc);
    int row2 = ROW(sqDst);
    int col2 = COLUMN(sqDst);
    
    NSString *sound = @"MOVE";

    Piece *capture = [_game x_getPieceAtRow:row2 col:col2];
    
    if (capture != nil) {
        [capture removeFromSuperlayer];
        sound = (isAI ? @"CAPTURE2" : @"CAPTURE");
    }

    if ( isAI ) {
        [_audioHelper performSelectorOnMainThread:@selector(play_wav_sound:) 
                                       withObject:sound waitUntilDone:NO];
    } else {
        [_audioHelper play_wav_sound:sound];
    }

    Piece *piece = [_game x_getPieceAtRow:row1 col:col1];
    [_game x_movePiece:piece toRow:row2 toCol:col2];
    
    // Check End-Game status.
    int nGameResult = [_game checkGameStatus:isAI];
    if ( nGameResult != kXiangQi_Unknown ) {  // Game Result changed?
        [self performSelectorOnMainThread:@selector(_handleEndGameInUI)
                               withObject:nil waitUntilDone:NO];
    }
    
    // Add this new Move to the Move-History.
    NSNumber *pMove = [NSNumber numberWithInteger:move];
    [_moves addObject:pMove];
}

- (void) _handleEndGameInUI
{
    NSString *sound = nil;
    NSString *msg   = nil;

    switch ( _game.game_result ) {
        case kXiangQi_YouWin:
            sound = @"WIN";
            msg = NSLocalizedString(@"You win,congratulations!", @"");
            break;
        case kXiangQi_ComputerWin:
            sound = @"LOSS";
            msg = NSLocalizedString(@"Computer wins. Don't give up, please try again!", @"");
            break;
        case kXiangqi_YouLose:
            sound = @"LOSS";
            msg = NSLocalizedString(@"You lose. You may try again!", @"");
            break;
        case kXiangQi_Draw:
            sound = @"DRAW";
            msg = NSLocalizedString(@"Sorry,we are in draw!", @"");
            break;
        case kXiangQi_OverMoves:
            sound = @"ILLEGAL";
            msg = NSLocalizedString(@"Sorry,we made too many moves, please restart again!", @"");
            break;
        default:
            break; /* Do nothing */
    }
    
    if ( !sound ) return;

    [_audioHelper play_wav_sound:sound];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PodChess"
                                                    message:msg
                                                   delegate:self 
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK", nil];
    alert.tag = POC_ALERT_END_GAME;
    [alert show];
    [alert release];
}

- (void) _displayResumeGameAlert
{
    UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"PodChess"
                                   message:NSLocalizedString(@"Resume game?", @"")
                                  delegate:self 
                         cancelButtonTitle:NSLocalizedString(@"No", @"")
                         otherButtonTitles:NSLocalizedString(@"Yes", @""), nil];
    alert.tag = POC_ALERT_RESUME_GAME;
    [alert show];
    [alert release];
}

- (void) saveGame
{
    NSMutableString *sMoves = [NSMutableString new];

    if ( _game.game_result == kXiangQi_InPlay ) {
        for (NSNumber *pMove in _moves) {
            if ([sMoves length]) [sMoves appendString:@","];
            [sMoves appendFormat:@"%d",[pMove integerValue]];
        }
    }

    [[NSUserDefaults standardUserDefaults] setObject:sMoves forKey:@"pending_game"];
    [sMoves release];
}

- (void) _loadPendingGame:(NSString *)sPendingGame
{
    NSArray *moves = [sPendingGame componentsSeparatedByString:@","];
    int move = 0;
    int sqSrc = 0;
    int sqDst = 0;
    int toggleTurn = 0;  // 0 = Human, 1 = AI

    for (NSNumber *pMove in moves) {
        move  = [pMove integerValue];
        sqSrc = SRC(move);
        sqDst = DST(move);

        [_game humanMove:ROW(sqSrc) fromCol:COLUMN(sqSrc)
                   toRow:ROW(sqDst) toCol:COLUMN(sqDst)];
        [self _onNewMove:move fromAI:( toggleTurn == 1 )];
        toggleTurn = 1 - toggleTurn;
    }
}
        
@end
