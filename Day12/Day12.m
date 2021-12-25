#import <ObjFW/ObjFW.h>
#include <ctype.h>

void add_to_graph(OFMutableDictionary *g, OFString *u, OFString *v) {
	if ([g objectForKey:u] == nil) {
		[g setValue:[OFMutableArray array] forKey:u];
	}
	[[g objectForKey:u] addObject:v];
}

void add_to_graph2(OFMutableDictionary *g, OFString *u, OFString *v) {
	add_to_graph(g, u, v);
	add_to_graph(g, v, u);
}

long long search(OFMutableDictionary *g, OFMutableSet *vis, OFString *start) {
	if ([start isEqual:@"end"]) return 1;
	long long result = 0;
	OFArray *a = [g objectForKey:start];
	int i;
	OFString *v;
	for (i = 0; i < a.count; ++i) {
		v = [a objectAtIndex:i];
		if ([vis containsObject:v]) continue;
		if (islower([v characterAtIndex:0])) {
			[vis addObject:v];
		}
		result += search(g, vis, v);
		if (islower([v characterAtIndex:0])) {
			[vis removeObject:v];
		}
	}
	return result;
}


@interface Day12: OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(Day12)

@implementation Day12
- (void)applicationDidFinishLaunching
{
	OFFile *f = [OFFile fileWithPath:@"input" mode:@"r"];
	OFString *s;
	OFMutableDictionary *g = [OFMutableDictionary dictionary];
	OFMutableSet *vis = [OFMutableSet set];
	long long ans;
	while ((s = [f readLine])) {
		OFArray *a = [s componentsSeparatedByString:@"-"];
		add_to_graph2(g, [a objectAtIndex:0], [a objectAtIndex:1]);
	}
	[vis addObject:@"start"];
	ans = search(g, vis, @"start");
	[OFStdOut writeFormat:@"%lld\n", ans];
	[OFApplication terminate];
}
@end
