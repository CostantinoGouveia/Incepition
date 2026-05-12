# USER DOCUMENTATION (Inception)

##  Overview

This project provides a Docker-based infrastructure composed of:

* MariaDB (Database)
* WordPress (Web Application)
* (Optional) Nginx (Web Server)

The goal is to deploy a fully functional WordPress website using containerization.

---

##  How to Start the Project

To start all services:

```bash
make up
```

Or using Docker Compose directly:

```bash
docker compose up -d
```

---

##  How to Stop the Project

```bash
make down
```

Or:

```bash
docker compose down
```

---

##  Access the Website

Once the containers are running, open your browser and go to:

```
http://localhost
```

Or:

```
http://<SERVER_IP>
```

---

##  Access WordPress Admin Panel

After installation:

```
http://localhost/wp-admin
```

---

##  Credentials

Credentials are stored securely using Docker Secrets.

Location:

```
secrets/db_password.txt
secrets/db_root_password.txt
```

Example:

* Database user: `wp_user`
* Password: defined in `db_password.txt`

---

##  Check if Services are Running

### List running containers:

```bash
docker ps
```

### Check logs:

```bash
docker logs wordpress
docker logs mariadb
```

---

## 🔍 Test Database Connection

Enter the WordPress container:

```bash
docker exec -it wordpress bash
```

Then:

```bash
mysql -h mariadb -u wp_user -p
```

---

##  Data Persistence

Data is stored using Docker volumes:

* `mariadb_data` → database files
* `wordpress_data` → WordPress files

This ensures data is not lost when containers restart.

---

##  Common Issues

### WordPress cannot connect to database

* Check if MariaDB is running:

  ```bash
  docker ps
  ```
* Check logs:

  ```bash
  docker logs mariadb
  ```

---

##  Clean the Environment

 This will remove ALL data:

```bash
docker compose down -v
```

---
