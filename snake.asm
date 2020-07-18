[org 0x100]

jmp start

snake:		dw 2000, 2002, 2004, 2006, 2008, 2010, 2012, 2014, 2016, 2018, 2020, 2022, 2024, 2026, 2028, 2030, 2032, 2034, 2036, 2038
			times 1980 dw 0
ogsnake:	dw 2000, 2002, 2004, 2006, 2008, 2010, 2012, 2014, 2016, 2018, 2020, 2022, 2024, 2026, 2028, 2030, 2032, 2034, 2036, 2038
			times 1980 dw 0
direction:	dw 0						;0 for left, 1 for right, 2 for up, 3 for down
slength:	dw 20
ticks:		dw 0
second: 	dw 0
minute:		dw 0
flag: 		dw 1
hour: 		dw 0
life: 		db 'Lives:3', 0
lives:		dw 3						;254 location for showing lives
total:		dw 0
copyright:	db 'Snake v 2.0 by UMAR', 0
fruit: 		dw 0
fruitpos:	dw 0
difficulty:	db 'Do you want to start the game? (y/n)', 0
dead:		db 'All lives are lost! GAME OVER :(', 0
result:		db 'Your total score = ', 0
mscore:		db 'Score=20', 0
mstage:		db 'Stage=1', 0
stage:		dw 1
heart:		dw 0
killer:		dw 0
tip:		db 'Pro Tip : Do not let your snake be lured by the music of flute and look for     heart to get a +1.', 0
shapes:		db 23h,'$','%','{','}','|','/','?', 'O', 155
sidewall:	dw 478, 480, 638, 640, 798, 800, 958, 960, 1118, 1120, 1278, 1280, 1438, 1440, 1598, 1600, 1758, 1760, 1918, 1920, 2078, 2080, 				   2238, 2240, 2398, 2400, 2558, 2560, 2718, 2720, 2878, 2880, 3038, 3040, 3198, 3200, 3358, 3360, 3518, 3520, 3678, 3680 

clrscr:		push ax
			push cx
			push es
			push di
			push 0xb800
			pop es
			mov cx, 2000
			mov ax, 0x0720
			mov di, 0
			cld
			rep stosw
			pop di
			pop es
			pop cx
			pop ax
			ret

beep:		in al, 61h  ;Save state
			pusha	  
			mov bx, 6818; 1193180/175
			mov al, 6bh  ; select channel 2, write lsb/bsb mode 3
			out 43h, al	 
			mov ax, bx	
			out 42h, al  ; send the lsb
			mov al, ah	 
			out 42h, al  ; send the msb
			in al, 61h	 ; get the 8255 port contence
			or al, 3h		
			out 61h, al  ;end able speaker and use clock channel 2 for input
			mov cx, 03h ; high order wait value
			mov dx, 0d04h; low order wait value
			mov ax, 86h;wait service
			int 15h			
			popa;restore speaker state
			out 61h, al
			ret

tborder:	pusha
			push 0xb800
			pop es
			mov di, 0
lp1:		mov word [es:di], 0x3020
			add di, 2
			cmp di, 320
			jne lp1
			mov di, 478
lp2:		mov word [es:di], 0x3020
			add di, 160
			cmp di, 3998
			jne lp2
			mov di, 320
lp3:		mov word [es:di], 0x3020
			add di, 160
			cmp di, 3840
			jne lp3
			mov di, 3840
lp4:		mov word [es:di], 0x3020
			add di, 2
			cmp di, 4000
			jne lp4
			popa
			ret

printnum: 	push bp
			mov bp, sp
			push es
			push ax
			push bx
			push cx
			push dx
			push di
			mov ax, 0xb800
			mov es, ax ; point es to video base
			mov ax, [bp+4] ; load number in ax
			mov bx, 10 ; use base 10 for division
			mov cx, 0 ; initialize count of digits
nextdigit:  mov dx, 0 ; zero upper half of dividend
			div bx ; divide by 10
			add dl, 0x30 ; convert digit into ascii value
			push dx ; save ascii value on stack
			inc cx ; increment count of values
			cmp ax, 0 ; is the quotient zero
			jnz nextdigit ; if no divide it again
			mov di, [bp+6]
