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
#import "PodChessAppDelegate.h"
#import "QuartzUtils.h"
#import "Bit.h"
#import "BitHolder.h"
#import "Grid.h"
#import "Piece.h"
#import "XiangQi.h"
#import "CChessGame.h"
#import "ChessBoardView.h"

#define MAX_MOVES_IN_GAME 100

enum GameEnd {
    kComputerWin,
    kYouWin,
    kDraw
};

static BOOL layerIsBit( CALayer* layer )        {return [layer isKindOfClass: [Bit class]];}
static BOOL layerIsBitHolder( CALayer* layer )  {return [layer conformsToProtocol: @protocol(BitHolder)];}

///////////////////////////////////////////////////////////////////////////////
//
//    Private methods
//
///////////////////////////////////////////////////////////////////////////////
 
@interface ChessBoardViewController ()

- (void) _setHighlightCells: (CChessGame *)game highlighted:(BOOL)bHighlight;

- (void) _doPieceMove: (Piece *)piece 
                toRow:(int)row toCol:(int)col
        capturedPiece:(Piece *)capture
                 isAI:(BOOL)isAI;

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
    }
    
    return self;
}


- (void)ticked:(NSTimer*)timer
{
    CChessGame *game = (CChessGame*)((ChessBoardView*)self.view).game;
    if(game.engine.sd_player) {
        //opponent - black
        //        b_total_time -= 1.0;
        //        m = (int)b_total_time / 60;
        //        s = (int)b_total_time % 60;
        //        opn_time.text = [NSString stringWithFormat:@"%d.%d",m,s];
    } else {
        r_total_time -= 1.0;
        int m = (int)r_total_time / 60;
        int s = (int)r_total_time % 60;
        self_time.text = [NSString stringWithFormat:@"%d.%d",m,s];
    }
}

- (void)robotThread:(void*)param
{
 	NSAutoreleasePool*  pool = [[NSAutoreleasePool alloc] init];
	
    robot = [NSThread currentThread];
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
    //place holder
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
    r_total_time = b_total_time = floor([[NSUserDefaults standardUserDefaults]floatForKey:@"time_setting"]) * 60.0f;
    [self_time setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:15.0]];
	[self_time setBackgroundColor:[UIColor clearColor]];
	[self_time setTextColor:[UIColor blackColor]];
    [opn_time setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:15.0]];
	[opn_time setBackgroundColor:[UIColor clearColor]];
	[opn_time setTextColor:[UIColor blackColor]];
    self_time.text = [NSString stringWithFormat:@"%.2f",floor([[NSUserDefaults standardUserDefaults]floatForKey:@"time_setting"])];
    opn_time.text = @"Robot";
    ticker = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(ticked:) userInfo:nil repeats:YES];
    [NSThread detachNewThreadSelector:@selector(robotThread:) toTarget:self withObject:nil];
    
    CChessGame *game = (CChessGame*)((ChessBoardView*)self.view).game;
    [game addObserver: self 
           forKeyPath: @"game_result"
              options: (NSKeyValueObservingOptionNew |
                        NSKeyValueObservingOptionOld)
              context: NULL];
}

- (void)viewWillAppear:(BOOL)animated
{
    if(![ticker isValid]) {
         ticker = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(ticked:) userInfo:nil repeats:YES];
    }
}

#pragma mark game result change notification handler
- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary *)change
                       context:(void *)context
{
    CChessGame *game = (CChessGame*)((ChessBoardView*)self.view).game;
    UIAlertView *alert = [UIAlertView alloc]; 
    
    if( object == game ) {
        switch(game.game_result) {
            case kXiangQi_YouWin:
                [audio_helper play_wav_sound:@"WIN"];
                [alert initWithTitle:@"PodChess"
                             message:@"You win,congratulations!"
                            delegate:self 
                   cancelButtonTitle:nil 
                   otherButtonTitles:@"OK", nil];
                break;
            case kXiangQi_ComputerWin:
                [audio_helper play_wav_sound:@"LOSS"];
                [alert initWithTitle:@"PodChess"
                             message:@"Computer wins. Don't give up, please try again!"
                            delegate:self 
                   cancelButtonTitle:nil 
                   otherButtonTitles:@"OK", nil];
                break;
            case kXiangqi_YouLose:
                [audio_helper play_wav_sound:@"LOSS"];
                [alert initWithTitle:@"PodChess"
                             message:@"You lose. You may try again!"
                            delegate:self 
                   cancelButtonTitle:nil 
                   otherButtonTitles:@"OK", nil];
                break;
            case kXiangQi_Draw:
                [audio_helper play_wav_sound:@"DRAW"];
                [alert initWithTitle:@"PodChess"
                             message:@"Sorry,we are in draw!"
                            delegate:self 
                   cancelButtonTitle:nil 
                   otherButtonTitles:@"OK", nil];
                break;
            case kXiangQi_OverMoves:
                [audio_helper play_wav_sound:@"ILLEGAL"];
                [alert initWithTitle:@"PodChess"
                             message:@"Sorry,we made too many moves, please restart again!"
                            delegate:self 
                   cancelButtonTitle:nil 
                   otherButtonTitles:@"OK", nil];
                break;
            case kXiangQi_InPlay:
                break;
        }
        
        [alert show];	
        [alert release];	
    }
}

