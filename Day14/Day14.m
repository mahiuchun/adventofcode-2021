#import <ObjFW/ObjFW.h>

@interface Day14: OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(Day14)

@implementation Day14
- (void)applicationDidFinishLaunching
{
	long long count[128] = {0};
	long long most = 0;
	long long least = LLONG_MAX;
	OFFile *f = [OFFile fileWithPath:@"input" mode:@"r"];
	OFString *s = [f readLine];
	OFList *l = [OFList list];
	OFListItem node, next;
	OFMutableDictionary *lookup = [OFMutableDictionary dictionary];
	int i;
	for (i = 0; i < [s length]; ++i) {
		[l appendObject:[OFNumber numberWithChar:[s characterAtIndex:i]]];
	}
	[f readLine];
	while ((s = [f readLine])) {
		OFArray *a = [s componentsSeparatedByString:@" -> "];
		OFNumber *n1 = [OFNumber numberWithChar:[[a objectAtIndex:0] characterAtIndex:0]];
		OFNumber *n2 = [OFNumber numberWithChar:[[a objectAtIndex:0] characterAtIndex:1]];
		OFNumber *n3 = [OFNumber numberWithChar:[[a objectAtIndex:1] characterAtIndex:0]];
		OFPair *p = [OFPair pairWithFirstObject:n1 secondObject:n2];
		[lookup setObject:n3 forKey:p];
	}
	for (i = 0; i < 10; ++i) {
		for (node = l.firstListItem, next = OFListItemNext(node); next; node = next, next = OFListItemNext(node)) {
			OFPair *p = [OFPair pairWithFirstObject:OFListItemObject(node) secondObject:OFListItemObject(next)];
			OFNumber *n = [lookup objectForKey:p];
			if (n != nil) {
				[l insertObject:n afterListItem:node];
			}
		}
	}
	for (node = l.firstListItem; node; node = OFListItemNext(node)) {
		count[[OFListItemObject(node) charValue]] += 1;
	}
	for (i = 'A'; i <= 'Z'; ++i) {
		if (count[i] > most) most = count[i];
		if (count[i] > 0 && count[i] < least) least = count[i];
	}
	[OFStdOut writeFormat:@"%lld-%lld=%lld\n", most, least, most-least];
	[OFApplication terminate];
}
@end
