---
title: "Ch11 Threads"
subtitle: ""
date: 2025-09-25T20:46:08+08:00
lastmod: 2025-09-25T20:46:08+08:00
draft: false
author: "rltyty"
authorLink: ""
description: ""
license: ""
images: []

tags: ['Unix', 'Threads']
categories: ['IT']

featuredImage: ""
featuredImagePreview: ""

hiddenFromHomePage: false
hiddenFromSearch: false
twemoji: false
lightgallery: true
ruby: true
fraction: true
fontawesome: true
linkToMarkdown: true
rssFullText: false

toc:
  enable: true
  auto: true
  keepStatic: false
code:
  copy: true
  maxShownLines: 50
math:
  enable: true
  # ...
mapbox:
  # ...
share:
  enable: true
  # ...
comment:
  enable: true
  # ...
library:
  css:
    # someCSS = "some.css"
    # located in "assets/"
    # Or
    # someCSS = "https://cdn.example.com/some.css"
  js:
    # someJS = "some.js"
    # located in "assets/"
    # Or
    # someJS = "https://cdn.example.com/some.js"
seo:
  images: []
  # ...
---

<!--more-->
`pthreads` = `POSIX threads`

## Thread Identification `pthread_t`

- process ID (`pid_t`, `unsigned int`) vs thread ID (`struct pthread_t`)
- thread ID only within the context of the process to which it belongs

## Thread Creation

```c
#include <pthread.h>
int pthread_create(pthread_t *restrict tidp,
                   const pthread_attr_t *restrict attr,
                   void *(*start_rtn)(void *), void *restrict arg);

                   // Returns: 0 if OK, error number on failure
```
### The new thread shares with the main thread:

  - Code segment (functions)
  - Global/static variables
  - Heap (memory allocated via malloc)
  - Open file descriptors
  - Signal dispositions (mostly)

### The new thread has its own:
  - Stack
  - Thread ID
  - Registers, instruction pointer, etc.

### Signals and `errno`
  - new thread has access to the process address space and inherits the calling
    thread's floating-point environment (FPE) and signal mask.
  - the set of pending signals for the new thread is cleared.
  - pthread functions return error code when they fail rather than set global
    `errno`

### Thread creation and scheduling are inseparable

POSIX threads are meant to be a thin and portable abstraction over native OS
threads (clone() in Linux, mach_thread_create() in macOS). Both kernels start
the thread immediately once created.

### What if you want all threads to start at the same time?

