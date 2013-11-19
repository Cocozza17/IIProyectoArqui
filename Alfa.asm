; Primero el programa recibe una entrada
; Si examina la primera palabra de la entrada (la linea de comandos)
; Se verifica que sea un comando valido
; Dependiendo si se ocupa, se almacena el nombre o los dos nombres necesarios por comando
; Se realiza la acción
; Se despliega el mensaje de exito 
; Se limpian los buffers 
; Vuelvea iniciar el programa

section .data

	ME db 10,'Igualar A', 10
	MEL equ $-ME

	MB db 10,'Igualar B', 10
	MBL equ $-MB

	punto db '.'
	puntolen equ $-punto

	leer1 db 10,"estamos en leer1"
	llen equ $-leer1


	leer2 db 10,"estamos en leer2"
	llen2 equ $-leer2

	cab db 10,"cdi»"
	clen equ $-cab

	msg1 db 10,"FD1: "
	m1len equ $-msg1

	msg2 db 10,"FD2: "
	m2len equ $-msg2


	msge2 db 10,"¡Éxito!"
	msge2len equ $-msge2

	nl db 10,"  ",10
	nlen equ $-nl

	coma db ", "
	colen equ $-coma

	dosp db ": "
	dosplen equ $-dosp

	Arch1 db "Archivo1: "
	arc1len equ $-Arch1

	Arch2 db "Archivo2: "
	arc2len equ $-Arch2

	PS db 10,"¿Está seguro sobre su decisión (S/N)? "
	PSlen equ $-PS

	me1 db 10,"¡Comando no encontrado!", 10
	me1len equ $-me1

	me2 db 10,"Error: ¡Posiblemente el archivo no exista o escribió mal el nombre!", 10
	me2len equ $-me2

	AB db 'Borrar.ayuda',0
	AC db 'Copiar.ayuda',0
	AK db 'Comparar.ayuda',0
	AM db 'Mostrar.ayuda',0
	AR db 'Renombrar.ayuda',0




section .bss
	
	l_comando resb lineaC
	cantidad resb buflen2
	origen resb buflen
	destino resb buflen
	fd1 resb buflen
	fd2 resb buflen
	buffer resb buflen
	buffer2 resb buflen
	buffer3 resb buflen
	buffer4 resb buflen

	SubC1 resb buflen
	SubC2 resb buflen

	buflen equ 25
	lineaC equ 40
	
	Aflag resb buflen2
	linea resb buflen2
	contador resb buflen2
	auxiliar resb buflen3
	contador2 resb buflen2
	caracter resb buflen2



	
	ayChar resb buflen3
	char1 resb buflen2
	char2 resb buflen2
	char3 resb buflen3

	auxi resb buflen3
	auxi2 resb buflen3

	buflen2 equ 1
	buflen3 equ 2

	lector resb Dmega
	Dmega equ 1024

	

section .text


global _start
_start:

;Imprimimos la consola (?)

	
	mov byte[Aflag], 0	;Se le mueve a la porcion de memoria un 0 (Funciona como bandera de estado)
	xor edi, edi		;Limpio el edi para un uso futuro.
	call cons		;Cons: Imprime la consola.

;Primero recibimos la entrada del usuario

;Llamo a sys_read y recibo la entrada del usuario (la entrada de comandos)
	mov eax, 3
	mov ebx, 0
	mov ecx, l_comando
	mov edx, buflen
	int 80h
	dec eax
	push eax ;Coloco en lapila la cantidad de caracteres menos 1. (para las posiciones en el string)



;Analizamos la accion a realizar 
;Procedimiento que se encarga de verificar el comando del usuario y si esta bien escrito

	jmp Clasificar

;------------------------------------------------------------------------------------------------

Borrar:

