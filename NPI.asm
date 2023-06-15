EXTERN printAnswer
GLOBAL main
; (9-(5+2))*3 => 952+-3* => 6
; (3+4)*(2-3/4)/((8+2*3)/3+4) => 34+234/-*823*+3/4+/ => 1.01
; 123+321
section .data
    msg db "Ingresa la expresion: "
    msgLen equ $-msg
    ; formato db 'El número flotante es: %.3f', 10
    exprLen db 0
    ; postfixExpr db 25 dup(0)
    postfixLen db 0
    chr db 0
    priori1 db 0
    priori2 db 0
    initialIndex dd 0
    number dd 0
    answer dd  0.0
    numCounter db -1
    mainLoopIndex db 0
    numLoopIndex db 0
    addressHolder dd 0
    recallAddress dd 0
section .bss
    asciiNum resb 10
    expresion resb 100
    buffer_size resb 100
    postfixExpr resb 128
section .text
main:
    ; mov eax, 0x2b
    ; mov ebx, -1
    ; mul ebx
    ; cmp eax, -43;<=- +
    ; jne exit
    mov [initialIndex], esp ;guardamos la posicion en donde se encuentra el stack pointer
;     push eax
;     cmp esp,[initialIndex]
;     je verdadero
;     nop
;     nop
; verdadero:
    jmp getExpr
return2:
    mov esi, expresion ;guardamos la direccion de la cadena en el registro
    mov edi, postfixExpr ;guardamos la direccion de la cadena en el registro
    mov dword[addressHolder], asciiNum
    mov ecx, [exprLen] ;guardamos el num total de caracteres que se ingresaron
    ; mov edx, [exprLen]
    ; mov [postfixLen], cl
ciclo:
    mov al, [esi] ; Cargar el caracter actual en AL
    
    mov [chr],al   ;cargar el caracter en la varaible
    cmp byte[chr],'('
    je parentesisAbre

    ;Verificando si es un operando (número)
    cmp byte[chr],'0' ;la mayoria de los operadores tienen un codigo acii menor al del '0'
    jb parseInt
    ;cmp byte[chr],'9' ;esta comprobacion solo va a funcionar con el caracter '^'
    ;ja parseInt


    ;Es un número
    mov ebx, [addressHolder] ;utilizamos el registro ebx para movernos por el arreglo
    mov [ebx], al ;asignamos el caracter a la posicion actual del arreglo
    inc ebx ;nos movemos a la siguiente casilla del arreglo
    
    mov [addressHolder], ebx 
    inc byte[numCounter]
    ; mov [edi],al ;ingresa el caracter actual en la cadena postfixExpr
    ; inc edi ;avanza a la siguiente posición de postfixExpr

continue:
    inc esi ;incrementar index del string de la expresion
    loop ciclo

    jmp parseInt

while3:
    cmp esp,[initialIndex]
    je solve

    call pop0

    jmp while3  ;si NO es la primera posición de la pila salta a while3

exit:
    mov eax, 1
    mov ebx, 0
    int 0x80
    
parseInt:
    mov [mainLoopIndex], cl ;guardamos en donde se quedo el bucle principal
    mov cl, [numCounter] ;asignamos el numero de vueltas que va a dar el actual bucle
    cmp cl, -1
    je notADigit ;no hay digitos, asi que no hay nada que hacer

    mov dword[addressHolder], asciiNum
parseLoop:
    call getBase
    mov ebx, [addressHolder]
    mov edx, 0 ;limpiamos el registro para poder tabajar con el
    mov dl, [ebx]
    sub dl, '0'
    mul edx
    add [number], eax

    inc ebx
    mov [addressHolder], ebx

    ; loop parseLoop
    dec ecx
    cmp ecx, -1
    jne parseLoop

    ;por ultimo agregamos al arreglo postfixExpr el numero
    mov eax, [number] ;TODO: revisar, puede que no haga falta esta linea
    mov [edi], eax ;asignamos los 4 bytes del numero a postfixExpr
    add edi, 4 ;avanza 4 posiciones en postfixExpr

    inc byte[postfixLen]

    ;*reiniciar parametros para trabajar con el siguiente numero*
    mov dword[addressHolder], asciiNum
    mov dword[number], 0 ;TODO: revisar, puede que no haga falta esta linea
    mov byte[numCounter], -1
    mov ecx, 0

