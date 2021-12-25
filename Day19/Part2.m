#import <ObjFW/ObjFW.h>

int mats[24][3][3] = {{{1,0,0},{0,1,0},{0,0,1}},
                     {{1,0,0},{0,-1,0},{0,0,-1}},
                     {{-1,0,0},{0,1,0},{0,0,-1}},
                     {{-1,0,0},{0,-1,0},{0,0,1}},
					 
	                 {{-1,0,0},{0,0,1},{0,1,0}},
                	 {{-1,0,0},{0,0,-1},{0,-1,0}},
                     {{1,0,0},{0,0,-1},{0,1,0}},
                	 {{1,0,0},{0,0,1},{0,-1,0}},
									 
                     {{0,1,0},{1,0,0},{0,0,-1}},
                     {{0,-1,0},{-1,0,0},{0,0,-1}},
					 {{0,-1,0},{1,0,0},{0,0,1}},
                     {{0,1,0},{-1,0,0},{0,0,1}},
					 
	                 {{0,0,1},{1,0,0},{0,1,0}},
                     {{0,0,1},{-1,0,0},{0,-1,0}},
                     {{0,0,-1},{-1,0,0},{0,1,0}},
   	                 {{0,0,-1},{1,0,0},{0,-1,0}},

					 
					 {{0,1,0},{0,0,1},{1,0,0}},
                     {{0,-1,0},{0,0,-1},{1,0,0}},
                     {{0,-1,0},{0,0,1},{-1,0,0}},
                     {{0,1,0},{0,0,-1},{-1,0,0}},
					 
	                 {{0,0,-1},{0,1,0},{1,0,0}},
                     {{0,0,1},{0,-1,0},{1,0,0}},
                     {{0,0,1},{0,1,0},{-1,0,0}},
					 {{0,0,-1},{0,-1,0},{-1,0,0}}};

OFTriple *transform(OFTriple *pos, int m) {
	long long x, y, z, x1, y1, z1;
	x = [[pos firstObject] longLongValue];
	y = [[pos secondObject] longLongValue];
	z = [[pos thirdObject] longLongValue];
	x1 = mats[m][0][0] * x + mats[m][0][1] * y + mats[m][0][2] * z;
	y1 = mats[m][1][0] * x + mats[m][1][1] * y + mats[m][1][2] * z;
	z1 = mats[m][2][0] * x + mats[m][2][1] * y + mats[m][2][2] * z;
	return [OFTriple 
		tripleWithFirstObject:[OFNumber numberWithLongLong:x1]
		secondObject:[OFNumber numberWithLongLong:y1]
		thirdObject:[OFNumber numberWithLongLong:z1]
	];
}

OFTriple *overlap(OFArray *r1o, int m1, OFArray *r2, int *m2) {
	OFTriple *res = nil;
	@autoreleasepool {
	OFMutableArray *r1 = [OFMutableArray array];
	OFMutableArray *r2t = [OFMutableArray array];
	OFMutableDictionary *d = [OFMutableDictionary dictionary];
	int i, j, k;
	long long x, y, z, x1, y1, z1, x2, y2, z2;
	BOOL done = NO;
	for (k = 0; k < r1o.count; k++) {
		[r1 addObject:transform([r1o objectAtIndex:k], m1)];
	}
	for (i = 0; i < 24; i++) {
		[r2t removeAllObjects];
		for (k = 0; k < r2.count; k++) {
			[r2t addObject:transform([r2 objectAtIndex:k], i)];
		}
		[d removeAllObjects];
		for (j = 0; j < r1.count; j++) {
			x1 = [[[r1 objectAtIndex:j] firstObject] longLongValue];
			y1 = [[[r1 objectAtIndex:j] secondObject] longLongValue];
			z1 = [[[r1 objectAtIndex:j] thirdObject] longLongValue];
			for (k = 0; k < r2t.count; k++) {
				x2 = [[[r2t objectAtIndex:k] firstObject] longLongValue];
				y2 = [[[r2t objectAtIndex:k] secondObject] longLongValue];
				z2 = [[[r2t objectAtIndex:k] thirdObject] longLongValue];
				x = x1 - x2;
				y = y1 - y2;
				z = z1 - z2;
				if (llabs(x) > 2000 || llabs(y) > 2000 || llabs(z) > 2000) continue;
				OFTriple *key = [OFTriple 
					tripleWithFirstObject:[OFNumber numberWithLongLong:x]
					secondObject:[OFNumber numberWithLongLong:y]
					thirdObject:[OFNumber numberWithLongLong:z]
				];
				OFNumber *n = [d objectForKey:key];
				if (n) {
					[d setObject:[OFNumber numberWithInt:[n intValue]+1] forKey:key];
				} else {
					[d setObject:[OFNumber numberWithInt:1] forKey:key];
				}
			}
		}
		OFArray *a = [d allKeys];
		for (k = 0; k < a.count; k++) {
			if ([[d objectForKey:[a objectAtIndex:k]] intValue] >= 12) {
				res = [a objectAtIndex:k];
				done = YES;
				// OFLog(@"res=%@", res);
				break;
			}
		}
		if (done) break;
	}
	if (i < 24) {
		*m2 = i;
	}
	}
	return res;
}

