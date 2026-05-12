# DEVELOPER DOCUMENTATION (Inception)

##  Prerequisites

Make sure you have installed:

* Docker
* Docker Compose
* Make (optional but recommended)

---

##  Initial Setup

### 1. Clone the repository

```bash
git clone <repository_url>
cd <repository>
```

---

### 2. Create secrets

```bash
mkdir -p ../secrets
```

Create the files:

```bash
echo "your_user_password" > ../secrets/db_password.txt
echo "your_root_password" > ../secrets/db_root_password.txt
```

---

### 3. Configure environment variables

Create a `.env` file:

```env
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
```

---

##  Build the Project

```bash
make build
```

Or:

```bash
docker compose build --no-cache
```

---

##  Run the Project

```bash
make up
```

Or:

```bash
docker compose up -d
```

---

##  Container Management

### List containers:

```bash
docker ps
```

### Access containers:

```bash
docker exec -it wordpress bash
docker exec -it mariadb bash
```

---

##  Logs

```bash
docker logs wordpress
docker logs mariadb
```

---

##  Restart services

```bash
docker compose restart
```

---

##  Project Structure

```
srcs/
 ├── docker-compose.yml
 ├── requirements/
 │    ├── mariadb/
 │    ├── wordpress/
 │    └── nginx/
 ├── secrets/
 └── .env
```

---

##  Data Persistence

The project uses Docker volumes to persist data even if containers are removed or restarted.

Volumes used:

- `mariadb_data` → mounted inside the container at `/var/lib/mysql`
- `wordpress_data` → mounted inside the container at `/var/www/html`

These volumes are mapped to a `data/` directory on the host machine.

---

##  Secrets vs Environment Variables

### Docker Secrets

* Secure
* Not exposed in container inspection

### Environment Variables

* Easier to use
* Less secure

---

##  Docker Network

Network used:

```
inception
```

Allows communication between containers using service names:

```
wordpress → mariadb
```

---

##  Test Container Communication

Inside WordPress container:

```bash
mysql -h mariadb -u wp_user -p
```

---

##  Common Issues

### MariaDB keeps restarting

* Check `run.sh`
* Verify passwords
* Check permissions:

```bash
chown -R mysql:mysql /var/lib/mysql
```

---

### WordPress cannot connect to database

* Ensure hostname is correct: `mariadb`
* Check network:

```bash
docker network inspect inception
```

---

##  Full Cleanup

```bash
docker compose down -v
docker system prune -a
```

---

##  Key Information

* Database: MariaDB
* Application: WordPress
* Communication: Docker Network
* Persistence: Docker Volumes

---
