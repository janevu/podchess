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


enum GameEnd {
    kComputerWin,
    kYouWin,
    kDraw
};

static BOOL layerIsBit( CALayer* layer )        {return [layer isKindOfClass: [Bit class]];}
static BOOL layerIsBitHolder( CALayer* layer )  {return [layer conformsToProtocol: @protocol(BitHolder)];}

@implementation ChessBoardViewController

@synthesize home;
@synthesize reset;
@synthesize self_time;
@synthesize opn_time;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (void)ticked:(NSTimer*)timer
{
    int m,s;
    CChessGame *game = (CChessGame*)((ChessBoardView*)self.view).game;
    if(game.engine.sd_player) {
        //opponent - black
        //        b_total_time -= 1.0;
        //        m = (int)b_total_time / 60;
        //        s = (int)b_total_time % 60;
        //        opn_time.text = [NSString stringWithFormat:@"%d.%d",m,s];
    } else {
        r_total_time -= 1.0;
        m = (int)r_total_time / 60;
        s = (int)r_total_time % 60;
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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view bringSubviewToFront:home];
    [self.view bringSubviewToFront:reset];
    [self.view bringSubviewToFront:self_time];
    [self.view bringSubviewToFront:opn_time];
    r_total_time = b_total_time = 3600.0;
    [self_time setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:15.0]];
	[self_time setBackgroundColor:[UIColor clearColor]];
	[self_time setTextColor:[UIColor blackColor]];
    [opn_time setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:15.0]];
	[opn_time setBackgroundColor:[UIColor clearColor]];
	[opn_time setTextColor:[UIColor blackColor]];
    self_time.text = @"60.0";
    opn_time.text = @"Computer";
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
                [alert initWithTitle:@"PodChess"
                             message:@"You win,congratulations!"
                            delegate:self 
                   cancelButtonTitle:nil 
                   otherButtonTitles:@"OK", nil];
                break;
            case kXiangQi_ComputerWin:
                [alert initWithTitle:@"PodChess"
                             message:@"Computer wins. Don't give up, please try again!"
                            delegate:self 
                   cancelButtonTitle:nil 
                   otherButtonTitles:@"OK", nil];
                break;
            case kXiangqi_YouLose:
                [alert initWithTitle:@"PodChess"
                             message:@"You lose. You may try again!"
                            delegate:self 
                   cancelButtonTitle:nil 
                   otherButtonTitles:@"OK", nil];
                break;
            case kXiangQi_Draw:
                [alert initWithTitle:@"PodChess"
                             message:@"Sorry,we are in draw!"
                            delegate:self 
                   cancelButtonTitle:nil 
                   otherButtonTitles:@"OK", nil];
                break;
            case kXiangQi_OverMoves:
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
    [home release];
    [reset release];
    [self_time release];
    [opn_time release];
    [super dealloc];
}

- (IBAction)homePressed:(id)sender
{
    [((PodChessAppDelegate*)[[UIApplication sharedApplication] delegate]).navigationController popViewControllerAnimated:YES];
    [self reset_board];
}

- (IBAction)resetPressed:(id)sender
{
    [self reset_board];
     ticker = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(ticked:) userInfo:nil repeats:YES];
}

static int moves[MAX_GEN_MOVES];
static int nMoves = 0;
static Piece *selected = nil;

#pragma mark  AI move 
- (void)AIMove:(void*)param
{
    int m, vlRep;
    int sqSrc, dstSq, col, row;
    int captured;
    Piece *piece = (Piece*)param; 
    Piece *ai_selected;
    CChessGame *game = (CChessGame*)((ChessBoardView*)self.view).game;
    m = [game RobotMoveWithCaptured:&captured];
    //check repeat status
    vlRep = [game.engine rep_status:3];
    if([game.engine is_mate]) {
        //computer wins
        game.game_result = kXiangQi_ComputerWin;	
        
    } else if(vlRep > 0) {
        //长打
        vlRep = [game.engine rep_value:vlRep];
        game.game_result = vlRep < -WIN_VALUE ? kXiangQi_ComputerWin : (vlRep > WIN_VALUE ? kXiangQi_YouWin : kXiangQi_Draw);
    } else if(game.engine.nMoveNum > 100) {
        //too many moves
        game.game_result = kXiangQi_OverMoves;
    }  else {
        sqSrc = SRC(m);
        dstSq = DST(m);
        row = ROW(sqSrc);
        col = COLUMN(sqSrc);
        ai_selected = [game x_getPieceAtRow:row col:col];
        if(ai_selected) {
            row = ROW(dstSq);
            col = COLUMN(dstSq);
            if(captured) {
                [game.engine set_irrev];
                piece = [game x_getPieceAtRow:row col:col];
                if(piece) {
                    [piece removeFromSuperlayer];
                }
            }
            [game x_movePiece:ai_selected toRow:row toCol:col];
        }
    }
    
}