- (void)alertView: (UIAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    [self reset_board];
    ticker = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(ticked:) userInfo:nil repeats:YES];
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


- (void)dealloc
{
    [home release];
    [reset release];
    [self_time release];
    [opn_time release];
    [audio_helper release];
    [activity release];
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
    CChessGame *game = (CChessGame*)((ChessBoardView*)self.view).game;
    int captured = 0;
    int m = [game RobotMoveWithCaptured:&captured];
    if (m == -1) {  // Invalid move.
        return;
    }
    
    int sqSrc = SRC(m);
    int sqDst = DST(m);
    Piece *piece = [game x_getPieceAtRow:ROW(sqSrc) col:COLUMN(sqSrc)];
    int row = ROW(sqDst);
    int col = COLUMN(sqDst);
    Piece *capture = [game x_getPieceAtRow:row col:col];
    [self _doPieceMove:piece toRow:row toCol:col capturedPiece:capture isAI:YES];
}

#pragma mark Touch event handling
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Valid for single touch only
    if ([[event allTouches] count] != 1) {
        return;
    }
    
    ChessBoardView *view = (ChessBoardView*) self.view;
    CChessGame *game = (CChessGame*) view.game;
    GridCell *holder = nil;
    
    UITouch *touch = [[touches allObjects] objectAtIndex:0];
    CGPoint p = [touch locationInView:self.view];
    Piece *piece = (Piece*)[view hitTestPoint:p LayerMatchCallback:layerIsBit offset:NULL];
    if(piece) {
        // Generate moves for the selected piece.
        holder = (GridCell*)piece.holder;
        if(!selected || (selected && selected._owner == piece._owner)) {
            int sqSrc = TOSQUARE(holder._row, holder._column);
            [self _setHighlightCells:game highlighted:NO]; // Clear old highlight.
            
            nMoves = [game.engine generate_moves:moves square:sqSrc];
            [self _setHighlightCells:game highlighted:YES];
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
        if([game.engine legal_move:m]) {
            if ( [game humanMove:cell._row fromCol:cell._column toRow:ROW(sqDst) toCol:COLUMN(sqDst)] ) {
                [self _doPieceMove:selected toRow:ROW(sqDst) toCol:COLUMN(sqDst)
                     capturedPiece:piece isAI:NO];
                // AI's turn.
                [self performSelector:@selector(AIMove:) onThread:robot withObject:nil waitUntilDone:NO];
            }
        }
    }
    
    selected = nil; // Reset selected state.
    [self _setHighlightCells:game highlighted:NO]; // Clear highlighted.
    nMoves = 0;
}


- (void)reset_board
{
    CChessGame *game = (CChessGame*)((ChessBoardView*)self.view).game;
    selected = nil;
    nMoves = 0;
    r_total_time = b_total_time = floor([[NSUserDefaults standardUserDefaults]floatForKey:@"time_setting"]) * 60.0f;
    memset(moves, 0x0, MAX_GEN_MOVES);
    self_time.text = [NSString stringWithFormat:@"%.2f",floor([[NSUserDefaults standardUserDefaults]floatForKey:@"time_setting"])];;
    opn_time.text = @"Robot";
    [ticker invalidate];
    [game reset_game];
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

- (void) _setHighlightCells: (CChessGame *)game highlighted:(BOOL)bHighlight
{    
    assert(game);
    // Set (or Clear) highlighted cells.
    for(int i = 0; i < nMoves; ++i) {
        int sqDst = DST(moves[i]);
        int row = ROW(sqDst);
        int col = COLUMN(sqDst);
        if ( ! bHighlight ) {
            moves[i] = 0;
        }
        ((XiangQiSquare*)[game._grid cellAtRow:row column:col])._highlighted = bHighlight;
    }
}


- (void) _doPieceMove: (Piece *)piece
                toRow:(int)row toCol:(int)col
        capturedPiece:(Piece *)capture
                 isAI:(BOOL)isAI
{
    ChessBoardView *view = (ChessBoardView*) self.view;
    CChessGame *game = (CChessGame*) view.game;
    NSString *sound = @"MOVE";

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

    [game x_movePiece:piece toRow:row toCol:col];
    
    // Check repeat status
    int vlRep = [game.engine rep_status:3];
    if([game.engine is_mate]) {
        game.game_result = (isAI ? kXiangQi_ComputerWin : kXiangQi_YouWin); 
    } else if(vlRep > 0) {
        //长打
        vlRep = [game.engine rep_value:vlRep];
        
        if (isAI) {
            game.game_result = vlRep < -WIN_VALUE ? kXiangQi_ComputerWin 
                                                  : (vlRep > WIN_VALUE ? kXiangQi_YouWin : kXiangQi_Draw);
        } else {
            game.game_result = vlRep > WIN_VALUE ? kXiangQi_ComputerWin 
                                                 : (vlRep < -WIN_VALUE ? kXiangQi_YouWin : kXiangQi_Draw);
        }
    } else if(game.engine.nMoveNum > MAX_MOVES_IN_GAME) {
        // Too many moves
        game.game_result = kXiangQi_OverMoves;	 
    } else {
        // Normal move.
        if(capture != nil) {
            [game.engine set_irrev];
        }
    }
}

@end
