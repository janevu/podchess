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

#import <Foundation/Foundation.h>


/**
 * PodChess Referee 's error codes (or Return-Codes).
 */
#define POC_RC_REF_UNKNOWN       -1
#define POC_RC_REF_OK             0  /* A generic success       */
#define POC_RC_REF_ERR            1  /* A generic error         */

/**
 * The Referee to judge a given Game.
 */
@interface Referee : NSObject
{
    /* Empty */
}

- (id)   init;
- (int)  initGame;
- (int)  generateMoveFrom:(int)sqSrc moves:(int*)moves;
- (BOOL) isLegalMove:(int)move; 

- (void) makeMove:(int)move captured:(int*) ppcCaptured;
- (int) repStatus:(int)nRecur repValue:(int*)pRepVal;
- (int) isMate;
- (int) get_nMoveNum;
- (int) get_sdPlayer;

@end
