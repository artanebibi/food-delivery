# Food Delivery – Full-Stack App with Docker & K8s

A full-stack food delivery app built with **Spring Boot** (backend) and **React + Vite** (frontend), fully containerized using **Docker** and deployable via **Kubernetes** or **Docker Compose**. Includes JWT-based login, clean API design, and simple DevOps pipelines to build and deploy everything.

---

## 🛠️ Tech Stack

### Backend

* Spring Boot
* PostgreSQL (Dockerized)
* JWT Auth
* Swagger for API docs

### Frontend

* React + Vite
* Axios
* Material UI

### DevOps

* Docker
* Docker Compose
* Kubernetes (Traefik for ingress)
* ConfigMaps for secret management

---

## Getting Started

1. **Clone the project**

   ```bash
   git clone https://github.com/artanebibi/food-delivery.git
   cd food-delivery
   ```

2. **Start Kubernetes cluster (with Traefik ingress)**

   ```bash
   cd kubernetes
   ./setup_cluster.ps1
   ```

3. **Access the app after running the script on:** [http://food-delivery.com](http://food-delivery.com)

---

##  Continuous Integration (CI)

This project includes a **GitHub Actions CI pipeline** that runs automatically \*\*on every push to \*\*\`\`.

###  What It Does

Here’s what the pipeline in `.github/workflows/ci-pipeline.yml` does:

1. **Watches the **\`master`** branch**

  * Every time you push code or open a pull request on `master`, it kicks off.

2. **Starts a temporary PostgreSQL container**

  * Used so the backend can connect to a fake DB during the build:

    * Uses secrets for DB name, user, and password
    * Exposes port `2346`

3. **Checks out the code**

4. **Builds the frontend**

  * Runs `npm ci` and `npm run build` inside the `food-delivery-frontend` folder

5. **Builds the backend**

  * Uses Maven (`./mvnw clean package`)
  * Uses environment variables to simulate real DB connection (`jdbc:postgresql://localhost:2346/food_delivery`)

6. **Logs into Docker Hub**

  * Uses secrets from your repo (username + token)

7. **Builds and pushes Docker images**

  * Tags the backend and frontend images as `latest`
  * Pushes both to your Docker Hub repo

>  This ensures that every commit to `master` gives you up-to-date images ready to deploy.

---

##  Continuous Deployment (CD)


###  How It Works

This is in `.github/workflows/cd-pipeline.yml`. Here's what it does when you trigger it manually:

1. **Triggered manually**

  * Go to the "Actions" tab in GitHub
  * Select the “CD – Deploy to EC2” workflow
  * Type `YES` in the confirmation field

2. **Checks EC2 instance status**

  * If your instance is stopped, it starts it automatically

3. **Fetches EC2’s public IP**

4. **SSH setup**

  * Injects your private key into a file (`ec2_key.pem`)
  * Uses it to SSH into the EC2 server

5. **Copies the entire project to EC2**

   ```bash
   scp -i ec2_key.pem -r * ec2-user@<your-ip>:/home/ec2-user/
   ```

6. **Builds the backend on the EC2 server**

   ```bash
   cd food-delivery/food-delivery-backend
   ./mvnw clean package
   ```

7. **Deploys using Docker Compose**

  * Stops old containers (if any)
  * Pulls fresh images from Docker Hub
  * Brings everything up with `docker-compose up -d`

>  So when you push to `master`, your images are built and pushed. Then when you’re ready, you manually deploy them to your EC2 server in one click.


---

## Project Structure Description

```
food-delivery/
├── food-delivery-frontend/   # React + Vite code
├── food-delivery-backend/    # Spring Boot REST Api backend
├── kubernetes/               # Manifests for needed services
├── docker-compose.yml        # Docker Compose for orchestrating application
└── .github/workflows/        # CI/CD pipelines
```

---

## 🐳 Docker Images

These are automatically built and pushed to Docker Hub:

* `artanebibi/food-delivery-backend:latest`
* `artanebibi/food-delivery-frontend:latest`

