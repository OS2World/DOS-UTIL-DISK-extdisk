		title	extdisk
		page	66,132
;
; Utility to display presence of BIOS INT 13H extensions
;
; Version: 1.1
;
; History:
;	1.0	Initial released version
;	1.1	Added display of C/H/S information
;
; Bob Eager   April 2006
;
		subttl	Constants
		page+
;
; Constant definitions
;
cr		equ	0dh		; Carriage return
lf		equ	0ah		; Linefeed
;
worksize	equ	11		; Size of number work area
;
		subttl	Macros
		page+
;
$msg		macro	x		;; output message at x (or DX)
		mov	ah,9		;; output message
		ifnb	<x>
		mov	dx,offset x	;; intro message
		endif
		int	21h		;; output it
		endm
;
		subttl	Structures
		page+
;
par		struc			; Drive parameters
par_size	dw	?		; Size of structure
par_flags	dw	?		; Information flags
par_cyls	dd	?		; Cylinders
par_heads	dd	?		; Heads
par_sectrk	dd	?		; Sectors per track
par_sectors	dq	?		; Total sectors
par_secsize	dw	?		; Bytes per sector
par		ends
;
		subttl	Main code
		page+
;
cseg		segment
;
		assume	cs:cseg,ds:cseg,es:cseg,ss:cseg
;
		org	100h
;
begin		proc	near
;
; See if INT 13H extensions are supported
;
		$msg	mes0		; "Version x.x"
;
		$msg	mes10		; "Reporting on hard drive "
		mov	al,drive	; get drive number
		cbw			; make 16 bit
		cwd			; make 32 bit
		call	putnum		; convert number
		$msg			; output it
		$msg	mes9		; newline
;
		$msg	mes1		; "INT 13H extensions are "
		mov	ah,41h		; check function
		mov	bx,55aah	; magic flag
		mov	dl,drive	; get drive number
		or	dl,80h		; convert to right form
		int	13h		; do it
		jc	int10		; j if not supported
		cmp	bx,0aa55h	; must be set too
		je	int20		; j if supported
;
int10:		$msg	mes2		; "not "
		dec	supp		; mark not supported
;
int20:		$msg	mes3		; "supported"
		cmp	supp,0		; see if want physical data
		je	int90		; j if not
;
; Output physical C/H/S data
;
		mov	ah,48h		; get drive parameters
		mov	dl,drive	; get drive number
		or	dl,80h		; convert to right form
		lea	si,parbuf	; result buffer
		mov	ax,size parbuf	; need to set
		mov	[si].par_size,ax; set size
		int	13h		; do it
		jnc	int30		; j if OK
		$msg	mes4		; "Cannot get physical C/H/S..."
		jmp	short int90	; and skip output
;
; All data are now in the 'parbuf' structure.
;
int30:		mov	ax,parbuf.par_flags
					; get information flags
		test	ax,02h		; geometry supported?
		jnz	int35		; j if so
		$msg	mes11		; "Physical geometry not available"
		jmp	short int90	; skip the rest
;
int35:		$msg	mes5		; "Physical C/H/S = "
		mov	ax,word ptr parbuf.par_cyls
		mov	dx,word ptr parbuf.par_cyls+2
		call	putnum		; convert cylinders
		$msg			; output cylinders
		$msg	mes8		; "/"
		mov	ax,word ptr parbuf.par_heads
		mov	dx,word ptr parbuf.par_heads+2
		call	putnum		; convert heads
		$msg			; output heads
		$msg	mes8		; "/"
		mov	ax,word ptr parbuf.par_sectrk
		mov	dx,word ptr parbuf.par_sectrk+2
		call	putnum		; convert sectors
		$msg			; output sectors
		$msg	mes9		; newline
;
; Output logical C/H/S data
;
int90:		mov	ah,08h		; get drive parameters
		mov	dl,drive	; get drive number
		or	dl,80h		; convert to right form
		int	13h		; do it
		jnc	int95		; j if all OK
		$msg	mes6		; "Cannot get logical C/H/S..."
		jmp	short int99	; and exit
;
; CH = low 8 bits of max cylinder number
; CL = bits 6-7, high 2 bits of max cylinder number
;    = bits 0-5, max sector number
; DH = max head number
;
int95:		push	cx		; save sectors
		push	dx		; save heads
		push	cx		; save cylinders
		$msg	mes7		; "Logical C/H/S = "
	int 3
		pop	ax		; recover cylinders
		xchg	al,ah		; now almost correct
		mov	cl,6		; to move into place
		shr	ah,cl		; now correct
		xor	dx,dx		; high order word
		call	putnum		; convert cylinders
		$msg			; output cylinders
		$msg	mes8		; "/"
		pop	ax		; recover heads
		xchg	al,ah		; move into place
		xor	ah,ah		; lose extraneous part
		xor	dx,dx		; high order word
		call	putnum		; convert heads
		$msg			; output heads
		$msg	mes8		; "/"
		pop	ax		; recover sectors
		xor	ah,ah		; lose cylinder part
		and	al,3fh		; lose other cylinder part
		xor	dx,dx		; high order word
		call	putnum		; convert sectors
		$msg			; output sectors
		$msg	mes9		; newline
;
int99:		mov	ax,4c00h	; exit with zero status
		int	21h
;
begin		endp
;
		subttl	Build number string
		page+
;
; Build a decimal number string in the work area. Returns pointer to start
; of (minimal width) number. String is terminated with a '$' character,
; ready for output.
;
; On entry:
;	DX:AX	number
; On exit:
;	DX	offset of work area
;
putnum		proc	near
;
		push	di		; save registers
		push	cx
;
		lea	di,work+worksize; beyond last digit position
		mov	cx,10		; divisor
	int 3
;
putn10:		div	cx		; divide by 10, DX=remainder,AX=quotient
		add	dl,'0'		; convert to digit
		dec	di		; make space
		mov	[di],dl		; store it
		xor	dx,dx		; for next time
		or	ax,ax		; more to do?
		jnz	putn10		; j if so
;
		mov	dx,di		; copy final pointer
;
		pop	cx
		pop	di		; recover register
;
		ret			; and return
;
putnum		endp
;
		subttl	Variable data
		page+
;
		align	2
parbuf		par	<>			; Parameter return buffer
work		db	worksize dup (?),'$'	; number work area
supp		db	1			; set to 1 if extensions supported
drive		db	0			; drive number
;
		subttl	Constant data
		page+
;
mes0		db	'Version 1.1',cr,lf,'$'
mes1		db	'INT 13H extensions are ','$'
mes2		db	'not ','$'
mes3		db	'supported',cr,lf,'$'
mes4		db	'Cannot get physical C/H/S information',cr,lf,'$'
mes5		db	'Physical C/H/S = ','$'
mes6		db	'Cannot get logical C/H/S information',cr,lf,'$'
mes7		db	'Logical C/H/S = ','$'
mes8		db	'/','$'
mes9		db	cr,lf,'$'
mes10		db	'Reporting on hard drive ','$'
mes11		db	'Physical geometry not available',cr,lf,'$'
;
cseg		ends
;
		end	begin
