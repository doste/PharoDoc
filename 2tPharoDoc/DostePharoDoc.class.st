"
I represent a Docs generator for Pharo classes.

Given a set of classes I generate a site to show all their methods and its corresponding comments.

I work by generating .pillar files from the methods and their comments of all the given classes.
Then, said files will be given to Ecstatic to generate the site containting all the info """"nicely"""" formatted.

To work properly I need to know: 
	1) The set of classes to show the docs for.
	2) A file path to the folder where I'll put all the generated .pillar files, so Ecstatic then can generate the proper site.
	
The main method to generate the docs is: generateDocPages
"
Class {
	#name : #DostePharoDoc,
	#superclass : #Object,
	#instVars : [
		'classesToShow',
		'pathToFolder'
	],
	#category : #'2tPharoDoc'
}

{ #category : #accessing }
DostePharoDoc >> classesToShow [

	^ classesToShow
]

{ #category : #accessing }
DostePharoDoc >> classesToShow: anObject [

	classesToShow := anObject
]

{ #category : #'as yet unclassified' }
DostePharoDoc >> concatCollection: aCollection withOtherCollection: anotherCollection [
		"The problem I had was that I wanted to concatenate two collections and maybe anotherCollection was nil, in that case the result it would be just
		aCollection, not to crash"
		"
		x := DostePharoDoc new.
		p := OrderedCollection new.
		p add: 23; add: 12; add: 5; yourself.""
		q := OrderedCollection new.
		q add: 'hola'; add: $a; yourself.""
		res := x concatCollection: p withOtherCollection: q.   --> res = { 23 . 12 . 5 . 'hola'. $a } (same as res := p, q. )
		
		But now, if:
		p := 'hola'.
		q := nil.
		res := p, q would crash! but
		res := x concatCollection: p withOtherCollection: q.  --> res = { 'hola' }
		
		"
		
		| mergedCollection |
		
		aCollection ifNil: [ 
				anotherCollection ifNil: [ 
						^ nil.
				] ifNotNil: [  
						^ anotherCollection
				]
		 ].
		"here we know that aCollection is not nil, so:"
		mergedCollection := aCollection.
		
		anotherCollection ifNotNil: [ mergedCollection := mergedCollection, anotherCollection ].

		^ mergedCollection
		
		
]

{ #category : #'doc-generation' }
DostePharoDoc >> generateDocPages [
	
	"Clases elegidas de manera completamente arbitraria."
	"self classesToShow: {Collection. GeometryObject. HEAbstractExported. BitBlt. AbstractDebugger}."
	
	self generateIndexPageForClasses: self classesToShow.

	"Aca se generan las paginas para cada una de las clases y subclases:"
	(self classesToShow) do: [ :aClassToShow | 
										 (aClassToShow  subclasses) do: [ :aSubclass | self generatePageForClass: aSubclass ]
	.]
]

{ #category : #'as yet unclassified' }
DostePharoDoc >> generateIndexPage [

	| result fileName |
	
	"result := {Array . String}. this was just to test"
	result := self getClassWithItsSubclasses: String.
	
	fileName := '/Users/juanidoste/ecstatic-example/index.pillar'.
	fileName asFileReference writeStreamDo: [ :w | 
																					w nextPutAll: '!PharoDoc'.
																					w nextPutAll: String cr.
																					w nextPutAll: '!!!'.
																					w nextPutAll: 'All Classes'.	
																					w cr.
																					w nextPutAll: String cr.			
																					"| *String>/classString.pillar*   |"																
																					result do: [ :aClass |  w nextPutAll: '| *'.
																															w nextPutAll: aClass printString.
																															w nextPutAll: '>/'.
																															w nextPutAll: 'class'.
																															w nextPutAll: aClass printString.
																															w nextPutAll: '.pillar* |'.
														 							w nextPutAll: String cr.
																					w nextPutAll: '[[['.
																					w nextPutAll: String cr.   "este vacio para que haya un poco de distancia entre cada metodo"
																					w nextPutAll: ']]]'.
																					w nextPutAll: String cr.
																					 ]. ].
]

{ #category : #'as yet unclassified' }
DostePharoDoc >> generateIndexPageForAllClasses [
	"Este el metodo 'principal', el que arma la index page.
	En classesToShow se pueden configurar las clases a mostrar. Por como funciona la logica interna del programa, classesToShow deberia contener 
	clases 'Base', es decir aquellas que tienen muchas subclases. De esta manera, por ejemplo teniendo la clase Collection como una de las classesToShow
	el programa ya se encargara de generar la vista para *todas* sus subclases 
	
	En este metodo, por cada una de las subclases de cada classToShow, generamos su 'index page', esta terminara siendo una seccion de toda la Index Page."
	| classesToShow fileName |
	
	classesToShow := {Collection.}.
	
	fileName := '/Users/juanidoste/ecstatic-example/index.pillar'.
	fileName asFileReference writeStreamDo: [ :w | 
																					w truncate: 0.
																					w nextPutAll: '!PharoDoc'.
																					w nextPutAll: String cr.
																					w nextPutAll: '!!!'.
																					w nextPutAll: 'All Classes'.	
																					w cr.
																					w nextPutAll: String cr.																		
																					classesToShow do: [ :aClass |  self generateIndexPageForClass: aClass withWriteStream: w ]. ].
]

{ #category : #'doc-generation' }
DostePharoDoc >> generateIndexPageForClass: aClass withWriteStream: aWriteStream [
	"Este metodo genera la seccion del Index Page correspondiente a la clase aClass.
	El WriteStream  es recibido como parametro para ir usando el mismo que se configuro en el metodo que invoco a este, generateIndexPageForAllClasses."
	| str|
	
	str := self getDescriptorsForClassAndItsSubclasses: aClass withLevelOfIndentation: 1.
	aWriteStream setToEnd. "Estamos escribiendo el 'modo append', es decir al final de lo que ya habia escrito. Para no pisar lo que ya teniamos."
	aWriteStream cr. 
	aWriteStream nextPutAll: str.
	aWriteStream cr
	
]

{ #category : #'doc-generation' }
DostePharoDoc >> generateIndexPageForClasses: allTheClasses [
	"Este el metodo 'principal', el que arma la index page.
	En classesToShow se pueden configurar las clases a mostrar. Por como funciona la logica interna del programa, classesToShow deberia contener 
	clases 'Base', es decir aquellas que tienen muchas subclases. De esta manera, por ejemplo teniendo la clase Collection como una de las classesToShow
	el programa ya se encargara de generar la vista para *todas* sus subclases 
	
	En este metodo, por cada una de las subclases de cada classToShow, generamos su 'index page', esta terminara siendo una seccion de toda la Index Page."
	| fileName |
	
	"fileName := '/Users/juanidoste/ecstatic-example/index.pillar'."
	fileName := self pathToFolder, '/index.pillar'.
	fileName asFileReference writeStreamDo: [ :w | 
																					w truncate: 0.
																					w nextPutAll: '!PharoDoc'.
																					w nextPutAll: String cr.
																					w nextPutAll: '!!!'.
																					w nextPutAll: 'All Classes'.	
																					w cr.
																					w nextPutAll: String cr.																		
																					allTheClasses do: [ :aClass |  self generateIndexPageForClass: aClass withWriteStream: w ]. ].
]

{ #category : #'doc-generation' }
DostePharoDoc >> generatePageForClass: aClass [
	"Dada una clase, este metodo genera su pagina correspondiente. Aqui se mostraran los metodos con sus respectivos comentarios de la clase en cuestion."
	| allTheMethods fileName |
	
	allTheMethods := (aClass methods) reject: [ :method | method comment isNil].   "Ignoraramos aquellos metodos que no tienen comentarios."
	fileName := self pathToFolder, '/class', aClass printString, '.pillar'.

	fileName asFileReference writeStreamDo: [ :w | 
																					w nextPutAll: '!PharoDoc'.
																					w cr.
																					w nextPutAll: '!!!Class: '.
																					w nextPutAll: aClass printString.	
																					w cr.	
																					w nextPutAll: '!!!!!Superclass: '.
																					w nextPutAll: (aClass superclass printString).
																					w cr.
																					w nextPutAll: '!!!!Methods'.	
																					w cr.
																					w cr.
																					allTheMethods ifEmpty: [ w nextPutAll: 'There are no methods in this class.' ].																			
																					allTheMethods do: [ :method |  w nextPutAll: '|'.
																															w nextPutAll: method selector.
																															w nextPutAll: '|'.
														 							w cr.
																					w nextPutAll: '[[['.
																					w cr.
														 							w nextPutAll: method comment.
																					w nextPutAll: String cr.
																					w nextPutAll: ']]]'.
														 							w nextPutAll: String cr.
																					w nextPutAll: '[[['.
																					w nextPutAll: String cr.   "este vacio para que haya un poco de distancia entre cada metodo"
																					w nextPutAll: ']]]'.
																					w nextPutAll: String cr.
																					 ]. ].
]

{ #category : #'as yet unclassified' }
DostePharoDoc >> getClassWithItsSubclasses: aClass [
		"Returns an OrderedCollection containing aClass *and* each subclass of it"
		
		| aClassWithAllSubclasses |
		
		aClassWithAllSubclasses := OrderedCollection new.
		
		aClassWithAllSubclasses add: aClass.
		
		^ self concatCollection:  aClassWithAllSubclasses withOtherCollection: (self getSubclassesOfClassRecursive: aClass )
]

{ #category : #'doc-generation' }
DostePharoDoc >> getDescriptorsForClassAndItsSubclasses: aClass withLevelOfIndentation: indent [
	"
	Expected result from calling getDescriptorsForClassAndItsSubclasses: String withLevelOfIndentation: 1 :
	String 
		ByteString.
		Symbol.
			ByteSymbol.
			WideSymbol
		WideString
	"	
	| str |
	str := String new.
	
	"Si indent = 1 es porque aClass es una de las clases 'Base', osea que deberian aparecer con indentacion 0, en ese caso imprimimos sin indentacion:"
	indent = 1 ifFalse: [ 
			"sino, agregamos el correspondiente nivel de indentacion"
			1 to: (indent-1) do: [ :i | str := str, '|     |' ].
	].
	str := str,'| *', aClass printString, '>/class', aClass printString, '.pillar* |', String cr, '[[[', String cr, ']]]', String cr.
	
	
	(aClass subclasses) do: [ :aSubclass | str := str, (self getDescriptorsForClassAndItsSubclasses: aSubclass withLevelOfIndentation: (indent + 1)) ].
	
	^ str
	
	
]

{ #category : #'as yet unclassified' }
DostePharoDoc >> getSubclassesOfClass: aClass [
		"One level deep. Return subclasses of aClass *and* the subclasses of each subclass of aClass"
		
		| subClassesOfClass subClasesToReturn |
		
		subClassesOfClass := aClass subclasses.
		
		subClassesOfClass ifEmpty: [^ nil].
		
		subClasesToReturn := OrderedCollection new.

		subClassesOfClass := subClassesOfClass reject: [ :s | s class subclasses isEmpty ].

		subClassesOfClass do: [ :s | 
															(s class subclasses) do: [ :ss | subClasesToReturn add: ss ]].

		^ subClasesToReturn
		
		
]

{ #category : #'as yet unclassified' }
DostePharoDoc >> getSubclassesOfClassRecursive: aClass [
		"A ver si sale recursivo esto"
		
		| subClassesOfClass subClasesToReturn |
		
		subClassesOfClass := aClass subclasses.
		
		subClassesOfClass ifEmpty: [^ nil].
		
		subClasesToReturn := OrderedCollection new.
		
		"subClassesOfClass do: [ :s | subClasesToReturn add: s.
															subClasesToReturn :=  subClasesToReturn, (self getSubclassesOfClassRecursive: s) ]. la llamada recursiva puede retornar NIL!!!! ver ese caso a parte!, me invento un metodo para salvar ese caso:"
														
		subClassesOfClass do: [ :s | subClasesToReturn add: s. "first we add the subclass s. and then we recursively add the subclasses of s"
															subClasesToReturn :=  self concatCollection: subClasesToReturn withOtherCollection: (self getSubclassesOfClassRecursive: s) ].
														
		^ subClasesToReturn
		
		
]

{ #category : #accessing }
DostePharoDoc >> pathToFolder [

	^ pathToFolder
]

{ #category : #accessing }
DostePharoDoc >> pathToFolder: anObject [

	pathToFolder := anObject
]
