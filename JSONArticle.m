//
//  JSONArticle.m
//  inspire
//
//  Created by Yuji on 2015/08/07.
//
//

#import "JSONArticle.h"

@implementation JSONArticle
{
    NSDictionary*dic;
}
@synthesize eprint;
@synthesize authors;
+(NSString*)requiredFields
{
    return @"publication_info,creation_date,doi,comment,number_of_citations,physical_description,abstract,corporate_name,authors,title,recid,system_control_number";
}
-(instancetype)initWithDictionary:(NSDictionary*)_dic
{
    self=[super init];
    dic=_dic;
    return self;
}
-(NSArray*)arrayFromKeyPath:(NSString*)kp
{
    NSArray*a=[dic valueForKeyPath:kp];
    if([a isKindOfClass:[NSNull class]]){
        return nil;
    }
    if(![a isKindOfClass:[NSArray class]]){
        a=@[a];
    }
    return a;
}
-(NSString*)stringFromKeyPath:(NSString*)kp
{
    NSArray*a=[self arrayFromKeyPath:kp];
    for(NSString*x in a){
        if(x && ![x isKindOfClass:[NSNull class]]){
            return x;
        }
    }
    return nil;
}
-(NSDictionary*)publicationInfo
{
    return [self arrayFromKeyPath:@"publication_info"][0];
}
-(NSString*)dateString
{
    return dic[@"creation_date"];
}
-(NSString*)doi
{
    return [self stringFromKeyPath:@"doi"];
}
-(NSString*)comment
{
    return [self stringFromKeyPath:@"comment"];
}
-(NSNumber*)citecount
{
    NSString*s=[self stringFromKeyPath:@"number_of_citations"];
    return @([s integerValue]);
}
-(NSNumber*)pages
{
    NSString*s=[self stringFromKeyPath:@"physical_description.pagination"];
    return @([s integerValue]);
}
-(NSString*)abstract
{
    return [self stringFromKeyPath:@"abstract.summary"];
}
-(NSString*)collaboration
{
    return [self stringFromKeyPath:@"corporate_name.collaboration"];
}
-(NSArray*)authors
{
    if(!authors){
        authors=[self arrayFromKeyPath:@"authors.full_name"];
    }
    return authors;
}
-(NSString*)title
{
    return [self stringFromKeyPath:@"title.title"];
}
-(NSString*)recid
{
    return dic[@"recid"];
}
-(NSString*)eprint
{
    if(!eprint){
        NSArray*a=[self arrayFromKeyPath:@"system_control_number"];
        for(NSDictionary*s in a){
            if([s[@"institute"] isEqualToString:@"arXiv"]){
                NSString*p=s[@"value"];
                eprint=[p stringByReplacingOccurrencesOfString:@"oai:arXiv.org" withString:@"arXiv"];
                break;
            }
        }
    }
    return eprint;
}
@end


