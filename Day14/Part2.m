#import <ObjFW/ObjFW.h>

void increase_key(OFMutableDictionary *dict, OFPair *key, long long x) {
	OFNumber *n = [dict objectForKey:key];
	if (n != nil) {
		[dict setObject:[OFNumber numberWithLongLong:[n longLongValue] + x] forKey:key];
	} else {
		[dict setObject:[OFNumber numberWithLongLong:x] forKey:key];
	}
} 

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
	OFMutableDictionary *pairs = [OFMutableDictionary dictionary];
	OFMutableDictionary *toadd = [OFMutableDictionary dictionary];
	OFMutableDictionary *lookup = [OFMutableDictionary dictionary];
	int first, last;
	int i, j;
	for (i = 0; i < [s length] - 1; ++i) {
		OFNumber *n1 = [OFNumber numberWithChar:[s characterAtIndex:i]];
		OFNumber *n2 = [OFNumber numberWithChar:[s characterAtIndex:i+1]];
		OFPair *p = [OFPair pairWithFirstObject:n1 secondObject:n2];
		increase_key(pairs, p, 1);
	}
	first = [s characterAtIndex:0];
	last = [s characterAtIndex:[s length]-1];
	[f readLine];
	while ((s = [f readLine])) {
		OFArray *a = [s componentsSeparatedByString:@" -> "];
		OFNumber *n1 = [OFNumber numberWithChar:[[a objectAtIndex:0] characterAtIndex:0]];
		OFNumber *n2 = [OFNumber numberWithChar:[[a objectAtIndex:0] characterAtIndex:1]];
		OFNumber *n3 = [OFNumber numberWithChar:[[a objectAtIndex:1] characterAtIndex:0]];
		OFPair *p = [OFPair pairWithFirstObject:n1 secondObject:n2];
		[lookup setObject:n3 forKey:p];
	}
	for (j = 0; j < 40; j++) {
		OFArray *a = [pairs allKeys];
		[OFStdErr writeFormat:@"%ld\n", a.count];
		for (i = 0; i < a.count; ++i) {
			OFPair *p = [a objectAtIndex:i];
			OFNumber *nc = [lookup objectForKey:p];
			if (nc != nil) {
				OFNumber *nn = [pairs objectForKey:p];
				OFPair *p1 = [OFPair pairWithFirstObject:[p firstObject] secondObject:nc];
				increase_key(toadd, p1, [nn longLongValue]);
				OFPair *p2 = [OFPair pairWithFirstObject:nc secondObject:[p secondObject]];
				increase_key(toadd, p2, [nn longLongValue]);
			} else {
				increase_key(toadd, p, [[pairs objectForKey:p] longLongValue]);
			}
		}
		[pairs removeAllObjects];
		[pairs addEntriesFromDictionary:toadd];
		[toadd removeAllObjects];
	}
	OFArray *a = [pairs allKeys];
	for (i = 0; i < a.count; ++i) {
		OFPair *p = [a objectAtIndex:i];
		OFNumber *nn = [pairs objectForKey:p];
		count[[[p firstObject] charValue]] += [nn longLongValue];
		count[[[p secondObject] charValue]] += [nn longLongValue];
	}
	count[first] += 1;
	count[last] += 1;
	for (i = 'A'; i <= 'Z'; ++i) {
		count[i] /= 2;
		if (count[i] > most) most = count[i];
		if (count[i] > 0 && count[i] < least) least = count[i];
	}
	[OFStdOut writeFormat:@"%lld-%lld=%lld\n", most, least, most-least];
	[OFApplication terminate];
}
@end