nextpos:    pop dx ; remove a digit from the stack
			mov dh, 0x04 ; use normal attribute
			mov [es:di], dx ; print char on screen
			add di, 2 ; move to next screen location
			loop nextpos ; repeat for all digits on stack
			pop di
			pop dx
			pop cx
			pop bx
			pop ax
			pop es
			pop bp
			ret 4

watch:		pusha
			push 0xb800
			pop es
			mov al, ':'
			mov ah, 4
			mov bx, 0x0430
			mov word [es:318], bx
			mov word [es:316], bx
			mov word [es:314], ax
			mov word [es:312], bx
			mov word [es:310], bx
			mov word [es:308], ax
			mov al, 'e'
			mov word [es:306], ax
			mov al, 'm'
			mov word [es:304], ax
			mov al, 'i'
			mov word [es:302], ax
			mov al, 'T'
			mov word [es:300], ax
			popa
			ret

strlen:		push bp
			mov bp, sp
			push ax
			push cx
			push di
			push es
			cld
			les di, [bp+4]
			mov al, 0
			mov cx, 0xffff
			repne scasb
			mov ax, 0xffff
			sub ax, cx
			dec ax
			mov [bp+8], ax
			pop es
			pop di
			pop cx
			pop ax
			pop bp
			ret 4

printstr:	push bp
			mov bp, sp
			pusha
			lds si, [bp+8]
			push 0
			push ds
			push si
			call strlen
			pop cx
			push 0xb800
			pop es
			mov bx, [bp+6]
			mov di, [bp+4]
			mov ax, 80
			mul bx
			add ax, di
			shl ax, 1
			mov di, ax
			mov ah, [bp+12]
			cld

ploop1:		lodsb 
			stosw
			loop ploop1

			popa
			pop bp
			ret 8

kbisr:		push ax
			in al, 0x60
			cmp al, 0x48		;up key
			je moveup
			cmp al, 0x50		;down key
			je movedown
			cmp al, 0x4b		;left key
			je moveleft
			cmp al, 0x4d		;right key
			je moveright
			jmp _return
moveup: 	cmp word [cs:direction], 3
			je _return
			mov word [cs:direction], 2
			jmp _return
movedown:	cmp word [cs:direction], 2
			je _return
			mov word [cs:direction], 3
			jmp _return
moveleft:	cmp word [cs:direction], 1
			je _return
			mov word [cs:direction], 0
			jmp _return
moveright:	cmp word [cs:direction], 0
			je _return
			mov word [cs:direction], 1		
_return:	mov al, 0x20
			out 0x20, al
			pop ax
			iret

timer:		push ax
			push bx
			push cx
			push dx
			push si
			push di
			push es
			push 0xb800
			pop es
			mov word [es:0], 0x3020
			mov word [es:2], 0x3020
			mov word [es:4], 0x3020
			mov word [es:6], 0x3020
			mov word [cs:8], 0x3020
			cmp word [cs:slength], 240
			jl goup
			inc word [cs:stage]
			push 192
			push word [cs:stage]
			call printnum
			mov word [cs:second], 0
			mov word [cs:minute], 0
			call watch
			push cs
			pop ds
			mov si, snake
			mov cx, [cs:slength]
loop30:		mov di, [si]
			mov word [es:di], 0x0720
			add si, 2
			loop loop30
			mov word [cs:slength], 20
			inc word [cs:lives]
			push 252
			push word [cs:lives]
			call printnum
goup:		cmp word [cs:lives], 0
			jnl carryon
			call clrscr
			push 7
			push cs
			push dead
			push 10
			push 20
			call printstr
			push 7
			push cs
			push result
			push 11
			push 20
			call printstr
			push 1840
			push word [cs:slength]
			call printnum
			jmp far [cs:terminate]
carryon:	cmp word [cs:total], 120
			jne goto
			mov al, 3
			mov ah, 4
			mov word [es:3350], ax
			mov al, 14
			mov ah, 5
			mov word [cs:heart], 1
			mov word [cs:killer], 1
			mov word [es:2260], ax
goto:		cmp word [cs:total], 240
			jnae carryon1
			cmp word [cs:slength], 240
			jge carryon1
			mov word [cs:total], 0
			mov word [cs:second], 0
			mov word [cs:minute], 0
			call watch
			dec word [cs:lives]
			push 252
			push word [cs:lives]
			call printnum
