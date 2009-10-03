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


static BOOL layerIsBit( CALayer* layer )        {return [layer isKindOfClass: [Bit class]];}
static BOOL layerIsBitHolder( CALayer* layer )  {return [layer conformsToProtocol: @protocol(BitHolder)];}

///////////////////////////////////////////////////////////////////////////////
//
//    Private methods
//
///////////////////////////////////////////////////////////////////////////////
 
@interface ChessBoardViewController ()

- (void) _setHighlightCells:(BOOL)bHighlight;

- (void) _doPieceMove:(int)row1 fromCol:(int)col1 
                toRow:(int)row2 toCol:(int)col2
                 isAI:(BOOL)isAI;

- (void) _handleEndGameInUI;

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

/**
 * The designated initializer.
 * Override if you create the controller programmatically and want to perform
 * customization that is not appropriate for viewDidLoad.
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        audio_helper = [[AudioHelper alloc] init];
        [self install_cchess_sounds];
        _game = (CChessGame*)((ChessBoardView*)self.view).game;
        _moves = [[NSMutableArray alloc] initWithCapacity: POC_MAX_MOVES_PER_GAME];
    }
    
    return self;
}


- (void)ticked:(NSTimer*)timer
{
    if ( [_game get_sdPlayer] ) {
        // The opponent is AI, playing BLACK. Do nothing for now!
    } else {
        --_redTime;
        int m = _redTime / 60;
        int s = _redTime % 60;
        self_time.text = [NSString stringWithFormat:@"%d.%d",m,s];
    }
}

- (void)robotThread:(void*)param
{
 	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
    robot = [NSThread currentThread];
    //set the priority to the highest so that Robot can utilize more time to think
    [NSThread setThreadPriority:1.0f];
    // Let the run loop process things.
    do
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
								 beforeDate:[NSDate distantFuture]];
    }
    while (YES);
	
    [pool release];   
}

- (void)resetRobot:(id)restart
{
    [self reset_board];
    [activity stopAnimating];
    if(restart) {
        ticker = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(ticked:) userInfo:nil repeats:YES];
    }else{
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
    ticker = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self
                                            selector:@selector(ticked:)
                                            userInfo:nil repeats:YES];
    [NSThread detachNewThreadSelector:@selector(robotThread:) toTarget:self withObject:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    if(![ticker isValid]) {
         ticker = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self
                                                 selector:@selector(ticked:)
                                                 userInfo:nil repeats:YES];
    }
}

- (void)alertView: (UIAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    [self reset_board];
    ticker = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(ticked:) userInfo:nil repeats:YES];
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
    [audio_helper release];
    [activity release];
    [_moves release];
    [super dealloc];
}

- (IBAction)homePressed:(id)sender
{
    [activity setHidden:NO];
    [activity startAnimating];
    [self performSelector:@selector(resetRobot:) onThread:robot withObject:nil waitUntilDone:NO];
}

- (IBAction)resetPressed:(id)sender
{
    [activity setHidden:NO];
    [activity startAnimating];
    [self performSelector:@selector(resetRobot:) onThread:robot withObject:self waitUntilDone:NO];
}

static int moves[MAX_GEN_MOVES];
static int nMoves = 0;
static Piece *selected = nil;

#pragma mark AI move 
- (void)AIMove:(void*)unused_param
{
    int captured = 0;
    int m = [_game robotMoveWithCaptured:&captured];
    if (m == -1) {  // Invalid move.
        return;
    }
    
    int sqSrc = SRC(m);
    int sqDst = DST(m);
    int row = ROW(sqDst);
    int col = COLUMN(sqDst);
    [self _doPieceMove:ROW(sqSrc) fromCol:COLUMN(sqSrc) toRow:row toCol:col isAI:YES];
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
        if(!selected || (selected && selected._owner == piece._owner)) {
            int sqSrc = TOSQUARE(holder._row, holder._column);
            [self _setHighlightCells:NO]; // Clear old highlight.

            nMoves = [_game generateMoveFrom:sqSrc moves:moves];
            [self _setHighlightCells:YES];
            selected = piece;
            [audio_helper play_wav_sound:@"CLICK"];
            return;
        }
        
    } else {
        holder = (GridCell*)[view hitTestPoint:p LayerMatchCallback:layerIsBitHolder offset:NULL];
    }
    
    // Make a move from the last selected cell to the current selected cell.
    if(holder && holder._highlighted && selected != nil && nMoves > 0) {
        int sqDst = TOSQUARE(holder._row, holder._column);
        GridCell *cell = (GridCell*)selected.holder;
        int sqSrc = TOSQUARE(cell._row, cell._column);
        int m = MOVE(sqSrc, sqDst);
        if([_game isLegalMove:m])
        {
            [_game humanMove:cell._row fromCol:cell._column toRow:ROW(sqDst) toCol:COLUMN(sqDst)];
            [self _doPieceMove:cell._row fromCol:cell._column toRow:ROW(sqDst) toCol:COLUMN(sqDst) isAI:NO];
            // AI's turn.
            if ( _game.game_result == kXiangQi_InPlay ) {
                [self performSelector:@selector(AIMove:) onThread:robot withObject:nil waitUntilDone:NO];
            }
        }
    }
    
    selected = nil; // Reset selected state.
    [self _setHighlightCells:NO]; // Clear highlighted.
    nMoves = 0;
}


- (void)reset_board
{
    selected = nil;
    nMoves = 0;
    _redTime = _blackTime = _initialTime * 60;
    memset(moves, 0x0, sizeof(moves));
    self_time.text = [NSString stringWithFormat:@"%.2f",(float)_initialTime];
    opn_time.text = @"Robot";
    [ticker invalidate];
    [_game reset_game];
}

- (void)install_cchess_sounds
{
    [audio_helper load_wav_sound:@"CAPTURE"];
    [audio_helper load_wav_sound:@"CAPTURE2"];
    [audio_helper load_wav_sound:@"DRAW"];
    [audio_helper load_wav_sound:@"LOSS"];
    [audio_helper load_wav_sound:@"CLICK"];
    [audio_helper load_wav_sound:@"CHECK"];
    [audio_helper load_wav_sound:@"CHECK2"];
    [audio_helper load_wav_sound:@"MOVE"];
    [audio_helper load_wav_sound:@"MOVE2"];
    [audio_helper load_wav_sound:@"WIN"];
    [audio_helper load_wav_sound:@"ILLEGAL"];
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
    for(int i = 0; i < nMoves; ++i) {
        int sqDst = DST(moves[i]);
        int row = ROW(sqDst);
        int col = COLUMN(sqDst);
        if ( ! bHighlight ) {
            moves[i] = 0;
        }
        ((XiangQiSquare*)[_game._grid cellAtRow:row column:col])._highlighted = bHighlight;
    }
}


- (void) _doPieceMove:(int)row1 fromCol:(int)col1
                toRow:(int)row2 toCol:(int)col2
                 isAI:(BOOL)isAI
{
    NSString *sound = @"MOVE";

    Piece *capture = [_game x_getPieceAtRow:row2 col:col2];
    
    if (capture != nil) {
        [capture removeFromSuperlayer];
        sound = (isAI ? @"CAPTURE2" : @"CAPTURE");
    }

    if ( isAI ) {
        [audio_helper performSelectorOnMainThread:@selector(play_wav_sound:) 
                                       withObject:sound waitUntilDone:NO];
    } else {
        [audio_helper play_wav_sound:sound];
    }

    Piece *piece = [_game x_getPieceAtRow:row1 col:col1];
    [_game x_movePiece:piece toRow:row2 toCol:col2];
    
    // Check repeat status
    int nGameResult = [_game checkGameStatus:isAI];
    if ( nGameResult != kXiangQi_Unknown ) {  // Game Result changed?
        _game.game_result = nGameResult;
        
        [self performSelectorOnMainThread:@selector(_handleEndGameInUI)
                               withObject:nil waitUntilDone:NO];
    }
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

    [audio_helper play_wav_sound:sound];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PodChess"
                                                    message:msg
                                                   delegate:self 
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK", nil];
    [alert show];
    [alert release];
}

@end
