//
//  ALDocumentsCell.h
//  Applozic
//
//  Created by devashish on 29/03/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//
//  THIS CELL IS BASICALLY FOR DOCUMENTS LIKE PPTX, PDF, DOCX etc.
/*********************************************************************
 TABLE CELL CUSTOM CLASS : THIS CLASS IS FOR MISC TYPE DOCUMENTS
 i.e. PDF, TXT, DOCX AND OTHER TYPES OF DOCS.
 **********************************************************************/

#import <UIKit/UIKit.h>
#import "ALMediaBaseCell.h"

@interface ALDocumentsCell : ALMediaBaseCell

@property (nonatomic, strong) UILabel * documentName;
@property (nonatomic, strong) UITapGestureRecognizer *tapper;

-(instancetype) populateCell:(ALMessage *) alMessage viewSize:(CGSize)viewSize;

@end