carryon1:	cmp word [cs:fruit], 0
			jne shortc
			mov ax, [cs:second]
			mov cl, 0xff
			mul cl
			mov cx, 4000
			div cx
			mov bx, 1
			test bx, dx
			jz continue1
			inc dx
			jmp continue1
shortc:		jmp continue
continue1:	cmp dx, 320					;ensuring that fruit doesn't land on walls
			jg continue2
			add dx, 322
			jmp continue2
continue2:	cmp dx, 3840
			jl continue3
			sub dx, 160
continue3:	mov cx, 46
			push cs
			pop ds
			mov si, sidewall
loop7:		cmp dx, [si]
			je continue4
			add si, 2
			loop loop7
			jmp continue5
continue4:	add dx, 4
continue5:	mov cx, [cs:slength]
			push cs
			pop ds
			mov si, snake
loop20:		cmp dx, [si]
			je change
			add si, 2
			loop loop20
			jmp cont5	
change:		mov di, 322
			mov al, '='
			mov ah, 4
			mov word [cs:fruitpos], di
			mov word [es:di], ax
			jmp continue
cont5:		mov si, dx
			mov ax, [cs:ticks]
			mov cl, 10
			div cl
			xor bx, bx
			mov bl, ah
			mov al, [cs:shapes+bx]
			mov ah, 0x04
			mov word [es:si], ax
			mov word [cs:fruit], 1
			mov word [cs:fruitpos], si
continue:	inc word [cs:ticks]
			cmp word [cs:ticks], 18
			je update
			jmp work
update:		mov word [cs:ticks], 0
			inc word [cs:second]
			inc word [cs:total]
			cmp word [cs:second], 10
			jge cont1
			mov word [es:316], 0x0430
			push 318
			push word [cs:second]
			call printnum
			jmp loop1
short1:		jmp reset
cont1:		push 316
			push word [cs:second]
			call printnum
loop1:		cmp word [cs:second], 59
			je l1
			jmp return
l1:			mov word [cs:second], 0
			inc word [cs:minute]
			cmp word [cs:minute], 10
			jge cont2
			push 312
			push word [cs:minute]
			call printnum
			jmp loop2
cont2:		push 310
			push word [cs:minute]
			call printnum
loop2:		cmp word [cs:minute], 59
			je l2
			jmp return
l2:			mov word [cs:minute], 0
			inc word [cs:hour]
			push 304
			push word [cs:hour]
			call printnum
return:		jmp work
reset:		push 0xb800
			pop es
			mov al, 0x30
			mov ah, 0x04
			mov bl, ':'
			mov bh, 0x04
			mov word [es:318], ax
			mov word [es:316], ax
			mov word [es:314], bx
			mov word [es:312], ax
			mov word [es:310], ax
			mov word [es:308], bx
			mov word [es:306], ax
			mov word [es:304], ax
			mov word [cs:flag], 0
			mov word [cs:second], 0
			mov word [cs:minute], 0
			mov word [cs:hour], 0
			jmp update	
		
work:		mov ax , [cs:snake]
			cmp ax, 322
			jnae boundary
			cmp ax, 3838
			jnbe boundary
			mov cx, 42
			push cs
			pop ds
			mov si, sidewall
b1:			mov bx, [si]
			cmp ax, bx
			je boundary
			add si, 2
			loop b1
			mov si, snake
			add si, 2
			mov cx, [cs:slength]
			dec cx
b2:			mov bx, [si]
			cmp ax, bx
			je boundary
			add si, 2
			loop b2

cont6:		cmp word [cs:direction], 1
			je shortr
			cmp word [cs:direction], 0
			je shortl1
			cmp word [cs:direction], 2
			je shortu1
			cmp word [cs:direction], 3
			je shortd1
			jmp exit
shortr:		jmp rsnake
boundary:	mov di, 478
lpp2:		mov word [es:di], 0x3020
			add di, 160
			cmp di, 3998
			jne lpp2
			mov di, 320
lpp3:		mov word [es:di], 0x3020
			add di, 160
			cmp di, 3840
			jne lpp3
			mov di, 3840
