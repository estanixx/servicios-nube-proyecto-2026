
# Proyecto de Servicios en la nube 2026

Este proyecto busca evaluar las capacidades de los estudiantes del curso de _Servicios en la nube_
de a Universidad Nacional de Colombia sede Medellín, al implementar la infraestructura necesaria
en la nube de Amazon Web Service (AWS), para correr de forma exitosa cada una de las secciones
de este proyecto.

## Dependencias

Este proyecto requiere **[Node.js versión 20 (la LTS actual)](https://nodejs.org/en/download)**. Además es necesario correr los comandos en un ambiente Linux, por ejemplo pueden usar [Windows Subsystem for Linux (WSL)](https://www.omgubuntu.co.uk/how-to-install-wsl2-on-windows-10) en caso tal use Windows como sistema operativo.

Dentro de la carpeta del proyecto (local) correr el siguiente comando:

```bash
npm install
```

Para realizar pruebas de estrés, es necesario que en el **servidor** en el que se ejecute disponga del comando `stress`. Dependiendo del sistema operativo, puede instalarse con alguno de los siguientes comandos:

```bash
sudo apt install stress -y
# Fedora
sudo dnf install stress -y
# Red Hat
sudo yum install stress -y
# Arch derivates
sudo pacman -S stress 
```

El proyecto está desarrollado utilizando [Next.js](https://nextjs.org/).
Puede ejecutar el proyecto en entorno local utilizando cualquiera de estos comandos:

```bash
npm run dev
# or
yarn dev
# or
pnpm dev
# or
bun dev
```

Acceda a [http://localhost:3000](http://localhost:3000) para visualizar los resultados en el entorno local.

El proyecto utiliza una base de datos PostgreSQL, un Bucket de S3, y un par de servicios Lambda.

Además, se debe recordar del requerimiento denominado "Balanceador de carga ", que implica el uso de una URL que apunta a un balanceador de carga. Esta página se carga a través de un proxy interno y se muestra en un iFrame. 

## Despliegue

Puede implementar este proyecto directamente en EC2 o utilizar Elastic Beanstalk. Se proporciona un archivo de ejemplo (.env.example) con las variables de entorno necesarias, pero se espera que, al realizar la implementación, se coloquen estas variables en las ubicaciones adecuadas, siguiendo las mejores prácticas para este tipo de aplicaciones.

Si desea desplegar estas variables de entornos de forma local, necesita crear un archivo `.env ` y agregar el contenido del archivo de ejemplo reemplazando los datos de las configuraciones reales.

Para preparar el proyecto para el despliegue deben seguir los siguientes pasos:

```bash
npm run build
```

Este comando nos creará el zip dentro de la carpeta, listo para subir a la nube.

**Recomendación:** Cada vez que corra el anterior comando, asegurse de eliminar la carpeta .next, para que los cambios puedan surtir efectos.

Consulte la [documentación de implementación de Next.js](https://nextjs.org/docs/deployment) para obtener más detalles.

## Bases de datos

En la carpeta database, se encuentra un [archivo sql](https://github.com/adatapoint/servicios-nube-proyecto-2025/blob/main/database/ddl-estudiante.sql), el cual tiene el script para crear la tabla y registrar los datos dummy en la bases de datos.

## Imágenes del Bucket S3

En el siguiente [link](https://drive.google.com/drive/folders/1lZPTUXAaDkVg0PWpys5wQ3OcJbO-4V9f?usp=share_link), encuentran las imágenes que deben subir al bucket.

## Errores en este proyecto

Si detecta algún error en este proyecto, le instamos a informarlo a través de los canales oficiales del curso. También estamos abiertos a recibir Pull Requests, aunque no se garantiza su aceptación.

---

## Despliegue de Infraestructura con Terraform

Esta sección describe cómo desplegar la infraestructura en AWS utilizando Terraform.

### Requisitos Previos

1. **Cuenta de AWS** con permisos para crear recursos (EC2, RDS, Lambda, API Gateway, S3, VPC, etc.)
2. **AWS CLI** configurada con credenciales (`aws configure`)
3. **Terraform** instalado (versión >= 1.5.0)

### Paso 1: Configurar el Backend de Terraform

Por seguridad, las credenciales del backend (bucket S3 para estado) no están en el código. Copie el archivo de ejemplo:

```bash
cp terraform/backend.tf.example terraform/backend.tf
```

Edite `terraform/backend.tf` y reemplace los valores:

```hcl
terraform {
  backend "s3" {
    bucket       = "NOMBRE-DE-SU-BUCKET"   # Cree un bucket S3 para estado
    key          = "ruta/al/estado.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
```

### Paso 2: Inicializar Terraform

```bash
cd terraform
terraform init
```

### Paso 3: Variables de Configuración

Cree un archivo `terraform/terraform.tfvars` con sus valores personalizados:

```hcl
# IP desde la cual permitirá acceso SSH (su IP actual)
office_ip = "SU_IP/32"

# Nombre del proyecto (usado para etiquetar recursos)
project_name = "nexacloud"

# Puerto SSH no estándar
ssh_port = 2222

# Configuración de EC2
ec2_instance_type  = "t3.micro"
ec2_min_size        = 2
ec2_max_size        = 5
ec2_desired_capacity = 2
ec2_key_pair        = "NOMBRE_DE_SU_KEY_PAIR"

# Configuración de RDS
rds_instance_class = "db.t3.micro"
rds_allocated_storage = 20

# Email para alertas SNS
alert_email = "su-email@ejemplo.com"
```

### Paso 4: Planificar y Aplicar

```bash
# Ver los cambios que se aplicarán
terraform plan

# Desplegar la infraestructura
terraform apply
```

### Paso 5: Configurar Variables de Lambda

Una vez desplegada la infraestructura, debe configurar las variables de entorno de las funciones Lambda. Estas no se pueden configurar vía Terraform en tiempo de ejecución, así que use AWS CLI:

```bash
# Obtener información de los recursos creados
terraform output

# Configurar variables para InsertStudentLambda
aws lambda update-function-configuration \
  --function-name nexacloud-insert-student \
  --environment Variables='{
    "DB_HOST":"ENDPOINT_RDS",
    "DB_PORT":"9876",
    "DB_USER":"nexacloud_admin",
    "DB_PASSWORD":"SU_PASSWORD",
    "DB_NAME":"nexaclouddb",
    "API_KEY":"SU_API_KEY"
  }'

# Configurar variables para ServeImagesLambda
aws lambda update-function-configuration \
  --function-name nexacloud-serve-images \
  --environment Variables='{
    "S3_BUCKET_NAME":"NOMBRE_DEL_BUCKET_S3",
    "API_KEY":"SU_API_KEY"
  }'
```

### Paso 6: Cargar Imágenes al Bucket S3

1. Descargue las imágenes del [drive compartido](https://drive.google.com/drive/folders/1lZPTUXAaDkVg0PWpys5wQ3OcJbO-4V9f?usp=share_link)
2. Cárguelas al bucket S3 creado:

```bash
aws s3 cp ./imagenes/ s3://NOMBRE_DEL_BUCKET_S3/images/ --recursive
```

### Recursos CREADOS

El despliegue crea los siguientes recursos en AWS:

| Recurso | Descripción |
|---------|-------------|
| VPC | Virtual Private Cloud con CIDR 10.0.0.0/16 |
| Subnets | 2 públicas + 2 privadas en 2 AZs |
| RDS PostgreSQL | Base de datos con puerto 9876 |
| S3 Bucket | Almacenamiento para imágenes de empleados |
| Lambda (Insert Student) | Función para insertar estudiantes |
| Lambda (Serve Images) | Función para servir imágenes vía URL prefirmada |
| API Gateway | API REST con endpoints /estudiante e /images |
| EC2 ASG | Auto Scaling Group con instancias t3.micro |
| Load Balancer | Application Load Balancer |
| CloudWatch | Dashboard, logs y alarmas |
| SNS | Tema para alertas por email |

### Destruir la Infraestructura

Para eliminar todos los recursos:

```bash
terraform destroy
```

**Nota:** Antes de destruir, asegúrese de:
1. Vaciar el bucket S3: `aws s3 rm s3://NOMBRE_BUCKET --recursive`
2. Hacer backup de cualquier dato importante en RDS