;Función Borrar:
;Recibe el nombre de un archivo a borrar.
;Si no es frozado, se le pregunta al usuario si está seguro sobre su decisión.

	cmp byte[Aflag], 1 ;Si la bandera de ayuda no esta encendida saltamos a la etiqueta .saltar
	jne .almacenar
			   ;Si está encendida entonces muevo a la porción de memoria ayChar la letra B
			   ;La letra señala cual mensaje de ayuda mostrar en pantalla
	mov byte[ayChar], 'B'
	jmp Ayuda	   ;Salto a la etiqueta Ayuda.

	.almacenar:

		pop eax	   ;Saco de la pila la cantidad de caracteres leidos en la entrada.
		xor ecx, ecx ;Limpio el ecx 
		mov ecx, 7   ;Muevo el numero 7 para apuntar a un caracter en especifico en el string
		;El caracter 7 debería ser la inicial del nombre del archivo a borrar.
		xor ebx, ebx
		xor edx, edx
		;Limpio los registros para su uso mas adelante.

	
	.guardar:

	
		;Muevo al bl el caracter que está en el string de entrada+ecx.
		mov bl, byte[l_comando+ecx]
		cmp bl, ' '
		je .EncenderBandera ;Si es igual a ' ' salto a .EncenderBandera
		cmp ecx, eax ; Si no, comparo la cantidad de caracteres leidos con la cantidad que lleva ecx.
		je .ForceFlag
		;Si son iguales salto a la etiqueta de pregunta.

		mov byte[origen+edx], bl ;Si no, guardo el caracter en la posicion de memoria origen+edx
		inc edx
		inc ecx
		;Incremento los registros para apuntar una posicion mas adelante.
		jmp .guardar

	.EncenderBandera:
		;Se fija si se quiere que el comando sea forzado (No enciende ninguna bandera)
		;Nada mas se fija si después del nombre del archivo a borrar hay algo más
		;y Si lo hay, se fija que sea un '-' para indicar el comando forzado.
		;Si no es igual a '-' entonces el comando da error.

		inc ecx
		mov bl, byte[l_comando+ecx]
		cmp bl, '-'
		je .borrar
		jmp Error
		
		
	
	.ForceFlag:	

		;Se encarga de preguntarle al usuario si esta seguro de la acción a realizar
		;Se recibe una entrada y se comprueba que sea la correcta
		;Si es la correcta se procede a borrar
		;Si no, entonces vuelve a inciar el programa limpiando los buffer.

		mov eax, 4
		mov ebx, 1
		mov ecx, PS
		mov edx, PSlen
		int 80h
	
		mov eax, 3
		mov ebx, 0
		mov ecx, char3
		mov edx, buflen3
		int 80h

		cmp byte[char3], 'S'
		je .borrar
		jmp Limpiar

	.borrar:

		;Se llama a la función sys_unlink
		mov eax, 10 ;Sys_unlink
		mov ebx, origen;Nombre del archivo a borrar 	
		int 80h		;Llamada al vector de interrupciones
		call msgExito
		jmp Limpiar	;Salto a la etiqueta Limpiar.

;---------------------------------------------------------------------------------------------------

Renombrar:

;Utiliza el mismo algoritmo para almacenar los parametros
;Parametros: Nombre original - Nombre Nuevo.
;Utiliza la tecnica de forzado.
;Una vez teniendo los nombres, se llama al vector de interrupciones y se realiza el cambio.



;Utiliza la misma tecnica de la ayuda.

	cmp byte[Aflag], 1
	jne .almacenar
	mov byte[ayChar], 'R'
	jmp Ayuda
	

;El algoritmo para almacenar los parametros son parecidos
;pero este guarda dos parametros
;Se le mueve al ecx 10, porque deberia ser donde se encuentre
;la primera letra del parametro.
;Una vez encontrada la primera letra se empiezan a almacenar hasta llegar a un ' '
;El ' ', señala que sigue el segundo parametro para almacenar
;Al final se compara el byte al que apunta el ecx con la cantidad de caracteres leidos
;para determinar si se terminan de almacenar caracteres.
;Si hay un espacio, es posible que se quiera el comando forzado.