lpp4:		mov word [es:di], 0x3020
			add di, 2
			cmp di, 4000
			jne lpp4
			dec word [cs:lives]
			push 252
			push word [cs:lives]
			call printnum
			push cs
			pop ds
			mov si, snake
			mov cx, [cs:slength]
			jmp space
shortl1:	jmp shortl
shortd1:	jmp shortd
shortu1:	jmp shortu
space:		mov di, [si]
			mov word [es:di], 0x0720
			add si, 2
			loop space
			push cs
			pop ds
			mov di, snake
			mov si, ogsnake
			push cs
			pop es
			mov cx, 2000
			rep movsw
			mov word [cs:direction], 0
			push 0xb800
			pop es
			jmp cont6
shortl:		jmp lsnake						;intermediate jump
rsnake:		push cs
			pop ds
			mov si, snake
			mov cx, [cs:slength]
sl1:		mov di, [si]					;clear previous snake
			mov word [es:di], 0x0720
			add si, 2
			loop sl1
			push cs
			pop ds
			mov si, snake
			mov cx, [cs:slength]
			dec cx
			mov bx, cx
			shl bx, 1
			jmp ml1
shortu:		jmp usnake
shortd: 	jmp dsnake
ml1:		mov ax, [si+bx-2]				;update co-ordinates of snake in memory
			mov word [si+bx], ax
			sub bx, 2
			loop ml1
			add word [cs:snake], 2			;mov head to right
			mov al, '@'
			mov ah, 0x02
			mov di, [si]
			mov word [es:di], ax
			mov cx, [cs:slength]
			dec cx
			add si, 2
			mov al, '*'
pl1:		mov di, [si]
			mov word [es:di], ax
			add si, 2
			loop pl1
cont7:		cmp word [cs:heart], 0
			je cont8
			mov ax, [cs:snake]
			cmp ax, 3350
			jne cont8
			inc word [cs:lives]
			push 252
			push word [cs:lives]
			call printnum
			mov word [cs:heart], 0
cont8:		cmp word [cs:killer], 0
			je cont
			mov ax, [cs:snake]
			cmp ax, 2260
			jne cont
			call beep
			dec word [cs:lives]
			push 252
			push word [cs:lives]
			call printnum
			mov word [cs:killer], 0
cont:		mov ax, [cs:snake]
			cmp ax, [cs:fruitpos]
			jne shoutr
			mov bx, [cs:slength]
			add word [cs:slength], 4
			mov word [cs:fruit], 0
			push 212
			push word [cs:slength]
			call printnum
			call beep
			dec bx
			shl bx, 1
			mov dx, bx
			mov ax, [cs:snake+bx]
			sub bx, 2
			mov cx, [cs:snake+bx]
			push cs
			pop ds
			mov si, snake
			mov bx, dx
			jmp cont4
shoutr:		jmp outr
cont4:		mov di, [si+bx]
			sub ax, cx
			mov cx, 4
			cmp ax, 2
			je incr1
			cmp ax, 160
			je incd1
			cmp ax, -2
			je incl1
			cmp ax, -160
			je incu1
incr1:		add di, 2
			mov word [si+bx+2], di
			add si, 2
			loop incr1
			jmp outr
incl1:		sub di, 2
			mov word [si+bx+2], di
			add si, 2
			loop incl1
			jmp outr
incd1:		add di, 160
			mov word [si+bx+2], di
			add si, 2
			loop incd1
			jmp outr
incu1:		sub di, 160
			mov word [si+bx+2], di
			add si, 2
			loop incu1
			jmp outr		
outr:		jmp exit
lsnake:		push cs
			pop ds
			mov si, snake
			mov cx, [cs:slength]
sl2:		mov di, [si]					;clear previous snake
			mov word [es:di], 0x0720
			add si, 2
			loop sl2
			push cs
			pop ds
			mov si, snake
			mov cx, [cs:slength]
			dec cx
			mov bx, cx
			shl bx, 1
ml2:		mov ax, [si+bx-2]				;update co-ordinates of snake in memory
			mov word [si+bx], ax
			sub bx, 2
			loop ml2
			sub word [cs:snake], 2			;mov head to left
			mov al, '@'
			mov ah, 0x02
			mov di, [si]
			mov word [es:di], ax
			mov cx, [cs:slength]
			dec cx
			add si, 2
			mov al, '*'
