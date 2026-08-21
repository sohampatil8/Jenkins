# Jenkins Container with Docker Access

## 1. Run Jenkins Container

Run the following command from Docker Desktop terminal:

```bash
docker run -d \
  --name jenkins \
  -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v //var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts
```

> **Windows CMD:** Replace `\` with `^` if running in Command Prompt.

---

## 2. Enter Jenkins Container as Root

```bash
docker exec -u 0 -it jenkins bash
```

---

## 3. Update Packages and Install Docker CLI

Inside the container:

```bash
apt update
apt install -y docker.io
```

Verify installation:

```bash
docker --version
```

---

## 4. Check Docker Socket

```bash
ls -l /var/run/docker.sock
```

Expected output:

```text
srw-rw---- 1 root root ... /var/run/docker.sock
```

---

## 5. Grant Jenkins Access to Docker Socket

Check Jenkins group:

```bash
getent group jenkins
```

Change socket ownership:

```bash
chown root:jenkins /var/run/docker.sock
```

Set permissions:

```bash
chmod 660 /var/run/docker.sock
```

Verify:

```bash
ls -l /var/run/docker.sock
```

Expected:

```text
srw-rw---- 1 root jenkins ... /var/run/docker.sock
```

Exit container:

```bash
exit
```

Restart Jenkins:

```bash
docker restart jenkins
```

---

## 6. Verify Docker Access

Enter container:

```bash
docker exec -it jenkins bash
```

Switch user (if needed):

```bash
su - jenkins
```

Test Docker:

```bash
docker ps
```

Also verify:

```bash
docker info
```

---

## 7. Docker Socket on Docker Desktop (Windows)

The following mount:

```bash
-v /var/run/docker.sock:/var/run/docker.sock
```

works because Docker Desktop exposes the Docker daemon through WSL2/Linux integration.

Verify socket on host:

```bash
ls -l /var/run/docker.sock
```

---

## 8. Jenkins Pipeline Test

Example pipeline:

```groovy
pipeline {
    agent any

    stages {
        stage('Docker Test') {
            steps {
                sh 'docker --version'
                sh 'docker ps'
            }
        }
    }
}
```

---

## Architecture

```text
Windows
   │
   ▼
Docker Desktop
   │
   ├── Docker Engine
   │       │
   │       └── /var/run/docker.sock
   │
   ▼
Jenkins Container
   │
   └── Docker CLI
           │
           ▼
   Docker Desktop Engine
```

---

## Security Note

Mounting `/var/run/docker.sock` gives Jenkins full control over the Docker host. This is suitable for development and learning environments, but for production use consider:

* Docker-in-Docker (DinD)
* Dedicated build agents
* Restricted Docker permissions
