//
//  OADataFetcher.m
//  OAuthConsumer
//
//  Created by Jon Crosby on 11/5/07.
//  Copyright 2007 Kaboomerang LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#import "OADataFetcher.h"


@implementation OADataFetcher

- (void)fetchDataWithRequest:(OAMutableURLRequest *)aRequest 
					delegate:(id)aDelegate 
		   didFinishSelector:(SEL)finishSelector 
			 didFailSelector:(SEL)failSelector 
{
    request = aRequest;
    delegate = aDelegate;
    didFinishSelector = finishSelector;
    didFailSelector = failSelector;
    
    [request prepare];

    responseData = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    
    if (response == nil || responseData == nil || error != nil) {
        OAServiceTicket *ticket= [[OAServiceTicket alloc] initWithRequest:request
                                                                 response:response
                                                               didSucceed:NO];
		
        
        if(response != nil){
            ticket.responseStatusCode = [(NSHTTPURLResponse *)response statusCode];
        }
        
        if(responseData != nil){
            ticket.responseBody = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
        }
        
        if(error != nil){
            ticket.error = error;
        }
        else if(responseData == nil){
            ticket.error = [NSError errorWithDomain:@"F1" code:2 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Response data was nil for %@", [request URL]], NSLocalizedDescriptionKey, nil]];
        }
        else {
            ticket.error = [NSError errorWithDomain:@"F1" code:3 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Response was nil for %@", [request URL]], NSLocalizedDescriptionKey, nil]];
        }
        
        [delegate performSelector:didFailSelector
                       withObject:ticket
                       withObject:error];
		
		[ticket release];
		
    } 
	else {
		
        OAServiceTicket *ticket = [[OAServiceTicket alloc] initWithRequest:request
                                                                  response:response
                                                                didSucceed:[(NSHTTPURLResponse *)response statusCode] < 400];
        
        ticket.responseStatusCode = [(NSHTTPURLResponse *)response statusCode];
        ticket.responseBody = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
        
        if(!ticket.didSucceed){
            ticket.error = [NSError errorWithDomain:@"F1" code:1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Expected status code greater than 400, but got %d", ticket.responseStatusCode], NSLocalizedDescriptionKey, ticket.responseBody, NSLocalizedFailureReasonErrorKey, nil]];
        }
        
        [delegate performSelector:didFinishSelector
                       withObject:ticket
                       withObject:responseData];
		
       [ticket release];
    }   
}

@end
