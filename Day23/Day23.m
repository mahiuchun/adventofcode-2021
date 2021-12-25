#import <ObjFW/ObjFW.h>

#define MIN(a,b) ((a)<(b)?(a):(b))
#define MAX(a,b) ((a)>(b)?(a):(b))

typedef struct state {
  char s[14];
  long long cost;
} State;

BOOL done(const State *st) {
  return
    st->s[5] == 'A' && st->s[6] == 'A' &&
    st->s[7] == 'B' && st->s[8] == 'B' &&
    st->s[9] == 'C' && st->s[10] == 'C' &&
    st->s[11] == 'D' && st->s[12] == 'D';
}

long long cost[13][13];
long long factor[4] = {1, 10, 100, 1000};

int stoidx(const State *st) {
  int res = 0, i;
  for (i = 0; i <= 12; i++) {
    res = res * 5 + st->s[i] - 'A';
  }
  return res;
}

struct heap {
  State h[10000000];
  int size;
  int *lut;
} H;

#define PARENT(i) (((i)-1)/2)
#define LEFT(i) ((2*(i))+1)
#define RIGHT(i) ((2*(i))+2)

void heap_swap(int i, int j) {
  State temp;
  int i1 = stoidx(&H.h[i]);
  int i2 = stoidx(&H.h[j]);
  H.lut[i1] = j + 1;
  H.lut[i2] = i + 1;
  temp = H.h[i];
  H.h[i] = H.h[j];
  H.h[j] = temp;
}

void min_heapify(int i) {
  int l = LEFT(i);
  int r = RIGHT(i);
  int smallest;
  if (l < H.size && H.h[l].cost < H.h[i].cost)
    smallest = l;
  else
    smallest = i;
  if (r < H.size && H.h[r].cost < H.h[smallest].cost)
    smallest = r;
  if (smallest != i) {
    heap_swap(i, smallest);
    min_heapify(smallest);
  }
}

State heap_extract_min() {
  State res = H.h[0];
  int i1 = stoidx(&H.h[0]);
  heap_swap(0, H.size-1);
  H.lut[i1] = 0;
  H.size -= 1;
  min_heapify(0);
  return res;
}

void heap_insert(const State *st) {
  int i = H.size;
  int idx = stoidx(st);
  H.h[H.size++] = *st;
  H.lut[idx] = H.size;
  while (i > 0 && H.h[PARENT(i)].cost > H.h[i].cost) {
    heap_swap(i, PARENT(i));
    i = PARENT(i);
  }
}

long long frontier_cost(const State *st) {
  int i = stoidx(st);
  if (H.lut[i] > 0) {
    return H.h[H.lut[i]-1].cost;
  } else {
    return LLONG_MAX;
  }
}

BOOL blocked(const State *st, int i, int j) {
  int t, ii;
  if (i > j) {
    t = i;
    i = j;
    j = t;
  }
  if (i > 4) OFLog(@"i=%d is too small");
  if (j < 5) OFLog(@"j=%d is too large");
  t = j;
  if (j % 2 ==0) t -= 1;
  t = (t - 3) / 2;
  if (t < i) {
    for (ii = t; ii < i; ii++) {
      if (st->s[ii] != 'E') return YES;
    }
  } else {
    for (ii = i + 1; ii < t; ii++) {
      if (st->s[ii] != 'E') return YES;
    }
  }
  return NO;
}

State ucs(State initial) {
  State front, temp;
  int i, j;
  H.h[0] = initial;
  H.size = 1;
  H.lut = calloc(sizeof(int), 1220703125);
  while (H.size > 0) {
    front = heap_extract_min();
    if (done(&front)) {
      return front;
    }
    H.lut[stoidx(&front)] = -1;
    for (i = 0; i <= 4; i++) {
      if (front.s[i] == 'E') continue;
      j = 2 * (front.s[i]-'A') + 5;
      if (front.s[j] == 'E' && front.s[j+1] == 'E') {
	if (blocked(&front, i, j+1)) continue;
	temp = front;
	temp.s[i] = front.s[j+1];
	temp.s[j+1] = front.s[i];
	if (H.lut[stoidx(&temp)] < 0) continue;
	temp.cost += cost[i][j+1] * factor[front.s[i]-'A'];
	if (temp.cost < frontier_cost(&temp)) heap_insert(&temp);
      } else if (front.s[j] == 'E' && front.s[j+1] == front.s[i]) {
	if (blocked(&front, i, j)) continue;
	temp = front;
	temp.s[i] = front.s[j];
	temp.s[j] = front.s[i];
	if (H.lut[stoidx(&temp)] < 0) continue;
	temp.cost += cost[i][j] * factor[front.s[i]-'A'];
	if (temp.cost < frontier_cost(&temp)) heap_insert(&temp);
      }
    }
    for (i = 5; i <= 11; i += 2) {
      if (front.s[i] == 'E') continue;
      for (j = 0; j <= 4; j++) {
	if (front.s[j] != 'E') continue;
	if (blocked(&front, i, j)) continue;
	temp = front;
	temp.s[i] = front.s[j];
	temp.s[j] = front.s[i];
	if (H.lut[stoidx(&temp)] < 0) continue;
	temp.cost += cost[i][j] * factor[front.s[i]-'A'];
	heap_insert(&temp);
      }
    }
    for (i = 6; i <= 12; i += 2) {
      if (front.s[i] == 'E' || front.s[i-1] != 'E') continue;
      for (j = 0; j <= 4; j++) {
	if (front.s[j] != 'E') continue;
	if (blocked(&front, i, j)) continue;
	temp = front;
	temp.s[i] = front.s[j];
	temp.s[j] = front.s[i];
	if (H.lut[stoidx(&temp)] < 0) continue;
	temp.cost += cost[i][j] * factor[front.s[i]-'A'];
	if (temp.cost < frontier_cost(&temp)) heap_insert(&temp);
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
    initial.s[i] = 'E';
  }
  initial.s[5] = [lines[2] characterAtIndex:3];
  initial.s[6] = [lines[3] characterAtIndex:3];
  initial.s[7] = [lines[2] characterAtIndex:5];
  initial.s[8] = [lines[3] characterAtIndex:5];
  initial.s[9] = [lines[2] characterAtIndex:7];
  initial.s[10] = [lines[3] characterAtIndex:7];
  initial.s[11] = [lines[2] characterAtIndex:9];
  initial.s[12] = [lines[3] characterAtIndex:9];
  initial.s[13] = '\0';
  OFLog(@"%s", initial.s);
  for (i = 0; i <= 4; i++) {
    for (j = i + 1; j <= 4; j++) {
      cost[i][j] = 2 * (j - i);
    }
  }
  cost[0][5] = cost[1][5] = cost[1][7] = cost[2][7] = cost[2][9] = cost[3][9] = cost[3][11] = cost[4][11] = 2;
  cost[0][7] = cost[1][9] = cost[2][5] = cost[2][11] = cost[3][7] = cost[4][9] = 4;
  cost[0][9] = cost[1][11] = cost[3][5] = cost[4][7] = 6;
  cost[0][11] = cost[4][5] = 8;
  for (i = 0; i <= 4; i++) {
    for (j = 6; j <=12; j += 2) {
      cost[i][j] = cost[i][j-1] + 1;
    }
  }
  for (i = 0; i <= 12; i++) {
    for (j = i + 1; j <=12; j++) {
      cost[j][i] = cost[i][j];
    }
  }
  final = ucs(initial);
  OFLog(@"%s", final.s);
  [OFStdOut writeFormat:@"%lld\n", final.cost];
  [OFApplication terminate];
}
@end