notADigit:
    mov cl, [mainLoopIndex]

    cmp ecx,0
    je while3

    cmp byte[chr],')'
    je parentesisCierra

ckOperator:
    ; operador (+,-,*,/)
    cmp esp,[initialIndex]
    je push0 ;si la pila esta vacia salta a push0
    cmp byte[esp],'('
    je push0 ;si pila[x]=='(' salta a push0
    ;else:
    whileCmp:
        cmp esp, [initialIndex]
        je push0 ;si la pila esta vacia salta 
        ; cmp edi,pila
        cmp byte[esp],'('
        je push0  ;si en la cima de la pila es un '(' entonces salta
        ; ; cmp byte[pila],'('
        ; je finWhile2  ;si es la primera posición de la pila salta a finWhile2
        jmp prioridad1 ;obtiene la prioridad de caracter
        ; call prioridad2
    retorno:
        mov ebx, 0
        mov bl, [priori2]
        cmp byte[priori1],bl
        ja push0       ; si priori1>priori2 salta a push0
         ;sino -> priori1<=priori2
    while2:
        call pop0
        jmp whileCmp

push0:
    mov eax, 0 ;limpiamos el registro
    mov al, [chr] ;obtenemos el caracter;
    push eax ;guarda el caracter en "pila"
    jmp continue

; cuando hacemos un call se hace un push al stack pointer con la direccion de donde se llamo
pop0:
    pop dword[recallAddress] ;guardamos la direccion en donde va a regresar call
    pop eax ;guardamos lo que esta en pila en el registro
    mov ebx, -1 
    mul ebx ;multiplicamos el oerador por -1 para convertirlo en negativo 
    mov [edi], eax ;guarda el oerador en el arreglo: postfixExpr
    add edi, 4; ;nos movemos 4 bytes en el arreglo
    
    inc byte[postfixLen]

    push dword[recallAddress] ;regresamos a pila la direccion para que regrese a la linea de codigo donde se llamo
    ret

parentesisAbre:
    ; dec byte[postfixLen]
    ; dec edx;
    jmp push0
    
parentesisCierra:
    ; dec byte[postfixLen]
    ; dec edx;
while0:
    call pop0
    cmp byte[esp],'('
    jne while0

    pop eax

    jmp continue

;guardando la prioridad
prioridad1:
    ;obteniendo la prioridad del caracter
    cmp byte[chr],'*'
    je ret2a
    cmp byte[chr],'/'
    je ret2a
    cmp byte[chr],'+'
    je ret1a
    cmp byte[chr],'-'
    je ret1a
ret2a:
    mov byte[priori1], 2
    jmp prioridad2
ret1a:
    mov byte[priori1], 1
    ; ret

prioridad2:
    ; mov ebx, [esp]
    ;obteniendo la prioridad de pila[x]
    cmp byte[esp],'*'
    je ret2b
    cmp byte[esp],'/'
    je ret2b
    cmp byte[esp],'+'
    je ret1b
    cmp byte[esp],'-'
    je ret1b
ret2b:
    mov byte[priori2], 2
    jmp retorno
ret1b:
    mov byte[priori2], 1
    jmp retorno

getExpr:
    mov eax, 4
    mov ebx, 1 
    mov ecx, msg 
    mov edx, msgLen
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, expresion
    mov edx, buffer_size
    int 0x80

    ;obtengo el ultimo caracter
    dec eax
    add ecx, eax
    ; mov bl, [ecx]
    ; mov [chr], bl
    mov byte[ecx], 0 ;cambiamos el salto de linea (\n) por fin de linea (\0)
    ; mov [chr], bl
    mov [exprLen], eax ;obtenemos el tamanio de la expresion (sin el ultimo caracter)
    jmp return2

