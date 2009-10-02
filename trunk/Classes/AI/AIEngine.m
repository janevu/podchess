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

#import "AIEngine.h"


@implementation AIEngine

- (void)dealloc
{
    [super dealloc];
}

#pragma mark -
#pragma mark AI METHODS TO BE OVERRIDDEN:

- (id) init
{
    self = [super init];
    return self;
}

- (int) setDifficultyLevel: (int)nAILevel
{
    return AI_RC_OK;
}

- (int) initGame
{
    return AI_RC_OK;
}

- (int) generateMove:(int*)pRow1 fromCol:(int*)pCol1
               toRow:(int*)pRow2 toCol:(int*)pCol2
{
    return AI_RC_OK;
}

- (int) onHumanMove:(int)row1 fromCol:(int)col1
              toRow:(int)row2 toCol:(int)col2
{
    return AI_RC_OK;
}

- (const char*) getInfo
{
    return "Some unknown AI written by someone";
}

- (int) loadBook
{
    return AI_RC_OK;
}

- (int) generateMoveFrom:(int)sqSrc moves:(int*)mvs
{
    return 0;
}

- (BOOL) isLegalMove:(int)mv
{
    return YES;
}

////////////
- (void) makeMove:(int)mv captured:(int*) ppcCaptured
{
}

- (int) repStatus:(int)nRecur repValue:(int*)repVal
{
    return 0;
}

- (int) isMate
{
    return NO;
}

- (int) get_nMoveNum
{
    return 0;
}

- (int) get_sdPlayer
{
    return 0;
}
////////////


@end
