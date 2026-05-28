La empresa NexaCloud los ha contratado como arquitectos de nube y espera que
ustedes puedan aprovisionar todos los componentes y servicios que ellos necesitan.
Actualmente toda su capacidad tecnológica instalada está on-premise y quieren hacer
el paso a la nube. El proyecto piloto con el que empieza la migración será un pequeño
servicio de intranet.
Para ello se tendrá la siguiente aplicación web con 5 páginas para comprobar las
funcionalidades de los servicios.
# Contenido Explicación Service or
Protocol

1 Web Page En esta pestaña hay una página web sencilla (sólo
HTML) que muestra el nombre de la empresa. De esta
manera los empleados de NexaCloud puede
comprobar que ha desplegado el proyecto con éxito.

EC2, SSH

2 Datos de la
Bases de
Datos

En esta pestaña se muestran los datos de una Bases
de Datos. El código DDL y el código para poblar los
datos son provistos por la empresa. La conexión a
esta base de datos desde el exterior debe ser desde el
puerto 9876.

RDS, Security
Groups, VPC

3 Imágenes en
bucket

En esta pestaña se muestra un conjunto de imágenes
de los empleados. La extracción se hace por medio de
una API Gateway, y sirve como Event Source para
disparar una función lambda que hace la extracción de
las imágenes desde un bucket de S3. Este bucket
debe ser creado y las imágenes deben depositarse en
él. La función lambda encargada de proveer las
imágenes a la web de NexaCloud debe programarse.

S3, Lambda,
API Gateway,
VPC

4 Lambda
function

En esta pestaña hay un botón que hace una petición a
un API Gateway. Dicho API Gateway debe ser creado
por ustedes, y debe servir de Event Source para
disparar una función lambda que inserte en la base de
datos la información de ambos integrantes del equipo
en la tabla estudiantes. La función Lambda que inserta
la info de los estudiantes debe programarse.

Lambda, API
Gateway

5 Monitoreo y
Alertas

Monitorizar los servicios y crear alertas pertinentes
que notifiquen cuando ciertos umbrales sean
alcanzados o eventos específicos ocurran.

CloudWatch,
SNS

6 Balanceador
de carga

Esta pestaña recarga constantemente una página web
embebida (no provista por NexaCloud). Se espera
que esta página sea servida por un balanceador de
carga, y debe mostrar información de interés, con al
menos el identificador del servidor que lo sirve en su
cabecera (nombre único). Se espera que detrás del
balanceador, haya varios servidores independientes
de EC2, y que sea posible generar más de forma
manual.

Elastic Load
Balancing,
EC2

Para NexaCloud, es de suma relevancia que todos los servicios desplegados en la
nube se configuren siguiendo las mejores prácticas del sector. Esta expectativa no es
únicamente por una cuestión de excelencia operativa, sino también para garantizar la
seguridad y privacidad de la información y recursos de la empresa.
Un ejemplo claro de estas mejores prácticas se refiere a la gestión de accesos. En
NexaCloud insisten en que ningún individuo o entidad fuera de la organización pueda
tener acceso no autorizado a sus recursos, por ejemplo:
● La API Gateway debe estar protegida y no permitir accesos no autorizados. La
utilización de una API Key es esencial para garantizar que solo las partes
autorizadas puedan interactuar con esta interfaz.
● Cualquier bucket que se cree no debe ser público. Es inaceptable que cualquier
persona, sin la debida autorización, pueda acceder, leer o escribir en los
almacenamientos de NexaCloud.
Además de las configuraciones de seguridad, NexaCloud espera una administración
financiera prudente. Es esencial que se presente un reporte detallado de estimación de
costos de los servicios que se implementarán en los próximos 6 meses. Si bien la
empresa está comprometida con la innovación y la mejora continua, también es
consciente de la necesidad de optimizar los gastos. Por lo tanto, se espera que las

instancias y recursos que se utilicen sean económicamente eficientes. NexaCloud no
está dispuesta a incurrir en gastos excesivos solo para realizar pruebas iniciales o
prototipos.
Se espera también un informe técnico de la arquitectura final del proyecto, con los
respectivos diagramas de red y topología de la estructura.

Notas:
1. La app web principal NO será desarrollada por ustedes. Su trabajo es
implementar y aprovisionar los servicios de AWS para luego conectarlos a la app
web.
2. Las funciones lambda sí deben ser desarrolladas por ustedes.
3. El acceso a las instancias por SSH debe estar bloqueado o puesto en otro
puerto diferente al predeterminado (SSH funciona predeterminadamente por el
puerto 22).
4. Para la conexión con la base de datos pueden usar cualquier cliente. Se
recomienda DBeaver por su facilidad.
5. Las imágenes para el Bucket serán proporcionadas por NexaCloud.