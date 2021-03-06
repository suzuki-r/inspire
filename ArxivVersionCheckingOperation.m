//
//  ArxivVersionCheckingOperation.m
//  spires
//
//  Created by Yuji on 09/02/07.
//  Copyright 2009 Y. Tachikawa. All rights reserved.
//

#import "ArxivVersionCheckingOperation.h"
#import "Article.h"
#import "ArxivPDFDownloadOperation.h"
#import "DeferredPDFOpenOperation.h"
#import "NSString+magic.h"
#import "AppDelegate.h"
#import "PDFHelper.h"
// #import <Quartz/Quartz.h>

#if TARGET_OS_IPHONE
#define NSAlert NSString
#define NSAlertDefaultReturn 0
#endif


@interface ArxivVersionCheckingOperation ()
-(void)downloadAlertDidEnd:(NSAlert*)alert code:(int)choice context:(id)ignore;
@end

@implementation ArxivVersionCheckingOperation
-(ArxivVersionCheckingOperation*)initWithArticle:(Article*)a usingViewer:(PDFViewerType)t;
{
    self=[super init];
    article=a;
    type=t;
    return self;
}
-(NSString*)description
{
    return [NSString stringWithFormat:@"version checking: %@", article.eprint];
}



-(void)run
{
    self.isExecuting=YES;

    if(article.version==nil || [article.version intValue]==0 || !article.hasPDFLocally){
	[self finish];
	return;
    }
    int v=[[PDFHelper sharedHelper] tryToDetermineVersionFromPDF:article.pdfPath];
    if(v==[article.version intValue] || v==0){
	[self finish];
	return;
    }
#if TARGET_OS_IPHONE
    [self downloadAlertDidEnd:nil code:NSAlertDefaultReturn context:nil];
#else
    NSString*commentsLine=@"";
    if(article.comments && ![article.comments isEqualToString:@""]){
	commentsLine=[NSString stringWithFormat:@"Comments: %@",article.comments];
    }
    NSAlert *alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:@"A new version of %@ has been found.",article.eprint]
				     defaultButton:@"Download" 
				   alternateButton:@"Cancel"
				       otherButton:nil
			 informativeTextWithFormat: @"Your PDF is version %d, which is older than the latest version %d on the web.\n%@",
		      v,[article.version intValue],commentsLine];
    [alert setAlertStyle:NSWarningAlertStyle];
    //   [NSApp unhide:self];
    
    [alert beginSheetModalForWindow:[[NSApp appDelegate] mainWindow]
		      modalDelegate:self 
		     didEndSelector:@selector(downloadAlertDidEnd:code:context:)
			contextInfo:nil];
#endif
}
-(void)downloadAlertDidEnd:(NSAlert*)alert code:(int)choice context:(id)ignore
{
    if(choice==NSAlertDefaultReturn){
        NSOperation*downloadOp=[[ArxivPDFDownloadOperation alloc] initWithArticle:article shouldAsk:NO];
        NSOperation*openOp=[[DeferredPDFOpenOperation alloc] initWithArticle:article
                                                                 usingViewer:type];
        [openOp addDependency:downloadOp];
	[[OperationQueues arxivQueue] addOperation:downloadOp];
        [[OperationQueues sharedQueue] addOperation:openOp];

    }
    [self finish];
}
    

@end
