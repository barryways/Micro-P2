#Proyecto No. 2 Microprogramacion
#Byron Albizurez y Carlos Barrientos

.global proyecto #Punto de Arranque

.data #Segmento de Variables
	buffer: .string "100" #cantidad de bytes
	ruta: .string "prueba.txt"
	errorLectura: .string "No se ha podido abrir el archivo"
.text #Segmento de Codigo
proyecto: #En esta etiqueta empieza nuestro programa

	la s0, buffer 	#Guardamos la direccion donde empieza la cadena
	li s1, 101 	#Validacion para mas de 100 bytes

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
	mv a1, s0	 	#mandamos una direccion de memoria para guardar lo que venga
	mv a2, s1		#cantidad de bytes que va a leer
	li a7, 63		#parametro para leer por bytes el archivo
	ecall
	
	bltz a0, cerrarArchivo  	#en caso de error cerrar el archivo 
	mv t0, a0 			#usamos registro T para contenido del archivo 
	add t1, s0, a0 		#sumamos la cantidad de bytes que leyo
	sb zero, 0(t1)
	
	mv a0, s0				#asignamos lo que vamos a aimprimir
	li a7, 4				#parametro para imprimir
	ecall
	
	beq t0, s1, cicloLectura
	
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