showExpr:
    mov eax, 4          
    mov ebx, 1          
    mov ecx, postfixExpr    
    mov dl, [postfixLen]
    int 0x80

; (9-(5+2))*3 => 952+-3*
    ;420+70/100 => 
    mov ecx, 0
    mov cl, [postfixLen]
    mov ebx, postfixExpr
prueba:
    mov eax, [ebx]
    add ebx, 4
    loop prueba

    ; mov ebx, postfixExpr
    ; mov eax, [ebx] ; => 9
    ; add ebx, 4
    ; mov eax, [ebx] ; => 5
    ; add ebx, 4
    ; mov eax, [ebx] ; => 2
    ; add ebx, 4
    ; mov eax, [ebx] ; => +
    ; add ebx, 4
    ; mov eax, [ebx] ; => -
    ; add ebx, 4
    ; mov eax, [ebx] ; => 3
    ; add ebx, 4
    ; mov eax, [ebx] ; => *

    ; mov eax, [ebx] ; => 420
    ; add ebx, 4
    ; mov eax, [ebx] ; => 70
    ; add ebx, 4
    ; mov eax, [ebx] ; => 100
    ; add ebx, 4
    ; mov al, byte[ebx] ; => /
    ; add ebx, 1
    ; mov al, byte[ebx] ; => +

    ; jmp exit

solve:
    mov ecx, 0
    mov cl, [postfixLen]
    ; postfixExpr contiene la expresión en postfijo
    mov esi, postfixExpr ;guardamos la direccion de la cadena en el registro
    mov dword[number], 0

    finit
loopSolv:
    mov eax, [esi] ; Cargar el numero actual en eax
    mov [number], eax  ;cargar el numero en la varaible

    ;verificar si no es un operador
    cmp eax, -43;<=- '+'
    je suma
    cmp eax, -45;<=- '-'
    je resta
    cmp eax, -42;<=- '*'
    je multiplicacion
    cmp eax, -47;<=- '/'
    je division

    fild dword[number] ;en caso de ser un operando lo ingresamos a la pila de flotantes
backLoopSolv:
    add esi, 4 ;recorremos 4 bytes
    loop loopSolv 
    jmp getResult ;si todos los operandos y operadores fueron procesados procedemos a imprimir el resultado

suma:
    ; hacer la suma en la fpu
    faddp
    ; el resultado de la suma se dejara en la pila
    jmp backLoopSolv
resta:
    ; hacer la resta en la fpu
    fsubp
    ; el resultado de la resta se dejara en la pila
    jmp backLoopSolv
multiplicacion:
    ; hacer la multiplicación en la fpu
    fmulp
    ; el resultado de la multiplicación se dejara en la pila
    jmp backLoopSolv
division:
    ; hacer la división en la fpu
    fdivp
    ; el resultado de la división se dejara en la pila
    jmp backLoopSolv
getResult:
    fstp dword[answer] ;extraemos el resultado de la pila
    push dword[answer]
    push dword expresion
    call printAnswer
    add esp, 8
    ; sub esp, 8;ajuste para imprimir
    ; fstp qword [esp];poner a imprimir resultado
    ; push formato ;formato de impreción
    ; call printf
    jmp exit

getBase:
    mov [numLoopIndex], cl ;guardamos en donde se quedo el bucle del parse
    ; mov ecx, [numCounter] ;asignamos el numero de vueltas que va a dar el actual bucle
    mov ebx, 1
    cmp ecx, 0 ;comprobamos si el esponente es un cero 
    jne calcPow ;si no lo es continuamos con el procedimiento 
    mov eax, 1 ; en caso de que el exponente sea un 0 agregamos un 1 en el registro que utilizamos para el resultado
    ret
calcPow:
    mov eax, 10
    mul ebx
    mov ebx, eax
    loop calcPow
    mov cl, [numLoopIndex] ;reingresamos el numero que utiliza el bucle al registro
    ret