;Ni el primer nombre ni el segundo pueden llevar espacios.

	.almacenar:

		pop eax      ;Se saca de la pila la cantidad de caracteres leidos y se guarda en el ecx.
		xor ecx, ecx
		mov ecx, 10
		xor ebx, ebx
		xor edx, edx

	
	.guardar:

		;El edx es el puntero en la porcion de memoria "origen"
		mov bl, byte[l_comando+ecx] ; muevo al bl lo que esta en l_comando+ecx
		cmp bl, ' '; lo comparo con un espacio ' '
		je .aux2   ;Si es igual salto a aux2
		mov byte[origen+edx], bl  ;Si no muevo a la posicion origen+edx lo que está en el bl
		inc edx
		inc ecx

		;Incremento los punteros para apuntar un byte mas adelante.
		
		jmp .guardar ;Iniciio el ciclo.
	.aux2:

		;Se encarga de inicializar el edx que funciona de nuevo como puntero y
		;Incremento el ecx para apuntar al primer caracter del segundo parametro.
		xor edx, edx 
		inc ecx

	.guardar2:

		;Casi igual que .guardar, pero la condición para que termine el ciclo es si 
		;el byte al que apunta el ecx es igual a la cantidad de caracteres leidos que tiene el eax
		;o si se encuentra un espacio (pero eso es porque sería forzado)

		mov bl, byte[l_comando+ecx]
		cmp bl, ' '
		je .EncenderBandera2

		cmp ecx, eax
		je .ForceFlag2

		mov byte[destino+edx], bl 

		inc edx
		inc ecx
		jmp .guardar2

	.EncenderBandera2:

		inc ecx
		mov bl, byte[l_comando+ecx]
		cmp bl, '-'
		je .renombrar
		jmp Error
		
		
	.ForceFlag2:	

		mov eax, 4
		mov ebx, 1
		mov ecx, PS
		mov edx, PSlen
		int 80h
	
		mov eax, 3
		mov ebx, 0
		mov ecx, char3
		mov edx, buflen3
		int 80h

		cmp byte[char3], 'S'
		je .renombrar
		jmp Limpiar

	.renombrar:
		; Muevo al eax,38 que es el numero de la interrupción
		; Al ebx y ecx se mueve el nombre original y el nuevo correspondientemente
		; Se llama al vector de interrupciones
		; Limpio los buffers
		mov eax, 38
		mov ebx, origen		
		mov ecx, destino
		int 80h
		call msgExito
		jmp Limpiar


;-----------------------------------------------------------------------------------------------------
Comparar:

;Compara caracter por caracter, para ver si hay alguna diferencia 
;Si la hay imprime la linea en la cual se encuentra la diferencia.
;Al comparar caracter por caracter es más facil verificar si hay salto de linea para contar las lineas.
 
