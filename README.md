\# Spring Boot Blue-Green Deployment on Kubernetes



!\[Java](https://img.shields.io/badge/Java-21-orange)

!\[Spring Boot](https://img.shields.io/badge/Spring%20Boot-4.1.1-brightgreen)

!\[Docker](https://img.shields.io/badge/Docker-Containerized-blue)

!\[Kubernetes](https://img.shields.io/badge/Kubernetes-Blue--Green-326CE5)



A hands-on DevOps project demonstrating \*\*blue-green deployment of a Spring Boot REST API on Kubernetes\*\*.



The application is packaged with Docker and deployed as two independent Kubernetes environments:



\- 🔵 \*\*Blue — version 1.0\*\*

\- 🟢 \*\*Green — version 2.0\*\*



Traffic is switched between the two versions by changing the Kubernetes Service selector. Before Green receives traffic, an automated PowerShell script checks rollout status and pod readiness to prevent an unhealthy deployment from becoming active.



\---



\## Architecture



```mermaid

flowchart LR

&#x20;   U\[Client] --> S\[Kubernetes Service]



&#x20;   S -->|version: blue| B\[Blue Deployment<br/>v1.0]

&#x20;   S -.->|version: green| G\[Green Deployment<br/>v2.0]



&#x20;   B --> B1\[Blue Pod 1]

&#x20;   B --> B2\[Blue Pod 2]



&#x20;   G --> G1\[Green Pod 1]

&#x20;   G --> G2\[Green Pod 2]

```



Both deployments exist simultaneously.



The Service routes traffic only to pods matching its active selector:



```yaml

selector:

&#x20; app: bluegreen

&#x20; version: blue

```



Switching to Green changes only:



```yaml

version: green

```



This allows a new release to be prepared and health-checked before production traffic is redirected.



\---



\## Features



\- Spring Boot REST API

\- Java 21

\- Docker containerization

\- Kubernetes Deployments and Services

\- Blue-green release strategy

\- Two replicas per deployment

\- Kubernetes readiness probes

\- Kubernetes liveness probes

\- Spring Boot Actuator health endpoints

\- Automated traffic switching with PowerShell

\- Deployment validation before Green cutover

\- Fast rollback to Blue

\- Version-specific Docker images generated from the same source code

\- Local Kubernetes environment using Minikube



\---



\## Technology Stack



| Technology | Purpose |

|---|---|

| Java 21 | Application development |

| Spring Boot | REST API |

| Spring Boot Actuator | Health monitoring |

| Maven | Build and dependency management |

| Docker | Application containerization |

| Kubernetes | Container orchestration |

| Minikube | Local Kubernetes cluster |

| kubectl | Kubernetes management |

| PowerShell | Deployment automation |

| Git / GitHub | Version control |



\---



\## REST API



The application contains a small in-memory Task API.



\### Task endpoints



| Method | Endpoint | Description |

|---|---|---|

| GET | `/api/tasks` | Retrieve all tasks |

| POST | `/api/tasks` | Create a task |

| PUT | `/api/tasks/{id}` | Update a task |

| DELETE | `/api/tasks/{id}` | Delete a task |



\### Deployment version



```http

GET /api/version

```



Blue response:



```json

{

&#x20; "environment": "blue",

&#x20; "version": "1.0"

}

```



Green response:



```json

{

&#x20; "environment": "green",

&#x20; "version": "2.0"

}

```



\### Health endpoints



```text

/actuator/health

/actuator/health/liveness

/actuator/health/readiness

```



These endpoints are used by Kubernetes to determine whether application containers are alive and ready to receive traffic.



\---



\## Project Structure



```text

springboot-blue-green-k8s/

│

├── src/

│   └── main/

│       └── java/

│           └── com/rohan/bluegreen/

│

├── k8s/

│   ├── blue-deployment.yaml

│   ├── green-deployment.yaml

│   └── service.yaml

│

├── scripts/

│   ├── switch-to-blue.ps1

│   └── switch-to-green.ps1

│

├── Dockerfile

├── pom.xml

└── README.md

```



\---



\# Running the Project



\## Prerequisites



Install:



\- Java 21

\- Maven

\- Docker Desktop

\- Minikube

\- kubectl

\- PowerShell



Verify:



```powershell

java --version

mvn --version

docker --version

kubectl version --client

minikube version

```



\---



\## 1. Clone the Repository



```powershell

git clone https://github.com/Rohan-HC/springboot-blue-green-k8s.git

cd springboot-blue-green-k8s

```



\---



\## 2. Build the Spring Boot Application



```powershell

mvn clean package

```



This creates:



```text

target/bluegreen-0.0.1-SNAPSHOT.jar

```



\---



\## 3. Build the Blue Docker Image



```powershell

docker build `

&#x20; --build-arg APP\_VERSION=1.0 `

&#x20; --build-arg APP\_ENVIRONMENT=blue `

&#x20; -t bluegreen-app:v1 .

```



\---



\## 4. Build the Green Docker Image



The same application source is used to create the second release:



```powershell

docker build `

&#x20; --build-arg APP\_VERSION=2.0 `

&#x20; --build-arg APP\_ENVIRONMENT=green `

&#x20; -t bluegreen-app:v2 .

```



Verify:



```powershell

docker images

```



You should have:



```text

bluegreen-app:v1

bluegreen-app:v2

```



\---



\# Kubernetes Deployment



\## 5. Start Minikube



```powershell

minikube start --driver=docker

```



Verify:



```powershell

kubectl get nodes

```



\---



\## 6. Load Docker Images into Minikube



```powershell

minikube image load bluegreen-app:v1

minikube image load bluegreen-app:v2

```



Verify:



```powershell

minikube image ls

```



\---



\## 7. Deploy Blue



```powershell

kubectl apply -f .\\k8s\\blue-deployment.yaml

```



\---



\## 8. Deploy Green



```powershell

kubectl apply -f .\\k8s\\green-deployment.yaml

```



\---



\## 9. Create the Kubernetes Service



```powershell

kubectl apply -f .\\k8s\\service.yaml

```



Verify everything:



```powershell

kubectl get deployments

kubectl get pods

kubectl get service bluegreen-service

```



Expected architecture:



```text

blue-deployment

&#x20;├── blue pod

&#x20;└── blue pod



green-deployment

&#x20;├── green pod

&#x20;└── green pod



bluegreen-service

&#x20;       │

&#x20;       └── Active deployment

```



\---



\# Accessing the Application



With Minikube's Docker driver:



```powershell

minikube service bluegreen-service --url

```



Keep this terminal open.



Minikube will return a local URL similar to:



```text

http://127.0.0.1:59770

```



Test:



```powershell

curl.exe http://127.0.0.1:59770/api/version

```



When Blue is active:



```json

{

&#x20; "environment": "blue",

&#x20; "version": "1.0"

}

```



\---



\# Blue → Green Deployment



The Green switching script performs safety checks before modifying production traffic.



Run:



```powershell

.\\scripts\\switch-to-green.ps1

```



The script:



1\. Checks the Green Deployment rollout.

2\. Waits for Green pods to reach the `Ready` condition.

3\. Stops immediately if Green is unhealthy.

4\. Changes the Kubernetes Service selector to Green only after validation.



Conceptually:



```text

Current state



Client

&#x20;  │

&#x20;  ▼

Service

&#x20;  │

&#x20;  ▼

🔵 Blue v1.0





After successful validation



Client

&#x20;  │

&#x20;  ▼

Service

&#x20;  │

&#x20;  ▼

🟢 Green v2.0

```



Verify:



```powershell

kubectl describe service bluegreen-service

```



The selector should contain:



```text

version=green

```



Test the API again:



```powershell

curl.exe http://127.0.0.1:59770/api/version

```



Expected:



```json

{

&#x20; "environment": "green",

&#x20; "version": "2.0"

}

```



\---



\# Rollback



If the Green release needs to be withdrawn, traffic can be moved back to Blue:



```powershell

.\\scripts\\switch-to-blue.ps1

```



The Service selector becomes:



```text

app=bluegreen

version=blue

```



The application therefore returns to Blue without rebuilding or redeploying the Blue application.



\---



\# Failure-Safety Test



A key part of this project is preventing traffic from being routed to an unavailable Green environment.



Scale Green to zero pods:



```powershell

kubectl scale deployment green-deployment --replicas=0

```



Try to switch:



```powershell

.\\scripts\\switch-to-green.ps1

```



The readiness check fails because there are no Green pods available.



The script exits without changing the Service selector:



```text

Green pods are not ready. Traffic will NOT be switched.

```



Verify:



```powershell

kubectl describe service bluegreen-service

```



Traffic should still target:



```text

version=blue

```



Restore Green:



```powershell

kubectl scale deployment green-deployment --replicas=2

```



Then:



```powershell

kubectl wait --for=condition=Ready pod -l app=bluegreen,version=green --timeout=60s

```



\---



\# Kubernetes Health Checks



Each deployment contains both \*\*liveness\*\* and \*\*readiness\*\* probes.



\### Liveness



```yaml

livenessProbe:

&#x20; httpGet:

&#x20;   path: /actuator/health/liveness

&#x20;   port: 8080

```



The liveness probe allows Kubernetes to detect an application that is no longer functioning correctly.



\### Readiness



```yaml

readinessProbe:

&#x20; httpGet:

&#x20;   path: /actuator/health/readiness

&#x20;   port: 8080

```



The readiness probe determines whether a pod should receive traffic.



This is especially important during a blue-green deployment because a release should not receive production traffic until it is ready.



\---



\# What I Learned



This project helped me understand how several DevOps concepts work together rather than treating them as isolated tools.



Key areas explored:



\- building and packaging a Java application with Maven

\- containerizing applications with Docker

\- Docker image versioning

\- Kubernetes Deployments, Pods and Services

\- Kubernetes labels and selectors

\- health checks using liveness and readiness probes

\- traffic routing using Service selectors

\- blue-green deployment strategies

\- deployment rollback

\- release validation

\- PowerShell automation

\- debugging container and Kubernetes configuration issues



One important lesson was that a successful Kubernetes rollout command alone is not always enough to prove that an environment is ready to receive traffic. The deployment automation therefore performs an additional pod-readiness check before switching the Service selector.



\---



\# Future Improvements



Possible extensions include:



\- GitHub Actions CI/CD

\- automated Docker image publishing

\- Kubernetes Ingress

\- Helm charts

\- Prometheus and Grafana monitoring

\- cloud deployment using AKS

\- automated integration tests before cutover



\---



\## Author



\*\*Rohan Hanumanthappa Channagouder\*\*



MSc Advanced Computer Science — University of York



GitHub: \[Rohan-HC](https://github.com/Rohan-HC)

