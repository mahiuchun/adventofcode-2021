#import <ObjFW/ObjFW.h>

#define MIN(a,b) ((a)<(b)?(a):(b))
#define MAX(a,b) ((a)>(b)?(a):(b))

typedef struct state {
  char s[24];
  char from[24];
  long long cost;
  long long score;
  OFNumber *key;
} State;

BOOL done(const State *st) {
  return
    st->s[7] == 'A' && st->s[8] == 'A' && st->s[9] == 'A' && st->s[10] == 'A' &&
    st->s[11] == 'B' && st->s[12] == 'B' && st->s[13] == 'B' && st->s[14] == 'B' &&
    st->s[15] == 'C' && st->s[16] == 'C' && st->s[17] == 'C' && st->s[18] == 'C' &&
    st->s[19] == 'D' && st->s[20] == 'D' && st->s[21] == 'D' && st->s[22] == 'D';
}

typedef struct coord {
  int x;
  int y;
} Coord;

Coord postoxy[23];
int xytopos[11][5];

long long cost(int i, int j) {
  if (i == j) return 0;
  return abs(postoxy[i].x-postoxy[j].x)+abs(postoxy[i].y-postoxy[j].y);
}

long long factor[4] = {1, 10, 100, 1000};
long long stoidx(const State *st) {
  long long res = 0;
  int i;
  for (i = 0; i <= 22; i++) {
    res = res * 6 + st->s[i] - 'A';
  }
  return res;
}

struct heap {
  State h[10000000];
  size_t size;
  OFMutableDictionary *lut;
  OFMutableSet *vis;
} H;

#define PARENT(i) (((i)-1)/2)
#define LEFT(i) ((2*(i))+1)
#define RIGHT(i) ((2*(i))+2)

void heap_swap(int i, int j) {
  State temp;
  // [H.lut setObject:[OFNumber numberWithInt:j] forKey:H.h[i].key];
  // [H.lut setObject:[OFNumber numberWithInt:i] forKey:H.h[j].key];
  temp = H.h[i];
  H.h[i] = H.h[j];
  H.h[j] = temp;
}

void min_heapify(int i) {
  int l = LEFT(i);
  int r = RIGHT(i);
  int smallest;
  if (l < H.size && H.h[l].score < H.h[i].score)
    smallest = l;
  else
    smallest = i;
  if (r < H.size && H.h[r].score < H.h[smallest].score)
    smallest = r;
  if (smallest != i) {
    heap_swap(i, smallest);
    min_heapify(smallest);
  }
}

State heap_extract_min() {
  State res = H.h[0];
  heap_swap(0, H.size-1);
  // [H.lut removeObjectForKey:H.h[H.size-1].key];  
  H.size -= 1;
  min_heapify(0);
  return res;
}

void heap_insert(const State *st) {
  // OFNumber *n = [H.lut objectForKey:st->key];
  int i;
  //if (n) {
  //  i = [n intValue];
  //  H.h[i] = *st;
  //} else {
    i = H.size;
    H.h[H.size] = *st;
    //[H.lut setObject:[OFNumber numberWithInt:H.size] forKey:st->key];
    H.size += 1;
    //}
  while (i > 0 && H.h[PARENT(i)].score > H.h[i].score) {
    heap_swap(i, PARENT(i));
    i = PARENT(i);
  }
}

/*long long frontier_cost(const State *st) {
  OFNumber *n = [H.lut objectForKey:st->key];
  if (n) {
    return H.h[[n intValue]].cost;
  } else {
    return LLONG_MAX;
  }
  }*/

BOOL blocked(const State *st, int i, int j) {
  int t, ii;
  Coord c1, c2, cm;
  if (i > j) {
    t = i;
    i = j;
    j = t;
  }
  if (i > 6) OFLog(@"i=%d is too small");
  if (j < 7) OFLog(@"j=%d is too large");
  c1 = postoxy[i];
  c2 = postoxy[j];
  cm.x = c2.x;
  cm.y = c1.y;
  for (ii = MIN(c1.x, cm.x)+1; ii < MAX(c1.x, cm.x); ii++) {
    if (xytopos[ii][cm.y] == -1) continue;
    if (st->s[xytopos[ii][cm.y]] != 'E') return YES;
  }
  for (ii = cm.y + 1; ii < c2.y; ii++) {
    if (st->s[xytopos[cm.x][ii]] != 'E') return YES;
  }
  return NO;
}

int extra[5] = {0, 0, 1, 3, 6};

long long h(const State *st) {
  long long res = 0, x;
  int i;
  int wrong[4] = {0};
  for (i = 0; i <= 22; i++) {
    if (st->s[i] == 'E') continue;
    x = 2 + 2 * (st->s[i] - 'A');
    if (postoxy[i].x != x) {
      res += llabs(postoxy[i].x - x + 1 + postoxy[i].y) * factor[st->s[i]-'A'];
      wrong[st->s[i]-'A'] += 1;
    }
  }
  for (i = 0; i < 4; i++) {
    res += extra[wrong[i]] * factor[i];
  }
  return res;
}

