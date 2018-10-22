@Example of file operation API calls using pread and pwrite. API calls found in this example program:
@ 	open, close, pread, pwrite, write, exit
@ High level description of what theis example program does:
@	Creates a new file with open() call and a filename specified at 'newfile' buffer.
@	Writes the contents in 'contents' buffer to this new file with the write() call.
@	Writes some different contents into the same file 8 bytes into the file with the pwrite() call.
@	Closes the file using close().
@	Re-opens the same existing file with open(), but in read-only mode this time.
@	Reads the file starting on the 8th byte using the pread() call
@	closes the file with close().
@	prints the contents of what was read to stdout (file descriptor 1) using write().
@	exits gracefully with exit().

.text
.global _start

_start:
@ Create new file with open() call and a filename specified at 'newfile' buffer
@------------------------------------------------------------------------------
	mov	r7, #5			@open
	ldr	r0, =newfile		@pointer to the filename
	mov	r1, #0102		@Flags, Create and Writable
	mov	r2, #0600		@Permissions
	swi	#0
	ldr	r1, =filehandle		@Get pointer to filehandle
	str	r0, [r1]		@Store filehandle number in that location

@Write the contents in 'contents' buffer to this new file with the write() call
@------------------------------------------------------------------------------
	mov	r7, #4			@write
	ldr	r0, =filehandle		@pointer to handle for opened file
	ldr	r0, [r0]		@value of file handle
	ldr	r1, =contents
	mov	r2, #47			@how many bytes to write
	swi	#0

@ Write different contents into same file 8 bytes into file with pwrite() call
@------------------------------------------------------------------------------
	mov	r7, #181		@pwrite
	ldr	r0, =filehandle		@pointer to handle for opened file
	ldr	r0, [r0]		@value of file handle
	ldr	r1, =modif
	mov	r2, #19			@how many bytes to write
	mov	r4, #8			@starting on the 8th byte of file (not r3)
	swi	#0

@ Close the file using close()
@------------------------------------------------------------------------------
	mov	r7, #6			@close
	ldr	r0, =filehandle
	ldr	r0, [r0]
	swi	#0

@ Re-open the same existing file with open(), but in read-only mode this time
@------------------------------------------------------------------------------
	mov	r7, #5			@open
	ldr	r0, =newfile		@pointer to the filename
	mov	r1, #0			@Flags, for Read Only
	swi	#0
	ldr	r1, =filehandle		@Get pointer to filehandle value
	str	r0, [r1]		@save filehandle

@ Read the file starting on the 8th byte using the pread() call
@------------------------------------------------------------------------------
	mov	r7, #180		@pread
	ldr	r0, =filehandle		@Get pointer for file handle
	ldr	r0, [r0]		@Get value of filehandle
	ldr	r1, =filebuffer		@data in memory
	mov	r2, #39			@read 39 bytes
	mov	r3, #8			@starting on the 8th byte of the file
	swi	#0

@ Close the file with close()
@------------------------------------------------------------------------------
	mov	r7, #6			@close
	ldr	r0, =filehandle
	ldr	r0, [r0]
	swi	#0

@ Print contents of what was read to stdout (file descriptor 1) using write()
@------------------------------------------------------------------------------
	mov	r7, #4			@write
	mov	r0, #1			@stdout
	ldr	r1, =filebuffer		@contents read from file
	mov	r2, #39			@how many bytes to print
	swi	#0

@ Exit program
@------------------------------------------------------------------------------
	mov	r7, #1
	swi	#0

.data
	newfile: .asciz "newfile.txt"
	contents: .ascii "This is an example of some contents of a file.\x0a"
	modif: .ascii "a modification of  "

.bss
	.lcomm filehandle, 4
	.lcomm filebuffer, 47

@ ------------------------------
@ | Some bitfield explanations |
@ ------------------------------

@ Mode Octal codes
@------------------------------------------------------------------------------
@	Read	4
@	Write	2
@	Execute	1

@ Flags octal codes (info from The Linux Programming Interface and 
@ https://code.woboq.org/userspace/glibc/sysdeps/unix/sysv/linux/bits/fcntl-linux.h.html)
@------------------------------------------------------------------------------
@	O_RDONLY    	0
@	O_WRONLY    	1
@	O_RDWR		2
@	O_ACCMODE	3
@	O_CREAT     	100
@	O_EXCL		200	(Create file exclusively, with CREAT; call fails if file already exists)
@	O_NOCTTY    	400	(Don’t let pathname become the controlling terminal)
@	O_TRUNC     	1000	(Truncate existing file to zero length)
@	O_APPEND	2000	(Append mode, also mitigates race conditions that lseek with SEEK_END doesn't)
@	O_NONBLOCK	4000	(Open in nonblocking mode)
@	O_DSYNC    	10000	(Provide synchronized I/O data integrity)
@	O_ASYNC		20000	(Generate a signal when I/O is possible)
@	O_DIRECT	40000	(File I/O bypasses buffer cache)
@	O_LARGEFILE	100000
@	O_DIRECTORY	200000	(Fail if pathname is not a directory)
@	O_NOFOLLOW	400000	(Don't dereference symbolic links)
@	O_NOATIME   	1000000	(Don't update access time with read syscall)
@	O_CLOEXEC   	2000000	(Set the close-on-exec flag)
@	O_SYNC		4010000	(Make file writes synchronous)
@	O_PATH     	10000000
@	O_TMPFILE   	20200000