@interface Day19: OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(Day19)

@implementation Day19
- (void)applicationDidFinishLaunching
{
	OFFile *f = [OFFile fileWithPath:@"input" mode:@"r"];
	OFString *s;
	OFMutableArray *reports  = [OFMutableArray array];
	OFMutableArray *report = [OFMutableArray array];
	OFNumber *zero = [OFNumber numberWithLongLong:0];
	long long best = 0, temp;
	int len, i, j;
	BOOL found[50] = {0};
	BOOL nope[50][50] = {0};
	int n_found;
	OFTriple *scanners[50] = {0};
	int matselect[50] = {0};
	while ((s = [f readLine])) {
		len = [s length];
		if (len == 0) {
			[reports addObject:report];
			report = [OFMutableArray array];
		} else if ([s characterAtIndex:len-1] == '-') {
			;
		} else {
			OFArray *a = [s componentsSeparatedByString:@","];
			OFNumber *x = [OFNumber numberWithLongLong:[[a objectAtIndex:0] longLongValue]];
			OFNumber *y = [OFNumber numberWithLongLong:[[a objectAtIndex:1] longLongValue]];
			OFNumber *z = [OFNumber numberWithLongLong:[[a objectAtIndex:2] longLongValue]];
			[report addObject:[OFTriple tripleWithFirstObject:x
												 secondObject:y
												  thirdObject:z]];

		}
	}
	[reports addObject:report];
	scanners[0] = [OFTriple tripleWithFirstObject:zero secondObject:zero thirdObject:zero];
	found[0] = YES;
	n_found = 1;
	while (n_found < reports.count) {
		OFTriple *diff;
		for (i = 0; i < reports.count; i++) {
			if (!found[i]) continue;
			for (j = 0; j < reports.count; j++) {
				if (found[j] || nope[i][j]) continue;
				diff = overlap([reports objectAtIndex:i], matselect[i], [reports objectAtIndex:j], &matselect[j]);
				if (diff) {
					break;
				} else {
					nope[i][j] = YES;
				}
			}
			if (j != reports.count) break;
		}
		if (i == reports.count) {
			OFLog(@"Something is wrong");
			break;
		} else {
			// OFLog(@"i=%d,j=%d",i,j);
			;
		}
		OFTriple *prev = scanners[i];
		OFTriple *scanner = [OFTriple 
			tripleWithFirstObject: [OFNumber numberWithLongLong:[[prev firstObject] longLongValue]+[[diff firstObject] longLongValue]]
			secondObject: [OFNumber numberWithLongLong:[[prev secondObject] longLongValue]+[[diff secondObject] longLongValue]]
			thirdObject: [OFNumber numberWithLongLong:[[prev thirdObject] longLongValue]+[[diff thirdObject] longLongValue]]
		];
		OFLog(@"scanner[%d]=%@",j,scanner);
		found[j] = YES;
		scanners[j] = scanner;
		n_found += 1;
	}
	if (n_found == reports.count) {
		for (i = 0; i < n_found; i++) {
			for (j = i+1; j < n_found; j++) {
				temp = llabs([[scanners[i] firstObject] longLongValue]-([[scanners[j] firstObject] longLongValue])) +
					llabs([[scanners[i] secondObject] longLongValue]-([[scanners[j] secondObject] longLongValue])) +
					llabs([[scanners[i] thirdObject] longLongValue]-([[scanners[j] thirdObject] longLongValue]));
				if (temp > best) best = temp;
			}
		}
	} else {
		OFLog(@"Only %d out of %zu scanners is found", n_found, reports.count);
	}
	OFLog(@"%lld", best);
	[OFApplication terminate];
}
@end
