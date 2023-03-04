

#define HEAP_SIZE 1024
#define B_OVERHEAD (sizeof(struct block))

typedef unsigned int  u16;

struct block {
	u16 size;
	struct block *next;
};

/* vbcc can's seem to accept things being passed though a/x
 * (it always does wierd lda & pha's before, overwriting what was in a)
 * so i'll just use standard r0/r1
 */
void init_heap();
__reg("a/x") void *kalloc(/*__reg("a/x")*/ u16 size);
void kfree(/*__reg("a/x") */struct block *ptr);
/* NOTE: not actually a block ptr, just a normal void * */


static char heap[HEAP_SIZE];

static struct block *head;

/*
void inc() = "\tinclude ../emu.s";
void display() = "\tDISPLAY \"hi\"";
void update()  = "\tUPDATE";
void pause()   = "\tPAUSE";

void showpasm() = "\tlda r1\n\tldx r0\n\tUPDATE";
static void showp(__reg("r0/r1") u16 hi) {
	inc();
	showpasm();
}

void tests() {
	void *a, *b, *c, *d;
	showp((u16)(a = kalloc(256))); //pause();
	showp((u16)(b = kalloc(256))); //pause();
	showp((u16)(c = kalloc(256))); //pause();
	showp((u16)(d = kalloc(16))); pause();

	kfree(c);
	pause();
	kfree(a);
	pause();
	kfree(b);
	pause();
	kfree(d);
	pause();
}
*/

void init_heap() {
  head = (struct block *)&heap[0];
  head->size = HEAP_SIZE - B_OVERHEAD;
  head->next = 0;
}

__reg("a/x") void *kalloc(/*__reg("a/x")*/ u16 size) {
	struct block *prev = 0;
	struct block *cur = head;

	while (cur) {
		if (cur->size >= size) {
			/* only able to split if cur->size > size + (the overhead of an extra block) */
			if (cur->size > size + B_OVERHEAD + 0/*reasonable small size*/) {
				/* split block, allocate the top one (new) */
				/* first, make space in old block's size */
				cur->size -= size + B_OVERHEAD;
				/* then, make new (freed) block within that space */
				struct block *new = (struct block *)(((char *)cur) + cur->size + B_OVERHEAD);
				new->size = size;
				new->next = 0;

				/* return pointer to the data area just above the block entry */
				return (B_OVERHEAD + (char *)new);
			}
			else {
				/* found a block that matches reasonably well */
				if (prev) prev->next = cur->next;  /* bypass block "cur" */
				else head = cur->next;

				cur->next = 0;
				return (B_OVERHEAD + (char *)cur);
			}
		}
		prev = cur;
		cur = (cur)->next;
	}
	/* E_NOMEM here */
	return 0;
}



static void try_merge(struct block *lo, struct block *hi) {
	if ((((char *)lo) + B_OVERHEAD + lo->size) == (char *)hi) {
		/* merge to lo */
		lo->size += hi->size + B_OVERHEAD;
		lo->next = hi->next;
	}
}

void kfree(/*__reg("a/x") */struct block *ptr) {
	/* ptr actually points to the block entry + 1, so decrement it */
	ptr = (struct block *)((char *)ptr - B_OVERHEAD);
	struct block *prev = 0;
	struct block *cur = head;

	while (cur) {
		/* search for where ptr should go */
		if ((u16)cur > (u16)ptr) {
			/* cur is the first free entry above ptr */
			/* prev is the last free entry that was below ptr */
			/* insert freed block between cur and prev */
			ptr->next = cur;

			/* try merge cur into ptr */
			try_merge(ptr, cur);
			if (prev) {
				/* as long as prev is there, try merge down */
				prev->next = ptr;
				try_merge(prev, ptr);
			}
			else {
				/* change head from cur to ptr */
				head = ptr;
			}
			return;
		}
		prev = cur;
		cur = cur->next;
	}
	/* here, there is EITHER
	 *   -> no free block that is after ptr
	 *   -> head is NULL
	 *   (in the unlikely event that something allocated precisely HEAP_SIZE)
	 */
 	if (head) {
	 	/* so append it to last free block (prev) */
 		prev->next = ptr;
 		try_merge(prev, ptr);
 	}
 	else {
	 	head = ptr;
 	}
}
