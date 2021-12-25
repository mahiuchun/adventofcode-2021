#import <ObjFW/ObjFW.h>

typedef struct map {
        char d[200][200];
        int row;
        int col;
} Map;

Map map, next;

void print_map(const Map* m) {
	int i;
	for (i = 0; i < m->row; i++) {
		[OFStdOut writeFormat:@"%s\n", m->d[i]];
	}
	[OFStdOut writeFormat:@"\n"];
}

@interface Day25: OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(Day25)

@implementation Day25
- (void)applicationDidFinishLaunching
{
        OFFile *f = [OFFile fileWithPath:@"input" mode:@"r"];
        OFString *s;
	int i, j, k;
	long long step = 0;
	BOOL stopped = NO; 
        while ((s = [f readLine])) {
                map.col = [s length];
                strcpy(map.d[map.row], [s cStringWithEncoding:OFStringEncodingUTF8]);
                map.row += 1; 
        }
	next = map;
	while (step < 10000000) {
		stopped = YES;
		for (i = 0; i < map.row; i++) {
			for (j = 0; j < map.col; j++) {
				if (map.d[i][j] != '>') continue;
				k = (j + 1) % map.col;
				if (map.d[i][k] != '.') continue;
				next.d[i][j] = '.';
				next.d[i][k] = '>';
				stopped = NO;
			}
		}
		for (i = 0; i < map.row; i++) {
			for (j = 0; j < map.col; j++) {
				if (map.d[i][j] != 'v') continue;
				k = (i + 1) % map.row;
				if (map.d[k][j] == 'v') continue;
				if (next.d[k][j] != '.') continue;
				next.d[i][j] = '.';
				next.d[k][j] = 'v';
				stopped = NO;
			}
		}
		step += 1;
		map = next;
		// if (step % 10 == 0) print_map(&map);
		if (stopped) break;

	}
	if (!stopped)
		OFLog(@"Something is wrong");
	[OFStdOut writeFormat:@"%lld\n", step];
        [OFApplication terminate];
}
@end