State astar(State initial) {
  State front, temp;
  int i, j, jj;
  BOOL other;
  H.h[0] = initial;
  H.size = 1;
  //H.lut = [OFMutableDictionary dictionaryWithCapacity:10000000];
  H.vis = [OFMutableSet setWithCapacity:10000000];
  while (H.size > 0) {
    front = heap_extract_min();
    if (done(&front)) {
      return front;
    }
    if ([H.vis containsObject:front.key]) continue;
    OFLog(@"%s->%s:%lld", front.from, front.s, front.score);
    [H.vis addObject:front.key];
    for (i = 0; i <= 6; i++) {
      if (front.s[i] == 'E') continue;
      jj = 4 * (front.s[i]-'A') + 7;
      if (front.s[jj] != 'E') continue;
      if (blocked(&front, i, jj)) continue;
      other = NO;
      for (j = jj; j < jj + 4; j++) {
	if (front.s[j] != 'E' && front.s[j] != front.s[i]) {
	  other = YES;
	  break;
	}
      }
      if (other) continue;
      for (j = jj+3; j >= jj; j--) {
	if (front.s[j] != 'E') continue;
	if (blocked(&front, i, j)) continue;
	temp = front;
	temp.s[i] = front.s[j];
	temp.s[j] = front.s[i];
	temp.key = [OFNumber numberWithLongLong:stoidx(&temp)];
	if ([H.vis containsObject:temp.key]) break;
	temp.cost += cost(i,j) * factor[front.s[i]-'A'];
	temp.score = temp.cost + h(&temp);
	strcpy(temp.from, front.s);
	//if (temp.cost < frontier_cost(&temp)) heap_insert(&temp);
	heap_insert(&temp);
	break;
      }
    }
    for (i = 7; i <= 22; i++) {
      if (front.s[i] == 'E') continue;
      for (j = 0; j <= 6; j++) {
	if (front.s[j] != 'E') continue;
	if (blocked(&front, i, j)) continue;
	temp = front;
	temp.s[i] = front.s[j];
	temp.s[j] = front.s[i];
	temp.key = [OFNumber numberWithLongLong:stoidx(&temp)];
	if ([H.vis containsObject:temp.key]) continue;
	temp.cost += cost(i,j) * factor[front.s[i]-'A'];
	temp.score = temp.cost + h(&temp);
	strcpy(temp.from, front.s);
	// if (temp.cost < frontier_cost(&temp)) heap_insert(&temp);
	heap_insert(&temp);
      }
    }
  }
  return initial;
}

@interface Day23: OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(Day23)

@implementation Day23
- (void)applicationDidFinishLaunching
{
  OFFile *f = [OFFile fileWithPath:@"input" mode:@"r"];
  OFString *lines[5];
  int i, j;
  State initial, final;
  initial.cost = 0;
  for (i = 0; i < 5; i++) {
    lines[i] = [f readLine];
  }
  for (i = 0; i < 7; i++) {
    initial.s[i] = 'E';
  }
  initial.s[7] = [lines[2] characterAtIndex:3];
  initial.s[8] = 'D';
  initial.s[9] = 'D';
  initial.s[10] = [lines[3] characterAtIndex:3];
  initial.s[11] = [lines[2] characterAtIndex:5];
  initial.s[12] = 'C';
  initial.s[13] = 'B';
  initial.s[14] = [lines[3] characterAtIndex:5];
  initial.s[15] = [lines[2] characterAtIndex:7];
  initial.s[16] = 'B';
  initial.s[17] = 'A';
  initial.s[18] = [lines[3] characterAtIndex:7];
  initial.s[19] = [lines[2] characterAtIndex:9];
  initial.s[20] = 'A';
  initial.s[21] = 'C';
  initial.s[22] = [lines[3] characterAtIndex:9];
  initial.s[23] = '\0';
  initial.key = [OFNumber numberWithLongLong:stoidx(&initial)];
  strcpy(initial.from, "nil");
  OFLog(@"%s", initial.s);
  for (i = 0; i < 5; i++) {
    for (j = 0; j < 11; j++) {
      xytopos[j][i] = -1;
    }
  }
  xytopos[0][0] = 0;
  xytopos[1][0] = 1;
  xytopos[2][1] = 7;
  xytopos[2][2] = 8;
  xytopos[2][3] = 9;
  xytopos[2][4] = 10;
  xytopos[3][0] = 2;
  xytopos[4][1] = 11;
  xytopos[4][2] = 12;
  xytopos[4][3] = 13;
  xytopos[4][4] = 14;
  xytopos[5][0] = 3;
  xytopos[6][1] = 15;
  xytopos[6][2] = 16;
  xytopos[6][3] = 17;
  xytopos[6][4] = 18;
  xytopos[7][0] = 4;
  xytopos[8][1] = 19;
  xytopos[8][2] = 20;
  xytopos[8][3] = 21;
  xytopos[8][4] = 22;
  xytopos[9][0] = 5;
  xytopos[10][0] = 6;
  for (i = 0; i < 5; i++) {
    for (j = 0; j < 11; j++) {
      if (xytopos[j][i] >= 0) {
	postoxy[xytopos[j][i]].x = j;
	postoxy[xytopos[j][i]].y = i;
      }
    }
  }
  final = astar(initial);
  OFLog(@"%s", final.s);
  [OFStdOut writeFormat:@"%lld\n", final.cost];
  [OFApplication terminate];
}
@end