Each thread starts running, but immediately waits at a barrier or condition
variable until the main thread signals "go". See [Barrier](<#create-all-threads-to-start-at-the-same-time>)

![Work queue](<./images/workqueue.png>)

## Thread Termination

A single thread can exit in three ways without terminating the entire process.

- Returns from the start routine. Return value is the thread's exit code.
- Gets cancelled by another thread in the same process. `pthread_cancel(3)`
- Calls `pthread_exit(3)`

```c
#include <pthread.h>

void pthread_exit(void *rval_ptr);

int pthread_join(pthread_t thread, void **rval_ptr);
                   // Returns: 0 if OK, error number on failure
int pthread_cancel(pthread_t tid);
                   // Returns: 0 if OK, error number on failure

void pthread_cleanup_push(void (*rtn)(void *), void *arg);
void pthread_cleanup_pop(int execute);

int pthread_detach(pthread_t tid);
                   // Returns: 0 if OK, error number on failure
```


If the target thread has already terminated, `pthread_join` will immediately
return with the thread’s exit status (without blocking).

The exit status comes from either:

- the value returned from the thread start function,
- or the argument passed to pthread_exit,
- or PTHREAD_CANCELED if it was canceled.

Lifetime semantics

- A `pthread_t` remains a valid handle until the thread is joined or detached.
- Even if the thread is long gone, the implementation keeps around its exit
  status until it’s collected by `pthread_join`.
- This prevents a race between "thread finished" and “main wants its status.”

## Comparison of process and thread primitives

![Comparison of process and thread primitives](<./images/procthrd-primitives.png>)

## Thread Synchronization

### Mutexes

A mutex is basically a lock that we set (lock) before accessing a shared
resource and release (unlock) when we’re done. While it is set, any other
thread that tries to set it will block until we release it.

- `pthread_mutex_t`:

  - `PTHREAD_MUTEX_INITIALIZER` (for statically allocated mutexes only)
  - `pthread_mutex_init(3)` (for dynamically allocated mutexes)


```c
int pthread_mutex_init(pthread_mutex_t *restrict mutex,
                       const pthread_mutexattr_t *restrict attr);
int pthread_mutex_destroy(pthread_mutex_t *mutex);
                // Both return: 0 if OK, error number on failure

int pthread_mutex_lock(pthread_mutex_t *mutex);
int pthread_mutex_trylock(pthread_mutex_t *mutex); // <- can’t afford to block
int pthread_mutex_unlock(pthread_mutex_t *mutex);
                // All return: 0 if OK, error number on failure

// macOS doesn't support
int pthread_mutex_timedlock(pthread_mutex_t *restrict mutex,
                            const struct timespec *restrict tsptr);
                // Returns: 0 if OK, error number on failure
```

### Deadlock Avoidance

A thread will deadlock itself if it tries to **lock the same mutex twice**.

When more than one mutex is used, the deadlock could occur if one thread is
holding a mutex and block while trying to lock a second mutex at the same
time that another thread holding the second mutex tries to lock the first
mutex.

Deadlocks can be avoided by carefully controlling **the order** in which mutexes
are locked. e.g. all threads always lock mutex A before mutex B, no deadlock
can occur from the use of the two mutexes.

The correct balance between code complexity and performance should be found,
while still satisfying your locking requirements.

- locking granularity too coarse, results in too many threads blocking behind
  the same locks, with little improvement possible from concurrency
- locking granularity too fine, results in bad performance from excess locking
  overhead and complex code.

### Reader-Writer Locks

Also called **shared–exclusive** locks.
- read locked, in shared mode
- write locked, in exclusive mode

```c
#include <pthread.h>
int pthread_rwlock_init(pthread_rwlock_t *restrict rwlock,
                        const pthread_rwlockattr_t *restrict attr);
int pthread_rwlock_destroy(pthread_rwlock_t *rwlock);

int pthread_rwlock_rdlock(pthread_rwlock_t *rwlock);
int pthread_rwlock_wrlock(pthread_rwlock_t *rwlock);
int pthread_rwlock_unlock(pthread_rwlock_t *rwlock);

int pthread_rwlock_tryrdlock(pthread_rwlock_t *rwlock);
int pthread_rwlock_trywrlock(pthread_rwlock_t *rwlock);

int pthread_rwlock_timedrdlock(pthread_rwlock_t *restrict rwlock,
                               const struct timespec *restrict tsptr);
int pthread_rwlock_timedwrlock(pthread_rwlock_t *restrict rwlock,
                               const struct timespec *restrict tsptr);

                        // All return: 0 if OK, error number on failure

int pthread_equal(pthread_t t1, pthread_t t2);
                        // Returns non-zero when t1 and t2 correspond to the
                        // same thread. Otherwise return 0.
```

Example: A queue of job requests is protected by a reader-writer lock.

- lock in write mode: add a job to the queue or remove a job from the queue
- lock in read mode : multiple threads search the queue concurrently

```c
#include <stdlib.h>
#include <pthread.h>

struct job {
	struct job *j_next;
	struct job *j_prev;
	pthread_t   j_id;   /* tells which thread handles this job */
	/* ... more stuff here ... */
};

struct queue {
	struct job      *q_head;
	struct job      *q_tail;
	pthread_rwlock_t q_lock;
};

/*
 * Initialize a queue.
 */
int
queue_init(struct queue *qp)
{
	int err;

	qp->q_head = NULL;
	qp->q_tail = NULL;
	err = pthread_rwlock_init(&qp->q_lock, NULL);
	if (err != 0)
		return(err);
	/* ... continue initialization ... */
	return(0);
}

/*
 * Insert a job at the head of the queue.
 */
void
job_insert(struct queue *qp, struct job *jp)
{
	pthread_rwlock_wrlock(&qp->q_lock);
	jp->j_next = qp->q_head;
	jp->j_prev = NULL;
	if (qp->q_head != NULL)
		qp->q_head->j_prev = jp;
	else
		qp->q_tail = jp;	/* list was empty */
	qp->q_head = jp;
	pthread_rwlock_unlock(&qp->q_lock);
}

/*
 * Append a job on the tail of the queue.
 */
void
job_append(struct queue *qp, struct job *jp)
{
	pthread_rwlock_wrlock(&qp->q_lock);
	jp->j_next = NULL;
	jp->j_prev = qp->q_tail;
	if (qp->q_tail != NULL)
		qp->q_tail->j_next = jp;
	else
		qp->q_head = jp;	/* list was empty */
	qp->q_tail = jp;
	pthread_rwlock_unlock(&qp->q_lock);
}

/*
 * Remove the given job from a queue.
 */
void
job_remove(struct queue *qp, struct job *jp)
{
	pthread_rwlock_wrlock(&qp->q_lock);
	if (jp == qp->q_head) {
		qp->q_head = jp->j_next;
		if (qp->q_tail == jp)
			qp->q_tail = NULL;
		else
			jp->j_next->j_prev = jp->j_prev;
	} else if (jp == qp->q_tail) {
		qp->q_tail = jp->j_prev;
		jp->j_prev->j_next = jp->j_next;
	} else {
		jp->j_prev->j_next = jp->j_next;
		jp->j_next->j_prev = jp->j_prev;
	}
	pthread_rwlock_unlock(&qp->q_lock);
}

/*
 * Find a job for the given thread ID.
 */
struct job *
job_find(struct queue *qp, pthread_t id)
{
	struct job *jp;

	if (pthread_rwlock_rdlock(&qp->q_lock) != 0)
		return(NULL);

	for (jp = qp->q_head; jp != NULL; jp = jp->j_next)
		if (pthread_equal(jp->j_id, id))
			break;

	pthread_rwlock_unlock(&qp->q_lock);
	return(jp);
}
```

Using a reader-writer lock will improve performance in this case only if
threads search the queue much more frequently than they add or remove jobs.

### Condition Variables

These synchronization objects provide a place for threads to ***rendezvous***.

***Mutex*** must be locked to be able to evaluate or change the condition.

Being protected by mutex, condition variables allow threads to ***wait*** in a
race-free way ***for*** arbitrary ***conditions*** to occur.

```c
#include <pthread.h>

int pthread_cond_init(pthread_cond_t *restrict cond,
                      const pthread_condattr_t *restrict attr);
int pthread_cond_destroy(pthread_cond_t *cond);

int pthread_cond_wait(pthread_cond_t *restrict cond,
                      pthread_mutex_t *restrict mutex);
int pthread_cond_timedwait(pthread_cond_t *restrict cond,
                           pthread_mutex_t *restrict mutex,
                           const struct timespec *restrict tsptr);

int pthread_cond_signal(pthread_cond_t *cond);
int pthread_cond_broadcast(pthread_cond_t *cond);

                        // All return: 0 if OK, error number on failure
```

The  `pthread_cond_wait()` function **atomically** blocks the current thread
waiting on the condition variable specified by `cond`, and **releases** the mutex
specified by `mutex`.  The waiting thread unblocks only after another thread
calls `pthread_cond_signal(3)`, or `pthread_cond_broadcast(3)` with the same
condition variable, and the current thread reacquires the lock on mutex.

Thus, `pthread_cond_wait(cond, mutex)` does two things **atomically**:

- Releases the `mutex`.
- Puts the thread to sleep on the condition variable `cond`.

When the thread is later awakened (via `pthread_cond_signal()` or
`pthread_cond_broadcast()`), it reacquires the same mutex **before returning**.

This atomic ***unlock-and-sleep*** operation is the key reason you must hold
the mutex before calling it — otherwise, the shared state that the condition
represents could change between checking it and sleeping, creating a race
condition.

The standard idiom for using `pthread_cond_wait()` is:

```c
pthread_mutex_lock(&q->lock);
while (queue_empty(q))  // predicate check must be done under the lock
    pthread_cond_wait(&q->cond, &q->lock);
dequeue_job(q);
pthread_mutex_unlock(&q->lock);
```


### Spin Locks

A spin lock is like a mutex, except that instead of blocking a process by
sleeping, the process is blocked by busy-waiting (spinning) until the lock can
be acquired.

```c
#include <pthread.h>

int pthread_spin_init(pthread_spinlock_t *lock, int pshared);
int pthread_spin_destroy(pthread_spinlock_t *lock);

int pthread_spin_lock(pthread_spinlock_t *lock);
int pthread_spin_trylock(pthread_spinlock_t *lock);
int pthread_spin_unlock(pthread_spinlock_t *lock);

                        // All return: 0 if OK, error number on failure
```

### Barriers

Barriers are a synchronization mechanism that can be used to coordinate
multiple threads working in parallel. A barrier allows each thread to wait
until all cooperating threads have reached the same point, and then continue
executing from there.

```c
#include <pthread.h>

int pthread_barrier_init(pthread_barrier_t *restrict barrier,
                         const pthread_barrierattr_t *restrict attr,
                         unsigned int count);
int pthread_barrier_destroy(pthread_barrier_t *barrier);

                        // Both return: 0 if OK, error number on failure

int pthread_barrier_wait(pthread_barrier_t *barrier);
                        // Returns: 0 or PTHREAD_BARRIER_SERIAL_THREAD if OK, error number on failure
```

- `pthread_barrier_init(3)`:
  - initialize the barrier object
  - set the number of threads to rendezvous (calling `pthread_barrier_wait(3)`)
- `pthread_barrier_wait(3)`:
  - after the specified number of threads that have called
    `pthread_barrier_wait(3)`, all threads proceed.
  - Return value: `PTHREAD_BARRIER_SERIAL_THREAD` for one (arbitrary) calling
    thread, 0 for all the other calling threads. This lets you do some
    once-only work. Example:

```c
void *worker(void *arg) {
  do_some_work(arg);

  // Wait for all threads
  int rc = pthread_barrier_wait(&barrier);

  if (rc == PTHREAD_BARRIER_SERIAL_THREAD) {
    save_results();   // only one thread does this
  }

  return NULL;
}
```

#### Create all threads to start at the same time

```c
#include <pthread.h>
#include <stdio.h>

#define NTHR 4
pthread_barrier_t barrier;

void *worker(void *arg) {
    long id = (long)arg;
    printf("Thread %ld created, waiting...\n", id);

    // Wait until all threads (and main) reach this point
    pthread_barrier_wait(&barrier);

    printf("Thread %ld starts work!\n", id);
    return NULL;
}

int main(void) {
    pthread_t tids[NTHR];
    pthread_barrier_init(&barrier, NULL, NTHR + 1);  // +1 for main

    for (long i = 0; i < NTHR; i++)
        pthread_create(&tids[i], NULL, worker, (void *)i);

    // All threads are created now
    printf("Main: releasing all threads...\n");
    pthread_barrier_wait(&barrier);

    for (int i = 0; i < NTHR; i++)
        pthread_join(tids[i], NULL);
    pthread_barrier_destroy(&barrier);
}
```

## Exercises

### Ex 11.1

[Source](https://github.com/rltyty/apue.3e/blob/main/mytests/threads/Ex11_1_good_exit.c)

To extend the lifetime of an object beyond the function that returns it,
allocate the memory dynamically instead of using an automatic variable.

```c
void *
thr_fn1(void *arg)
{
    struct foo *fp;
    if ((fp = malloc(sizeof(struct foo))) == NULL)  // dynamic allocation
        err_sys("can’t allocate memory");
    fp->a = 1;
    fp->b = 2;
    fp->c = 3;
    fp->d = 4;
    printfoo("thread:\n", fp);
    return((void *)fp);
}
```

### Ex 11.3

[Source](<https://github.com/rltyty/apue.3e/blob/main/mytests/threads/Ex11_3_workerthrd.c>)

### Ex 11.5
[Source](<https://github.com/rltyty/apue.3e/blob/main/mytests/threads/Ex11_5.barrier_wait.c>)


## NOTE

`struct timespec`, `struct tm` and `struct timevalue`

```c
#include <time.h>

struct tm {
	int	tm_sec;		    /* seconds after the minute [0-60] */
	int	tm_min;		    /* minutes after the hour [0-59] */
	int	tm_hour;	    /* hours since midnight [0-23] */
	int	tm_mday;	    /* day of the month [1-31] */
	int	tm_mon;		    /* months since January [0-11] */
	int	tm_year;	    /* years since 1900 */
	int	tm_wday;	    /* days since Sunday [0-6] */
	int	tm_yday;	    /* days since January 1 [0-365] */
	int	tm_isdst;	    /* Daylight Savings Time flag */
	long	tm_gmtoff;	/* offset from UTC in seconds */
	char	*tm_zone;	/* timezone abbreviation */
};

struct timespec {           /* Modern POSIX and C standards */
    time_t      tv_sec;     /* Seconds */
    long        tv_nsec;    /* Nanoseconds */
};

struct t̶i̶m̶e̶v̶a̶l̶ {            /* Obsolescent */
    time_t       tv_sec;    /* Seconds */
    suseconds_t  tv_usec;   /* Microseconds */
};

```