;La misma tecnica de ayuda 
;Es la misma tecnica de almacenar.
;Esta vez abro los dos archivos.
;Guardo sus file descriptor (en fd1 y fd2)
;Leo un byte de cada uno
;Verifico que no sea eof en cada archivo (si sucede, saltamos a Limpiar para iniciar el programa de nuev)
;Si no, verifico si alguno de los dos es un salto de linea, (si lo es aumento el contador respectivo)
;y continuo a comparar los caracteres.
;Si no,  comparo los caracteres(si son diferentes, imprimo el numero de linea donde se da.
;Si son iguales,  vuelvo a leer del archivo para iniciar el ciclo.

	cmp byte[Aflag], 1
	jne .almacenar
	mov byte[ayChar], 'K'
	jmp Ayuda
	
	.almacenar:

		pop eax
		xor ecx, ecx
		mov ecx, 9
		xor ebx, ebx
		xor edx, edx

	
	.guardar:

		
		mov bl, byte[l_comando+ecx]
		cmp bl, ' '
		je .aux
		mov byte[origen+edx], bl 
		inc edx
		inc ecx
		jmp .guardar
	.aux:
		xor edx, edx 
		inc ecx

	.guardar2:

		mov bl, byte[l_comando+ecx]
		cmp ecx, eax
		je .abrir
		mov byte[destino+edx], bl 
		inc edx
		inc ecx
		jmp .guardar2

	

	
	.abrir:

	mov eax, 5
	mov ebx, origen
	xor ecx, ecx
	xor edx, edx
	int 80h

	mov [fd1], eax ;Se mueve a la variable fd1 el file descriptor del archivo original.
	xor eax, eax

	mov eax, 5
	mov ebx, destino
	xor ecx, ecx
	xor edx, edx
	int 80h

	mov [fd2], eax ;Se mueve a la variable fd1 el file descriptor del archivo original.
	xor eax, eax

	xor esi, esi 		;Se limpia el esi 
	mov esi, 1		;Se le mueve un 1(Se va a usar como contador de lineas mas adelante)
	xor ebp, ebp
	mov ebp, 1
	xor ebx, ebx
	xor ecx, ecx
	mov byte[SubC1], 1   ;Es el contador de lineas del primer archivo en comparar.
	mov byte[SubC2], 1	;Es el contador de lineas del segundo archivo en comparar.
	call LimpiarP

	.Preguntar:
		cmp esi, ebp
		je .leer
		cmp esi, ebp
		jb .leermas
		cmp esi, ebp
		jg .leermas2
		jmp Error
	.leer:

		mov eax, 3
		mov ebx, [fd1]
		mov ecx, char1
		mov edx, buflen2
		int 80h


		test eax, eax
		jz Limpiar

	.Linea:

		cmp byte[char1], 0xA
		jne .incrementarS1
		inc esi
		mov byte[SubC1], 1
	.tsuju:

	.leer2:
	
		mov eax, 3
		mov ebx, [fd2]
		mov ecx, char2
		mov edx, buflen2
		int 80h
	

		test eax, eax
		jz Limpiar

	.Linea2:

		cmp byte[char2], 0xA
		jne .incrementarS2

		inc ebp
		mov byte[SubC2], 1
		
	.tsuju2:
	

	.comparar:

		mov al, byte[char1]
		cmp al, byte[char2]
		je .leer

	.noI:
		mov ecx, origen
		mov edx, buflen
		call Print
	
		mov ecx, dosp
		mov edx, dosplen
		call Print
		
		mov eax, esi
		mov edi, buffer
		call Itoa

		mov edx, eax
		mov ecx, buffer
		call Print


		mov edx, puntolen
		mov ecx, punto
		call Print
		

		mov eax, [SubC1]
		mov edi, buffer
		call Itoa
		
		mov edx, eax
		mov ecx, buffer
		call Print
	
		mov ecx, coma
		mov edx, colen
		call Print
	
		mov ecx, destino
		mov edx, buflen
		call Print
		
		mov ecx, dosp
		mov edx, dosplen
		call Print
		

		mov eax, ebp
		mov edi, buffer
		call Itoa
	
		mov edx, eax
		mov ecx, buffer
		call Print
	
		mov edx, puntolen
		mov ecx, punto
		call Print


		mov eax, [SubC2]
		mov edi, buffer
		call Itoa
	
		mov edx, eax
		mov ecx, buffer
		call Print
		
		mov edx, nlen
		mov ecx, nl
		call Print


		jmp .Preguntar

		
	
	.leermas:

		cmp esi, ebp
		je .Preguntar
		
		mov eax, 3
		mov ebx, [fd1]
		mov ecx, char1
		mov edx, buflen2
		int 80h
	
		test eax, eax
		jz Limpiar

	.Lineamas:

		cmp byte[char1], 0xA
		jne .Aimprimirmas
		inc esi
		mov byte[SubC1], 1
		jmp .leermas

	.Aimprimirmas:

		inc byte[SubC1]

	.imprimirmas:
		mov ecx, origen
		mov edx, buflen
		call Print
	
		mov ecx, dosp
		mov edx, dosplen
		call Print
		
		mov eax, esi
		mov edi, buffer
		call Itoa

		mov edx, eax
		mov ecx, buffer
		call Print


		mov edx, puntolen
		mov ecx, punto
		call Print
		

		mov eax, [SubC1]
		mov edi, buffer
		call Itoa
		
		mov edx, eax
		mov ecx, buffer
		call Print
	
		mov ecx, coma
		mov edx, colen
		call Print
	
		mov ecx, destino
		mov edx, buflen
		call Print
		
		mov ecx, dosp
		mov edx, dosplen
		call Print
		

		mov eax, ebp
		mov edi, buffer
		call Itoa
	
		mov edx, eax
		mov ecx, buffer
		call Print
	
		mov edx, puntolen
		mov ecx, punto
		call Print


		mov eax, [SubC2]
		mov edi, buffer
		call Itoa
	
		mov edx, eax
		mov ecx, buffer
		call Print
		
		mov edx, nlen
		mov ecx, nl
		call Print

		jmp .leermas


	.leermas2:

		cmp esi, ebp
		je .Preguntar

		mov eax, 3
		mov ebx, [fd2]
		mov ecx, char2
		mov edx, buflen2
		int 80h

		
	
		test eax, eax
		jz Limpiar

	.Lineamas2:

		cmp byte[char2], 0xA
		jne .Aimprimirmas2
		inc ebp
		mov byte[SubC2], 1
		jmp .leermas2

	.Aimprimirmas2:

		inc byte[SubC2]

	.imprimirmas2:
		mov ecx, origen
		mov edx, buflen
		call Print

		mov ecx, dosp
		mov edx, dosplen
		call Print

		mov eax, esi
		mov edi, buffer
		call Itoa

		mov edx, eax
		mov ecx, buffer
		call Print

		mov edx, puntolen
		mov ecx, punto
		call Print
	

		mov eax, [SubC1]
		mov edi, buffer
		call Itoa
		
		mov edx, eax
		mov ecx, buffer
		call Print

		mov ecx, coma
		mov edx, colen
		call Print

		push ecx
		mov ecx, destino
		mov edx, buflen
		call Print
		pop ecx

		push ecx
		mov ecx, dosp
		mov edx, dosplen
		call Print
		pop ecx

		mov eax, ebp
		mov edi, buffer2
		call Itoa
	
		mov edx, eax
		mov ecx, buffer2
		call Print
	
		mov edx, puntolen
		mov ecx, punto
		call Print

		

		mov eax, [SubC2]
		mov edi, buffer
		call Itoa

		
		mov edx, eax
		mov ecx, buffer
		call Print

		mov edx, nlen
		mov ecx, nl
		call Print
		jmp .leermas2

.incrementarS1:

	inc byte[SubC1]
	jmp .tsuju

.incrementarS2:

	inc byte[SubC2]
	jmp .tsuju2
	
;---------------------------------------------------------------------------------------------------
Copiar:


;Utiliza el mismo algoritmo de ayuda
;Utiliza el mismo algoritmo de almacenar que "Comparar"
;Como se tiene que leer de un archivo, se tiene que abrir primero.
;Se mueve al eax, 5(el numero de la interrupcion), al ebx el nombre del archivo
;al ecx, la manera en que se quiere abrir(0 leer, 2 leer escribir)
;al edx, si se desea que si el archivo no existe se cree.
;una vez que se llama al vector de interrupciones, el eax tendrá el fd del archivo.
;Después de abrir los dos, se tiene que leer de uno y escribir en el otro, hay que repetirlo hasta
;llegar al end of file del archivo fuente.

	cmp byte[Aflag], 1
	jne .almacenar
	mov byte[ayChar], 'C'
	jmp Ayuda
	
	.almacenar:

		
		xor ecx, ecx
		mov ecx, 7
		xor ebx, ebx
		xor edx, edx

	
	.guardar:

		
		mov bl, byte[l_comando+ecx]
		cmp bl, ' '
		je .aux
		mov byte[origen+edx], bl 
		inc edx
		inc ecx
		jmp .guardar
	.aux:
		xor edx, edx 
		pop eax
		inc ecx

	.guardar2:

		mov bl, byte[l_comando+ecx]
		cmp ecx, eax
		je .abrir
		mov byte[destino+edx], bl 
		inc edx
		inc ecx
		jmp .guardar2



.abrir:

;Se abre el archivo
	mov eax, 5
	mov ebx, origen
	xor ecx, ecx
	xor edx, edx
	int 80h

;Guardo lo que está en el eax, a una porción de memoria llamada fd1 

	mov [fd1], eax
;Reviso si hay errores
	test eax, eax
	jns .abrir2
	jmp ErrorArchivo



.abrir2:
;Abro el segundo archivo
	mov eax, 5
	mov ebx, destino
	mov ecx, 0102o
	mov edx, 0666o
	int 80h
;Guardo su fd en una porcion de memoria.

	mov [fd2], eax

.leer:
;Leo del archivo fuente
;Para leer es igual que recibir la entrada del usuario
;pero en vez de leer del teclado lee del file descriptor del archivo fuente.

	mov ebx, [fd1]
	mov eax, 3
	mov ecx, lector
	mov edx, Dmega 
	int 80h

;Reviso si ese el end of file

	test eax, eax
	jz .auxLimpiar

;Si lo es, salto a Limpiar.

.escribir:

;Para escribir, muevo al ebx la porción de memoria que tiene el file descriptor del  archivo destino
;Muevo al eax, 4 (sys_write), muevo al ecx lo que apunta lector, y al edx el tamaño.
;Llamo al vector de interrupciones
;Vuelvo a iniciar el ciclo

	mov ebx, [fd2]
	mov eax, 4	
	mov ecx, lector 
	mov edx, Dmega
	int 80h	

	jmp .leer
	
.auxLimpiar:

	call msgExito
	jmp Limpiar
;---------------------------------------------------------------------------------------------
Mostrar:

;Utiliza el mismo algoritmo de ayudar que las funciones anteriores.
;El algoritmo de almacenar solo guarda un nombre.
;1.Una vez con el nombre abro el archivo
;2.Leo del archivo
;3.Verifico si es eof: Si lo es procedo a limpiar los buffer y empezar de nuevo el programa.
;4.Si no, escribo en pantalla lo que se leyo del archivo.
;5.Vuelvo a 2.


	cmp byte[Aflag], 1
	jne .almacenar
	mov byte[ayChar], 'M'
	jmp Ayuda

	.almacenar:

		pop eax
		xor ecx, ecx
		mov ecx, 8
		xor ebx, ebx
		xor edx, edx

	
	.guardar:

		
		mov bl, byte[l_comando+ecx]
		cmp ecx, eax
		je .abrir
		mov byte[origen+edx], bl 
		inc edx
		inc ecx
		jmp .guardar
	

	.abrir:

		mov eax, 5
		mov ebx, origen
		mov ecx, 0
		mov edx, 0
		int 80h
	
		test eax, eax
		mov ebx, eax
		jns .file_read
		jmp ErrorArchivo


	.file_read:
			
		mov eax, 3
		mov ecx, lector
		mov edx, Dmega 
		int 80h

		push eax
		push ebx
		mov edx, Dmega
		mov ecx, lector
		call Print
		pop ebx
		pop eax

		test eax, eax
		jnz .file_read
		jmp Limpiar

;-----------------------------------------------------------------------------------------------------
	
salir:

	mov eax, 1
	mov ebx, 0
	int 80h

cons:

	;Procedimiento, imprime en pantalla "cdi»» "
	mov eax, 4
	mov ebx, 1
	mov ecx, cab
	mov edx, clen
	int 80h
	ret


Ayuda:

;Se encarga de mostrar el mensaje respectivo de ayuda.
;Con la letra que se pasa en la función
; se identifica cual es el mensaje.
;Se abre el archivo, se guarda el fd y se pasa a la etiqueta file_read el cual hace el ciclo de leido y mostrado en pantalla.

	cmp byte[ayChar], 'B'
	je .ABorrar

	cmp byte[ayChar], 'C'
	je .ACopiar

	cmp byte[ayChar], 'K'
	je .AComp

	cmp byte[ayChar], 'M'
	je .AMostrar

	cmp byte[ayChar], 'R'
	je .ARenomb
	jmp salir

	.ABorrar:

		mov eax, 5
		mov ebx, AB
		mov ecx, 0
		mov edx, 0
		int 80h
	
		test eax, eax
		mov ebx, eax
		jns .file_read
		jmp ErrorArchivo

	.ACopiar:

		mov eax, 5
		mov ebx, AC
		mov ecx, 0
		mov edx, 0
		int 80h
	
		test eax, eax
		mov ebx, eax
		jns .file_read
		jmp ErrorArchivo

	.AComp:

		mov eax, 5
		mov ebx, AK
		mov ecx, 0
		mov edx, 0
		int 80h
	
		test eax, eax
		mov ebx, eax
		jns .file_read
		jmp ErrorArchivo

	.AMostrar:

		mov eax, 5
		mov ebx, AM
		mov ecx, 0
		mov edx, 0
		int 80h
	
		test eax, eax
		mov ebx, eax
		jns .file_read
		jmp ErrorArchivo

	.ARenomb:

		mov eax, 5
		mov ebx, AR
		mov ecx, 0
		mov edx, 0
		int 80h
	
		test eax, eax
		mov ebx, eax
		jns .file_read
		jmp ErrorArchivo

	.file_read:
			
		mov eax, 3
		mov ecx, lector
		mov edx, Dmega 
		int 80h

		push eax
		push ebx
		mov edx, Dmega
		mov ecx, lector
		call Print	
		pop ebx
		pop eax

		test eax, eax
		jnz .file_read
		jmp Limpiar


		
Itoa:
;El Itoa se encarga de pasar de int a string
;El algoritmo: 
;1. Antes de llamar al procedimiento, le muevo al eax el número a convertir y al edi la porción de
;memoria donde almacenaremos el string 
;2.Limpio el ecx y muevo al ebx, 10 (la función div divide el eax entre el ebx y el resultado termina en 
;el edx) le paso un 10 porque ocupo el último digito del número para sumarle '0' y convertirlo en string
;3. Aplico la división, le sumo al edx '0' para convertirlo en string y lo coloco en la pila.
;4. Me fijo si el eax, tiene un 0, si lo es termino el ciclo, si no lo vuelvo a empezar
;5. Hago loop para sacar cada valor colocado en la pila y moverlo al buffer. 
	xor edx, edx
	xor ecx, ecx
	mov ebx, 10


pushloop:

	xor edx, edx
	div ebx
	add edx, '0'
	push edx
	inc ecx
	test eax, eax
	jnz pushloop
	mov eax, ecx

poploop:
	pop edx
	mov [edi], dl
	inc edi
	loop poploop
	ret

Limpiar:

;Son un par de ciclos que se encargan de limpiar los buffers de las entradas
;del usuario.
;Tengo los tamaños de cada buffer así que nada maslo muevo al ecx y hago loop
;a cada posición del buffer le paso un 0.	

	mov ecx, 39
	.loop:
	mov byte[l_comando+ecx], ' '
	loop .loop
	mov ecx, 24
	.loop2:
	mov byte[origen+ecx], 0
	mov byte[destino+ecx], 0
	mov byte[buffer+ecx], 0
	loop .loop2
	jmp _start


Clasificar:

;Se encarga de verificar que el comando que se ingreso esté correctamente escrito
;La primera letra de comando siempre tiene que ser mayúscula!
;Luego, dependiendo de la primera letra del comando se salta a una etiqueta que tiene las comparaciones
;de los caracteres de cada palabra.
;Tambien se fija si se ocupa la ayuda.
;Si la ocupa enciende la bandera de ayuda (Aflag) para cuando vaya al comando correspondiente.

	cmp byte[l_comando], 'B'
	je .Borrar
	cmp byte[l_comando], 'C'
	je .CoC
	cmp byte[l_comando], 'M'
	je .Mostrar
	cmp byte[l_comando], 'R'
	je .Renombrar
	cmp byte[l_comando], 'S'
	je .Salir
	jmp Error
	.Borrar:
		cmp byte[l_comando+1], 'o'
	 	jne Error
		cmp byte[l_comando+2], 'r'
	 	jne Error
		cmp byte[l_comando+3], 'r'
	 	jne Error
		cmp byte[l_comando+4], 'a'
	 	jne Error
		cmp byte[l_comando+5], 'r'
	 	jne Error
		cmp byte[l_comando+7], '-'
		jne Borrar
		mov byte[Aflag], 1
		jmp Borrar
	.CoC:
		cmp byte[l_comando+2], 'p'
		je .Copiar
		cmp byte[l_comando+3], 'p'
	 	jne Error
		cmp byte[l_comando+4], 'a'
	 	jne Error
		cmp byte[l_comando+5], 'r'
	 	jne Error
		cmp byte[l_comando+6], 'a'
	 	jne Error
		cmp byte[l_comando+7], 'r'
	 	jne Error
		cmp byte[l_comando+9], '-'
		jne Comparar
		mov byte[Aflag], 1
		jmp Comparar

	.Copiar:
		
		cmp byte[l_comando+3], 'i'
	 	jne Error
		cmp byte[l_comando+4], 'a'
	 	jne Error
		cmp byte[l_comando+5], 'r'
	 	jne Error
		cmp byte[l_comando+7], '-'
		jne Copiar
		mov byte[Aflag], 1
		jmp Copiar

	.Mostrar:
		cmp byte[l_comando+1], 'o'
	 	jne Error
		cmp byte[l_comando+2], 's'
	 	jne Error
		cmp byte[l_comando+3], 't'
	 	jne Error
		cmp byte[l_comando+4], 'r'
	 	jne Error
		cmp byte[l_comando+5], 'a'
	 	jne Error
		cmp byte[l_comando+6], 'r'
		jne Error
		cmp byte[l_comando+8], '-'
		jne Mostrar
		mov byte[Aflag], 1
		jmp Mostrar
	.Renombrar:
		cmp byte[l_comando+1], 'e'
	 	jne Error
		cmp byte[l_comando+2], 'n'
	 	jne Error
		cmp byte[l_comando+3], 'o'
	 	jne Error
		cmp byte[l_comando+4], 'm'
	 	jne Error
		cmp byte[l_comando+5], 'b'
	 	jne Error
		cmp byte[l_comando+6], 'r'
	 	jne Error
		cmp byte[l_comando+7], 'a'
	 	jne Error
		cmp byte[l_comando+8], 'r'
	 	jne Error
		cmp byte[l_comando+10], '-'
		jne Renombrar
		mov byte[Aflag], 1
		jmp Renombrar
	.Salir:

		cmp byte[l_comando+1], 'a'
	 	jne Error
		cmp byte[l_comando+2], 'l'
	 	jne Error
		cmp byte[l_comando+3], 'i'
	 	jne Error
		cmp byte[l_comando+4], 'r'
	 	jne Error
		cmp byte[l_comando+6], '-'
		jne salir
		mov byte[Aflag], 1
		jmp salir
	
Error:

	mov eax, 4
	mov ebx, 1
	mov ecx, me1
	mov edx, me1len
	int 80h
	jmp Limpiar
		
ErrorArchivo:

	mov eax, 4
	mov ebx, 1
	mov ecx, me2
	mov edx, me2len
	int 80h 
	jmp Limpiar

msgExito:

	mov eax, 4
	mov ebx, 1
	mov ecx, msge2
	mov edx, msge2len
	int 80h 
	ret
LimpiarP:

;Son un par de ciclos que se encargan de limpiar los buffers de las entradas
;del usuario.
;Tengo los tamaños de cada buffer así que nada maslo muevo al ecx y hago loop
;a cada posición del buffer le paso un 0.	

	mov ecx, 24
	.loop2:
	mov byte[buffer+ecx], 0
	mov byte[buffer2+ecx], 0
	loop .loop2
	ret

Print:
	push ebx 
	mov eax, 4
	mov ebx, 1
	int 80h
	pop ebx
	ret
