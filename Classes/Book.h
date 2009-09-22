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

// opening book item
typedef struct _BookItem {
    int dwLock;
    short wmv;
    short wvl;
}BookItem;

#define BOOK_SIZE 16384

@interface Book : NSObject {
    int nBookSize;                 // 开局库大小
    BookItem *BookTable; // 开局库
}

- (id)initWithBook:(NSString*)bookfile;

@property (nonatomic, readonly) int nBookSize;
@property (nonatomic, readonly) BookItem *BookTable;
@end
