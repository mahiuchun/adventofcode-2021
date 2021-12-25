#import <ObjFW/ObjFW.h>

#define MIN(a,b) ((a)<(b)?(a):(b))
#define MAX(a,b) ((a)>(b)?(a):(b))

typedef struct coord {
	int x;
	int y;
} Coord;

void atocoord(OFString *s, Coord *res) {
	OFArray *a = [s componentsSeparatedByString:@","];
	res->x = (int)[[a objectAtIndex:0] longLongValue];
	res->y = (int)[[a objectAtIndex:1] longLongValue];
}

@interface Day5: OFObject <OFApplicationDelegate>

int field[1000][1000];

@end

OF_APPLICATION_DELEGATE(Day5)

@implementation Day5
- (void)applicationDidFinishLaunching
{
	OFFile *f = [OFFile fileWithPath:@"input" mode:@"r"];
	OFString *s = [f readLine];
	int i, j, tot = 0, min, max;
	Coord p1, p2, p3;
	while (s != nil) {
		OFArray *a = [s componentsSeparatedByString:@" -> "];
		atocoord([a objectAtIndex:0], &p1);
		atocoord([a objectAtIndex:1], &p2);
		if (p1.x != p2.x && p1.y != p2.y) {
			if (p1.x > p2.x) {
				p3 = p1;
				p1 = p2;
				p2 = p3;
			}
			if (p2.x-p1.x == abs(p2.y-p1.y)) {
				int sign = p1.y<p2.y ? 1 : -1;
				for (i = p1.x; i <= p2.x; ++i) {
					j = i - p1.x;
					field[p1.y+sign*j][i] += 1;
				}
			}
		} else if (p1.x != p2.x) {
			min = MIN(p1.x, p2.x);
			max = MAX(p1.x, p2.x);
			for (i = min; i <= max; ++i) field[p1.y][i] += 1;
		} else if (p1.y != p2.y) {
			min = MIN(p1.y, p2.y);
			max = MAX(p1.y, p2.y);
			for (i = min; i <= max; ++i) field[i][p1.x] += 1;
		}
		s = [f readLine];
	}
	for (i = 0; i < 1000; ++i) {
		for (j = 0; j < 1000; ++j) {
			if (field[i][j] >= 2) tot += 1;
		}
	}
	[OFStdOut writeFormat:@"%d\n", tot];
	[OFApplication terminate];
}
@end