pl2:		mov di, [si]
			mov word [es:di], ax
			add si, 2
			loop pl2
cont13:		cmp word [cs:heart], 0
			je cont14
			mov ax, [cs:snake]
			cmp ax, 3350
			jne cont14
			inc word [cs:lives]
			push 252
			push word [cs:lives]
			call printnum
			mov word [cs:heart], 0
cont14:		cmp word [cs:killer], 0
			je gosnake2
			mov ax, [cs:snake]
			cmp ax, 2260
			jne gosnake2
			call beep
			dec word [cs:lives]
			push 252
			push word [cs:lives]
			call printnum
			mov word [cs:killer], 0
gosnake2:	mov ax, [cs:snake]
			cmp ax, [cs:fruitpos]
			jne shoutl
			mov bx, [cs:slength]
			add word [cs:slength], 4
			mov word [cs:fruit], 0
			push 212
			push word [cs:slength]
			call printnum
			call beep
			dec bx
			shl bx, 1
			mov dx, bx
			mov ax, [cs:snake+bx]
			sub bx, 2
			mov cx, [cs:snake+bx]
			push cs
			pop ds
			mov si, snake
			mov bx, dx
			jmp cont3
shoutl:		jmp outl
cont3:	    mov di, [si+bx]
			sub ax, cx
			mov cx, 4
			cmp ax, 2
			je incr2
			cmp ax, 160
			je incd2
			cmp ax, -2
			je incl2
			cmp ax, -160
			je incu2
incr2:		add di, 2
			mov word [si+bx+2], di
			add si, 2
			loop incr2
			jmp outl
incl2:		sub di, 2
			mov word [si+bx+2], di
			add si, 2
			loop incl2
			jmp outl
incd2:		add di, 160
			mov word [si+bx+2], di
			add si, 2
			loop incd2
			jmp outl
incu2:		sub di, 160
			mov word [si+bx+2], di
			add si, 2
			loop incu2
			jmp outl		
outl:		jmp exit
usnake:		push cs
			pop ds
			mov si, snake
			mov cx, [cs:slength]
sl3:		mov di, [si]					;clear previous snake
			mov word [es:di], 0x0720
			add si, 2
			loop sl3
			push cs
			pop ds
			mov si, snake
			mov cx, [cs:slength]
			dec cx
			mov bx, cx
			shl bx, 1
ml3:		mov ax, [si+bx-2]				;update co-ordinates of snake in memory
			mov word [si+bx], ax
			sub bx, 2
			loop ml3
			sub word [cs:snake], 160		;move head up
			mov al, '@'
			mov ah, 0x02
			mov di, [si]
			mov word [es:di], ax
			mov cx, [cs:slength]
			dec cx
			add si, 2
			mov al, '*'
pl3:		mov di, [si]
			mov word [es:di], ax
			add si, 2
			loop pl3
cont9:		cmp word [cs:heart], 0
			je cont10
			mov ax, [cs:snake]
			cmp ax, 3350
			jne cont10
			inc word [cs:lives]
			push 252
			push word [cs:lives]
			call printnum
			mov word [cs:heart], 0
cont10:		cmp word [cs:killer], 0
			je gosnake
			mov ax, [cs:snake]
			cmp ax, 2260
			jne gosnake
			call beep
			dec word [cs:lives]
			push 252
			push word [cs:lives]
			call printnum
			mov word [cs:killer], 0
gosnake:	mov ax, [cs:snake]
			cmp ax, [cs:fruitpos]
			jne outl
			mov bx, [cs:slength]
			add word [cs:slength], 4
			mov word [cs:fruit], 0
			push 212
			push word [cs:slength]
			call printnum
			call beep
			dec bx
			shl bx, 1
			mov dx, bx
			mov ax, [cs:snake+bx]
			sub bx, 2
			mov cx, [cs:snake+bx]
			push cs
			pop ds
			mov si, snake
			mov bx, dx
			mov di, [si+bx]
			sub ax, cx
			mov cx, 4
			cmp ax, 2
			je incr3
			cmp ax, 160
			je incd3
			cmp ax, -2
			je incl3
			cmp ax, -160
			je incu3
incr3:		add di, 2
			mov word [si+bx+2], di
			add si, 2
			loop incr3
			jmp outu