#pragma mark touch event handling
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    int i;
    GridCell *holder;
    Piece *piece;
    CChessGame *game = (CChessGame*)((ChessBoardView*)self.view).game;
    if([[event allTouches] count] == 1) {
        //be valid for single touch only
        UITouch *touch = [[touches allObjects] objectAtIndex:0];
		CGPoint p = [touch locationInView:self.view];
        piece = (Piece*)[(ChessBoardView*)self.view hitTestPoint:p
                        LayerMatchCallback:layerIsBit
                                    offset:NULL];
        if(piece) {
            //we may generate moves for selected piece
            holder = (GridCell*)piece.holder;
            if(!selected || (selected && selected._owner == piece._owner)) {
                int sqSrc = TOSQUARE(holder._row, holder._column);
                //clear the previous highlighted cells
                for(i = 0; i < nMoves; i++) {
                    int m = moves[i];
                    int dstSq = DST(m);
                    int row = ROW(dstSq);
                    int col = COLUMN(dstSq);
                    moves[i] = 0;
                    ((XiangQiSquare*)[game._grid cellAtRow:row column:col])._highlighted = NO;
                }
                
                nMoves = [game.engine generate_moves:moves square:sqSrc];
                for(i = 0; i < nMoves; i++) {
                    int m = moves[i];
                    int dstSq = DST(m);
                    int row = ROW(dstSq);
                    int col = COLUMN(dstSq);
                    ((XiangQiSquare*)[game._grid cellAtRow:row column:col])._highlighted = YES;
                }
                selected = piece;
                return;
            }
            
        } else {
            holder = (GridCell*)[(ChessBoardView*)self.view hitTestPoint:p
                                LayerMatchCallback:layerIsBitHolder
                                            offset:NULL];
        }
        if(holder && holder._highlighted && selected != nil && nMoves > 0) {
            //make a move to this
            int dstSq = TOSQUARE(holder._row, holder._column);
            GridCell *cell = (GridCell*)selected.holder;
            int sqSrc = TOSQUARE(cell._row, cell._column);
            int m = MOVE(sqSrc, dstSq);
            int captured = 0;
            if([game.engine legal_move:m]) {
                int row, col;
                if([game.engine make_move:m captured:&captured]) {
                    row = ROW(dstSq);
                    col = COLUMN(dstSq);
                    if(captured && piece != nil) {
                        [piece removeFromSuperlayer];
                    }
                    [game x_movePiece:selected toRow:row toCol:col];
                    
                    //check if we win
                    int vlRep;
                    vlRep = [game.engine rep_status:3];
                    if([game.engine is_mate]) {
                        //you wins
                        game.game_result = kXiangQi_YouWin;
                        
                    }else if(vlRep > 0) {
                        //长打
                        vlRep = [game.engine rep_value:vlRep];
                        game.game_result = vlRep > WIN_VALUE ? kXiangQi_ComputerWin : (vlRep < -WIN_VALUE ? kXiangQi_YouWin : kXiangQi_Draw);
                    } else if(game.engine.nMoveNum > 100) {
                        //too many moves
                        game.game_result = kXiangQi_OverMoves;	
                    } else {
                        //normal move
                        if(captured) {
                            [game.engine set_irrev];
                        }
                    }
                    
                    
                    
                    //computer turn
                    [self performSelector:@selector(AIMove:) onThread:robot withObject:piece waitUntilDone:NO];
                }
            }
        }
        
        //reset selected state
        selected = nil;
        
        //clear highlighted state
        for(i = 0; i < nMoves; i++) {
            int m = moves[i];
            int dstSq = DST(m);
            int row = ROW(dstSq);
            int col = COLUMN(dstSq);
            moves[i] = 0;
            ((XiangQiSquare*)[game._grid cellAtRow:row column:col])._highlighted = NO;
        }
        nMoves = 0;
    }
}


- (void)reset_board
{
    CChessGame *game = (CChessGame*)((ChessBoardView*)self.view).game;
    selected = nil;
    nMoves = 0;
    r_total_time = b_total_time = 3600.0;
    memset(moves, 0x0, MAX_GEN_MOVES);
    self_time.text = @"60.0";
    opn_time.text = @"Computer";
    [ticker invalidate];
    [game reset_game];
}




@end
