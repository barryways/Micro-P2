#Proyecto No. 2 Microprogramacion
#Byron Albizurez y Carlos Barrientos
.global proyecto #Punto de Arranque

.data #Segmento de Variables
	buffer: .string "100" #cantidad de bytes
	ruta: .string "prueba.txt"
	errorLectura: .string "No se ha podido abrir el archivo"
	
	matrix: .space 1296                   # Reservamos espacio para una matriz de 5x5 de enteros (4 bytes por cada posición) matriz maxima de 9*9 y eso por los 16 bytes de la cadena 1296
	newline: .string "\n"                # Cadena para nueva línea
	space: .string " | "                   # Espacio entre números
	text: .string "A-C B-C C-C D-C"      # Definimos el string "A-C B-C C-C D-C"
	iniciobuffer: .string "Indicaciones de camino: "
	
.text #Segmento de Codigo
proyecto: #En esta etiqueta empieza nuestro programa

	la s0, buffer 	#Guardamos la direccion donde empieza la cadena
	li s1, 101 		#Validacion para mas de 100 bytes

abrirArchivo:
	li a1, 0 		#parametro 0 es modo lectura (permisos)
	la a0, ruta 	#enviar direccion de la ruta del archivo
	li a7, 1024 	#abrir el archivo
	ecall
	
#validar que el archivo se haya abierto
	blt a0, zero, imprimirErrorLectura
	mv s2, a0  	#guardamos en s2 el descriptor del archivo y si existe tambien un error

cicloLectura:
	mv a0, s2
	mv a1, s0	 				#mandamos una direccion de memoria para guardar lo que venga
	mv a2, s1					#cantidad de bytes que va a leer
	li a7, 63					#parametro para leer por bytes el archivo
	ecall
	
	bltz a0, cerrarArchivo  	#en caso de error cerrar el archivo 
	mv t0, a0 					#usamos registro T para contenido del archivo 
	add t1, s0, a0 				#sumamos la cantidad de bytes que leyo
	sb zero, 0(t1)

	mv a0, s0					#asignamos lo que vamos a imprimir
	li a7, 4					#parametro para imprimir
	ecall
	
	beq t0, s1, cicloLectura
    	
    	la a0, newline                   # Imprimir salto de línea
    	li a7, 4                         # Código de syscall para imprimir cadena
    	ecall

	# Procesar los dos números que nos interesan
	la t1, buffer               # t1 apunta al inicio del buffer

	# Ignorar el primer número
	lb t2, 1(t1)                # Cargar segundo número (05)
	lb t3, 4(t1)                # Cargar cuarto número (05)

	# Convertir caracteres a enteros
	li t4, '0'                  # Cargar el valor ASCII de '0' en t4
	sub t2, t2, t4              # Convertir a entero (caracter - '0')
	sub t3, t3, t4              # Convertir a entero (caracter - '0')
	
	# Guardar los enteros en registros
	mv s3, t2                   # Guardar primer número en s3
	mv s4, t3                   # Guardar segundo número en s4


	# Aquí continúa el proceso para llenar la matriz
	la t1, matrix                    # t1 apunta al inicio de la matriz
	mul t2, s4, s4                   # t2 = s4 * s4
	li t3, 16                        # Cargar el valor constante 16 en t3
	mul t2, t2, t3                   # t2 = t2 * 16
	li t3, 0   # Limpia el registro t0 poniendo 0 en él
	la t3, text                      # t4 apunta a la cadena "A-C B-C C-C D-C"
    
    # Llenar la matriz 5x5 con "A-C B-C C-C D-C" en cada posición
fill_matrix:
    li t4, 16                        # Número de bytes en cada cadena
    
copy_text:
    lb t5, 0(t3)                     # Cargar el byte actual de "A-C B-C C-C D-C" en t5
    sb t5, 0(t1)                     # Guardar el byte en la posición actual de la matriz
    addi t1, t1, 1                   # Avanzar al siguiente byte en la matriz
    addi t3, t3, 1                   # Avanzar al siguiente byte en "A-C B-C C-C D-C"
    addi t4, t4, -1                  # Decrementamos el contador de bytes restantes
    bnez t4, copy_text               # Continuar hasta copiar todos los bytes de "A-C B-C C-C D-C"

    la t3, text                      # Resetear t3 al inicio de "A-C B-C C-C D-C"
    la t5, matrix                    # Reiniciar t5 al inicio de la matriz
    sub t6, t1, t5                   # Calcular cuántos bytes se han llenado
    blt t6, t2, fill_matrix          # Continuar llenando hasta alcanzar el tamaño total de la matriz

    # Reset de t1 para apuntar de nuevo al inicio de la matriz
    la t1, matrix

    # Imprimir la matriz 5x5
    # Imprimir la matriz 5x5
print_matrix:
    mv t3, s3                         # Usar el registro s3 como contador para los elementos por fila
print_row:
    mv a0, t1                        # Cargar la dirección actual de la cadena en a0
    li a7, 4                         # Código de syscall para imprimir cadena
    ecall                            # Llamada de sistema para imprimir el string
    
    la a0, space                   # Imprimir un espacio entre cada columna
    li a7, 4                         # Código de syscall para imprimir cadena
    ecall

    addi t1, t1, 16                  # Avanzamos al siguiente string en la matriz (16 bytes por cadena)
    addi t3, t3, -1                  # Decrementamos el contador de fila
    bnez t3, print_row               # Si no hemos llegado al final de la fila, continuar imprimiendo

    # Imprimir nueva línea después de cada fila
    la a0, newline                   # Imprimir salto de línea al final de cada fila
    li a7, 4                         # Código de syscall para imprimir cadena
    ecall

    # Repetir para cada fila
    la t5, matrix                    # Reiniciamos t5 con el inicio de la matriz
    sub t6, t1, t5                   # Calculamos cuántos bytes hemos recorrido
    blt t6, t2, print_matrix         # Si no hemos llegado al final de la matriz, repetir
    
    la a0, newline                   # Imprimir texto
    li a7, 4                         # Código de syscall para imprimir cadena
    ecall

    
modificarMatriz:
	
	la a0, iniciobuffer                   # Imprimir texto
    	li a7, 4                         # Código de syscall para imprimir cadena
    	ecall

	la t1, buffer
	addi t1, t1, 6

	#imprimir
	mv a0, t1
	li a7, 4
	ecall
	
	la a0, newline                   # Imprimir salto de línea
    	li a7, 4                         # Código de syscall para imprimir cadena
    	ecall
    	
    	 # Terminar el programa
    	li a7, 10                        # Código de syscall para terminar el programa
   	ecall


cerrarArchivo:
	mv a0, s2 #Guardamos el descriptor del archivo
	li a7, 57 #Desciptor del archivo
	ecall

imprimirErrorLectura:
	la a0, errorLectura
	li a7, 4
	ecall
	
finalizar:
	li a7, 10
	ecall
