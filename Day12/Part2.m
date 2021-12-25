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

long long search(OFMutableDictionary *g, OFMutableDictionary *vis, OFDictionary *maxvis, OFString *start) {
	if ([start isEqual:@"end"]) return 1;
	long long result = 0;
	OFArray *a = [g objectForKey:start];
	int i;
	OFString *v;
	for (i = 0; i < a.count; ++i) {
		v = [a objectAtIndex:i];
		OFNumber *viscount = [vis objectForKey:v];
		if (viscount && [viscount intValue] >= [[maxvis objectForKey:v] intValue])
			continue;
		if (islower([v characterAtIndex:0])) {
			if (!viscount) {
				[vis setValue:[OFNumber numberWithInt:1] forKey:v];
			} else {
				[vis setValue:[OFNumber numberWithInt:[viscount intValue]+1] forKey:v];
			}
		}
		result += search(g, vis, maxvis, v);
		if (islower([v characterAtIndex:0])) {
			OFNumber *viscount = [vis objectForKey:v];
			[vis setValue:[OFNumber numberWithInt:[viscount intValue]-1] forKey:v];
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
	OFMutableDictionary *vis = [OFMutableDictionary dictionary];
	OFMutableDictionary *maxvis = [OFMutableDictionary dictionary];
	long long tot = 0, small = 0;
	int i;
	while ((s = [f readLine])) {
		OFArray *a = [s componentsSeparatedByString:@"-"];
		add_to_graph2(g, [a objectAtIndex:0], [a objectAtIndex:1]);
	}
	OFArray *a = [g allKeys];
	for (i = 0; i < a.count; ++i) {
		OFString *u = [a objectAtIndex:i];
		if (islower([u characterAtIndex:0])) {
			[maxvis setValue:[OFNumber numberWithInt:1] forKey:u];
		}
	}
	for (i = 0; i < a.count; ++i) {
		OFString *u = [a objectAtIndex:i];
		if ([u isEqual:@"start"] || [u isEqual:@"end"]) continue;
		if (islower([u characterAtIndex:0])) {
			[vis removeAllObjects];
			[vis setValue:[OFNumber numberWithInt:1] forKey:@"start"];
			[maxvis setValue:[OFNumber numberWithInt:2] forKey:u];
			tot += search(g, vis, maxvis, @"start");
			[maxvis setValue:[OFNumber numberWithInt:1] forKey:u];
			small += 1;
			[OFStdErr writeFormat:@"%@ %lld\n", u, tot];
		}
	}
	tot -= (small - 1) * search(g, vis, maxvis, @"start");
	[OFStdOut writeFormat:@"%lld\n", tot];
	[OFApplication terminate];
}
@end
