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

#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "Game.h"
#import "XiangQi.h"
#import "AIEngine.h"

#define TOSQUARE(row, col) (16 * ((row) + 3) + ((col) + 3))
#define COLUMN(sq) ((sq) % 16 - 3)
#define ROW(sq) ((sq) / 16 - 3)


/* Possible game result */
enum{
    kXiangQi_InPlay,
    kXiangQi_YouWin,
    kXiangQi_ComputerWin,
    //we need this state because you might play with other online player
    kXiangqi_YouLose,
    kXiangQi_Draw,
    kXiangQi_OverMoves,
};

/* Possible AI engines.
 * TODO: We should use prefix "kPodChess" to make our constants
 *       unique from others (to avoid naming conflicts).
 *       Also, once we are done with the AI framework, then there will be
 *       no need for these constants.
 */
enum {
    kPodChess_AI_xqwlight,
    kPodChess_AI_haqikid,
};

@class RectGrid;
@class Piece;

@interface CChessGame : Game
{
    RectGrid *_grid;
    
    NSMutableArray *_pieceBox;
    
    int _aiType;
    XiangQi *engine;
    AIEngine *_aiEngine;
    
    int game_result;
}

- (void)setupCChessPieces;
- (void)x_createPiece: (NSString*)imageName row: (int)row col: (int)col forPlayer: (unsigned)playerNo;
- (void)x_movePiece:(Piece*)piece toRow:(int)row toCol:(int)col;
- (Piece*)x_getPieceAtRow:(int)row col:(int)col;
- (int)robotMoveWithCaptured:(int*)captured;
- (BOOL)humanMove:(int)row1 fromCol:(int)col1
            toRow:(int)row2 toCol:(int)col2;
- (void)setSearchDepth:(int)depth;
- (void)resetCChessPieces;
- (void)reset_game;

@property (nonatomic,readonly)    XiangQi *engine;
@property (nonatomic,readonly)    RectGrid *_grid;

@property (nonatomic,assign) int game_result;
@end