incl3:		sub di, 2
			mov word [si+bx+2], di
			add si, 2
			loop incl3
			jmp outu
incd3:		add di, 160
			mov word [si+bx+2], di
			add si, 2
			loop incd3
			jmp outu
incu3:		sub di, 160
			mov word [si+bx+2], di
			add si, 2
			loop incu3
			jmp outu		
outu:		jmp exit
dsnake:		push cs
			pop ds
			mov si, snake
			mov cx, [cs:slength]
sl4:		mov di, [si]					;clear previous snake
			mov word [es:di], 0x0720
			add si, 2
			loop sl4
			push cs
			pop ds
			mov si, snake
			mov cx, [cs:slength]
			dec cx
			mov bx, cx
			shl bx, 1
ml4:		mov ax, [si+bx-2]				;update co-ordinates of snake in memory
			mov word [si+bx], ax
			sub bx, 2
			loop ml4
			add word [cs:snake], 160		;move head up
			mov al, '@'
			mov ah, 0x02
			mov di, [si]
			mov word [es:di], ax
			mov cx, [cs:slength]
			dec cx
			add si, 2
			mov al, '*'
pl4:		mov di, [si]
			mov word [es:di], ax
			add si, 2
			loop pl4
cont11:		cmp word [cs:heart], 0
			je cont12
			mov ax, [cs:snake]
			cmp ax, 3350
			jne cont12
			inc word [cs:lives]
			push 252
			push word [cs:lives]
			call printnum
			mov word [cs:heart], 0
cont12:		cmp word [cs:killer], 0
			je gosnake1
			mov ax, [cs:snake]
			cmp ax, 2260
			jne gosnake1
			call beep
			dec word [cs:lives]
			push 252
			push word [cs:lives]
			call printnum
			mov word [cs:killer], 0
gosnake1:	mov ax, [cs:snake]
			cmp ax, [cs:fruitpos]
			jne outl
			mov bx, [cs:slength]
			add word [cs:slength], 4
			mov word [cs:fruit], 0
			push 212
			push word [cs:slength]
			call printnum
			call beep
			dec bx
			shl bx, 1
			mov dx, bx
			mov ax, [cs:snake+bx]
			sub bx, 2
			mov cx, [cs:snake+bx]
			push cs
			pop ds
			mov si, snake
			mov bx, dx
			mov di, [si+bx]
			sub ax, cx
			mov cx, 4
			cmp ax, 2
			je incr4
			cmp ax, 160
			je incd4
			cmp ax, -2
			je incl4
			cmp ax, -160
			je incu4
incr4:		add di, 2
			mov word [si+bx+2], di
			add si, 2
			loop incr4
			jmp outd
incl4:		sub di, 2
			mov word [si+bx+2], di
			add si, 2
			loop incl4
			jmp outd
incd4:		add di, 160
			mov word [si+bx+2], di
			add si, 2
			loop incd4
			jmp outd
incu4:		sub di, 160
			mov word [si+bx+2], di
			add si, 2
			loop incu4
			jmp outd		
outd:		jmp exit
exit:		mov al, 0x20
			out 0x20, al
			pop es
			pop di
			pop si
			pop dx
			pop cx
			pop bx
			pop ax
			iret

start:		call clrscr
			push 7
			push ds
			push difficulty
			push 10
			push 20
			call printstr
			push 7
			push ds
			push tip
			push 23
			push 0
			call printstr
menu:		mov ah, 0
			int 0x16
			cmp al, 'y'
			je start1
			cmp al, 'n'
			je menu
			jne menu
start1:		call clrscr
			call tborder
			call watch
			push 4
			push ds
			push life
			push 1
			push 40
			call printstr
			push 4
			push ds
			push mscore
			push 1
			push 20
			call printstr
			push 1
			push ds
			push copyright
			push 0
			push 34
			call printstr
			push 4
			push ds
			push mstage
			push 1
			push 10
			call printstr
			xor ax, ax
			mov es, ax
			cli
			mov word [es:8*4], timer
			mov [es:8*4+2], cs
			mov word [es:9*4], kbisr
			mov [es:9*4+2], cs
			sti
			jmp $

terminate:	mov ax, 0x4c00
			int 0x21

