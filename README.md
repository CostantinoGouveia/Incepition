*This project has been created as part of the 42 curriculum by cgouveia*

#  Inception

##  Description

The **Inception** project focuses on system administration using **Docker** and containerization.
Its main goal is to set up a small infrastructure composed of multiple services, each running in its own container, and communicating through a Docker network.

The project includes:

* A **WordPress** website (PHP-FPM)
* A **MariaDB** database
* An **Nginx** web server (with SSL)

Each service is isolated inside its own container and configured manually using Dockerfiles, without using pre-built images like `wordpress` or `mysql`.

The objective is to understand:

* How containers work internally
* How services communicate in a network
* How to manage data persistence
* How to configure and secure services manually

---

##  Instructions

###  Requirements

* Docker
* Docker Compose

###  Installation

Clone the repository:

```bash
cd inception/
```

---

###  Build the project and run the services

```bash
make
make all
```

---

###  Build the project

```bash
make build
```

---

###  Run the services

```bash
make up
```

---

###  Check running containers

```bash
make ps
```

---

###  View volumes

```bash
make  volumes
```

---

###  View networks

```bash
make  networks
```

---

###  View logs

```bash
make  logs
```

---

###  Stop containers

```bash
make down
make clean
```

---

###  Stop everything

```bash
make fclean
```

---

##  Project Architecture

The infrastructure is composed of:

* **Nginx**

  * Acts as a reverse proxy
  * Handles HTTPS (SSL)
  * Serves WordPress content

* **WordPress (PHP-FPM)**

  * Handles dynamic content
  * Connects to MariaDB

* **MariaDB**

  * Stores website data
  * Uses persistent volumes

All services communicate through a custom **Docker network**.

---

##  Design Choices

###  Virtual Machines vs Docker

| Virtual Machines     | Docker                  |
| -------------------- | ----------------------- |
| Full OS per instance | Shares host kernel      |
| Heavy (GBs)          | Lightweight (MBs)       |
| Slower startup       | Fast startup            |
| Strong isolation     | Process-level isolation |

 Docker was chosen because it is:

* Faster
* More efficient
* Easier to manage for microservices

---

###  Secrets vs Environment Variables

| Secrets             | Environment Variables |
| ------------------- | --------------------- |
| Stored securely     | Visible in container  |
| Not exposed in logs | Can leak easily       |
| Used for passwords  | Used for configs      |

Secrets are used for:

* Database passwords
* Root credentials

This improves security and avoids exposing sensitive data.

---

###  Docker Network vs Host Network

| Docker Network          | Host Network       |
| ----------------------- | ------------------ |
| Isolated environment    | Uses host directly |
| Service name = hostname | No isolation       |
| Secure communication    | Less control       |

 A custom Docker network allows:

* Containers to communicate using service names (`mariadb`, `wordpress`)
* Better isolation and security

---

###  Docker Volumes vs Bind Mounts

| Volumes           | Bind Mounts               |
| ----------------- | ------------------------- |
| Managed by Docker | Linked to host filesystem |
| Portable          | Depends on host path      |
| Safer             | Risk of permission issues |

Volumes are used for:

* Database persistence
* WordPress files

This ensures data is not lost when containers restart.

---

##  Sources

The project includes:

* Custom **Dockerfiles** for each service
* Configuration files:

  * Nginx config
  * PHP-FPM config
  * MariaDB setup script
* Initialization scripts (`run.sh`)
* Docker Compose configuration

All services are built from **Debian base images**.

---

##  Usage Example

After running the project:

* Access the website via:

```
https://localhost:443
```

* The main page of a standard WordPress website should appear.

---

##  Debugging Tips

```bash
# Check container status
docker ps

# View logs
docker logs mariadb
docker logs wordpress
docker compose -f srcs/docker-compose.yml logs -f

# Enter container
docker exec -it wordpress bash

# Test database connection
mysql -h mariadb -u wp_user -p

# View volumes
docker volume ls

# View networks
docker network ls
```

---

##  Resources

### Documentation

* Docker Official Docs: https://docs.docker.com/
* Docker Compose: https://docs.docker.com/compose/
* MariaDB Docs: https://mariadb.org/documentation/
* WordPress Docs: https://developer.wordpress.org/

---

### Tutorials

* Docker Crash Course
* Nginx Reverse Proxy Guide
* PHP-FPM Explained

---

###  Use of AI

AI tools (such as ChatGPT) were used in this project to:

* Understand Docker concepts and architecture
* Debug container communication issues
* Improve shell scripts and configurations
* Assist in writing documentation (README)

All configurations and implementations were manually reviewed and adapted.

---

## Conclusion

This project provides hands-on experience with:

* Containerization
* Networking
* Service orchestration
* System administration

