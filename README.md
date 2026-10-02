\# Spring Boot Blue-Green Deployment on Kubernetes



!\[Java](https://img.shields.io/badge/Java-21-orange)

!\[Spring Boot](https://img.shields.io/badge/Spring%20Boot-4.1.1-6DB33F)

!\[Docker](https://img.shields.io/badge/Docker-Containerized-2496ED)

!\[Kubernetes](https://img.shields.io/badge/Kubernetes-Blue--Green-326CE5)

!\[Minikube](https://img.shields.io/badge/Minikube-Local%20Cluster-blue)



A hands-on DevOps project demonstrating a \*\*Blue-Green deployment strategy for a containerized Spring Boot REST API on Kubernetes\*\*.



The application is packaged as two independently versioned Docker images and deployed as parallel Kubernetes environments:



\- 🔵 \*\*Blue — v1.0\*\*

\- 🟢 \*\*Green — v2.0\*\*



Both releases can run simultaneously. A Kubernetes Service controls which deployment receives traffic by selecting pods based on their `version` label.



Before switching traffic to Green, a PowerShell deployment script validates the Green rollout and verifies that Green pods are actually ready.



\---



\## Project Goals



This project was built to practise how application development, containerization and Kubernetes deployment concepts work together in a realistic release workflow.



It demonstrates:



\- containerizing a Spring Boot application with Docker

\- running multiple application versions simultaneously

\- Kubernetes Deployments, Pods and Services

\- labels and selectors for traffic routing

\- liveness and readiness health probes

\- Blue-Green release switching

\- deployment validation before cutover

\- rollback to a previous release

\- PowerShell deployment automation

\- failure-safe traffic switching



\---



\## Architecture



```mermaid

flowchart LR

&#x20;   Client\[Client] --> Service\[Kubernetes Service]



&#x20;   Service -->|version=blue| Blue\[Blue Deployment<br/>v1.0]

&#x20;   Service -.->|version=green| Green\[Green Deployment<br/>v2.0]



&#x20;   Blue --> B1\[Blue Pod 1]

&#x20;   Blue --> B2\[Blue Pod 2]



&#x20;   Green --> G1\[Green Pod 1]

&#x20;   Green --> G2\[Green Pod 2]

```



Both Kubernetes Deployments contain two replicas.



The Service initially uses:



```yaml

selector:

&#x20; app: bluegreen

&#x20; version: blue

```



Therefore traffic flows to Blue pods.



After the Green deployment passes validation, the selector becomes:



```yaml

selector:

&#x20; app: bluegreen

&#x20; version: green

```



The application does not need to be rebuilt during the traffic switch.



\---



\## Blue-Green Deployment Flow



\### 1. Blue is live



```text

Client

&#x20;  │

&#x20;  ▼

Kubernetes Service

&#x20;  │

&#x20;  │ version=blue

&#x20;  ▼

Blue Deployment

&#x20;  ├── Blue Pod 1

&#x20;  └── Blue Pod 2

```



The version endpoint returns:



```json

{

&#x20; "environment": "blue",

&#x20; "version": "1.0"

}

```



\### 2. Green is deployed alongside Blue



```text

&#x20;                    ┌── Blue Pod 1

Blue Deployment ─────┤

&#x20;                    └── Blue Pod 2



&#x20;                    ┌── Green Pod 1

Green Deployment ────┤

&#x20;                    └── Green Pod 2

```



Blue continues receiving traffic while Green is prepared and checked.



\### 3. Green is validated



Before cutover, the deployment script:



1\. checks the Green Deployment rollout

2\. waits for Green pods to reach the `Ready` condition

3\. stops if Green is unavailable

4\. changes the Service selector only after validation succeeds



\### 4. Traffic switches to Green



```text

Client

&#x20;  │

&#x20;  ▼

Kubernetes Service

&#x20;  │

&#x20;  │ version=green

&#x20;  ▼

Green Deployment

&#x20;  ├── Green Pod 1

&#x20;  └── Green Pod 2

```



The API then returns:



```json

{

&#x20; "environment": "green",

&#x20; "version": "2.0"

}

```



Blue remains available for rollback.



\---



\## Technology Stack



| Technology | Purpose |

|---|---|

| Java 21 | Application development |

| Spring Boot | REST API |

| Spring Boot Actuator | Application health endpoints |

| Maven | Build and dependency management |

| Docker | Application containerization |

| Kubernetes | Container orchestration |

| Minikube | Local Kubernetes environment |

| kubectl | Kubernetes management |

| PowerShell | Deployment automation |

| Git | Version control |

| GitHub | Source-code hosting |



\---



\## Project Structure



```text

springboot-blue-green-k8s/

│

├── src/

│   └── main/

│       ├── java/

│       │   └── com/rohan/bluegreen/

│       │       ├── controller/

│       │       │   ├── TaskController.java

│       │       │   └── VersionController.java

│       │       └── model/

│       │           └── Task.java

│       │

│       └── resources/

│           └── application.properties

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



\## REST API



The Spring Boot application contains a small in-memory Task API together with a deployment-version endpoint.



\### Task endpoints



| Method | Endpoint | Description |

|---|---|---|

| `GET` | `/api/tasks` | Retrieve all tasks |

| `POST` | `/api/tasks` | Create a task |

| `PUT` | `/api/tasks/{id}` | Update a task |

| `DELETE` | `/api/tasks/{id}` | Delete a task |



\### Example task



```json

{

&#x20; "title": "Test Kubernetes deployment",

&#x20; "completed": false

}

```



> Task data is stored in memory for this project and is therefore reset when the application instance restarts.



\---



\## Version Endpoint



```http

GET /api/version

```



The response identifies the Docker image/release currently receiving traffic.



\### Blue



```json

{

&#x20; "environment": "blue",

&#x20; "version": "1.0"

}

```



\### Green



```json

{

&#x20; "environment": "green",

&#x20; "version": "2.0"

}

```



The version and environment are configurable when the Docker image is built, allowing both releases to be created from the same source code.



\---



\## Health Endpoints



Spring Boot Actuator provides the endpoints used by the Kubernetes probes:



```text

/actuator/health

/actuator/health/liveness

/actuator/health/readiness

```



The Kubernetes manifests use:



\### Liveness probe



```yaml

livenessProbe:

&#x20; httpGet:

&#x20;   path: /actuator/health/liveness

&#x20;   port: 8080

&#x20; initialDelaySeconds: 10

&#x20; periodSeconds: 10

```



\### Readiness probe



```yaml

readinessProbe:

&#x20; httpGet:

&#x20;   path: /actuator/health/readiness

&#x20;   port: 8080

&#x20; initialDelaySeconds: 5

&#x20; periodSeconds: 5

```



The liveness probe checks whether the application remains operational.



The readiness probe determines whether a pod is ready to receive traffic.



\---



\# Running Locally



\## Prerequisites



Install:



\- Java 21

\- Maven

\- Docker Desktop

\- Minikube

\- kubectl

\- PowerShell

\- Git



Verify the main tools:



```powershell

java --version

mvn --version

docker --version

kubectl version --client

minikube version

git --version

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



The packaged application is created at:



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



The same source code is used to build the Green release:



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



You should see:



```text

bluegreen-app   v1

bluegreen-app   v2

```



\---



\# Deploying to Minikube



\## 5. Start the Kubernetes Cluster



```powershell

minikube start --driver=docker

```



Verify the node:



```powershell

kubectl get nodes

```



The Minikube node should report:



```text

Ready

```



\---



\## 6. Load the Images into Minikube



The Kubernetes manifests use local Docker images with:



```yaml

imagePullPolicy: Never

```



Load both images into Minikube:



```powershell

minikube image load bluegreen-app:v1

minikube image load bluegreen-app:v2

```



Verify:



```powershell

minikube image ls

```



\---



\## 7. Deploy Blue and Green



Apply the Blue deployment:



```powershell

kubectl apply -f .\\k8s\\blue-deployment.yaml

```



Apply Green:



```powershell

kubectl apply -f .\\k8s\\green-deployment.yaml

```



Create the Service:



```powershell

kubectl apply -f .\\k8s\\service.yaml

```



Verify:



```powershell

kubectl get deployments

kubectl get pods

kubectl get services

```



The expected deployment state is:



```text

blue-deployment     2/2

green-deployment    2/2

```



\---



\## 8. Access the Application



The Kubernetes Service uses `NodePort`.



With Minikube's Docker driver:



```powershell

minikube service bluegreen-service --url

```



Keep that terminal running.



Minikube returns a URL similar to:



```text

http://127.0.0.1:59770

```



Use the URL returned by your own Minikube session.



Check which release is active:



```powershell

curl.exe http://127.0.0.1:59770/api/version

```



Initially the Service targets Blue:



```json

{

&#x20; "environment": "blue",

&#x20; "version": "1.0"

}

```



\---



\# Switching Blue → Green



Run:



```powershell

.\\scripts\\switch-to-green.ps1

```



The script first runs:



```text

kubectl rollout status deployment/green-deployment

```



It then checks that Green pods are actually Ready.



Only after those checks succeed does it execute the equivalent of:



```text

kubectl set selector service bluegreen-service app=bluegreen,version=green

```



Verify the active selector:



```powershell

kubectl describe service bluegreen-service

```



The selector should now contain:



```text

app=bluegreen

version=green

```



Check the API again using your Minikube URL:



```powershell

curl.exe http://127.0.0.1:59770/api/version

```



Expected response:



```json

{

&#x20; "environment": "green",

&#x20; "version": "2.0"

}

```



\---



\# Failure-Safe Cutover



The Green switch script is designed to avoid routing traffic to an unavailable Green environment.



To test this behaviour, first make sure Blue is active:



```powershell

.\\scripts\\switch-to-blue.ps1

```



Then deliberately remove all Green replicas:



```powershell

kubectl scale deployment green-deployment --replicas=0

```



Attempt the Green cutover:



```powershell

.\\scripts\\switch-to-green.ps1

```



Because no Green pods are available, the readiness check fails and the script exits:



```text

Green pods are not ready. Traffic will NOT be switched.

```



The Service remains pointed at Blue.



Verify:



```powershell

kubectl describe service bluegreen-service

```



The selector should still contain:



```text

version=blue

```



Restore the Green environment:



```powershell

kubectl scale deployment green-deployment --replicas=2

```



Wait for it to become ready:



```powershell

kubectl wait `

&#x20; --for=condition=Ready `

&#x20; pod `

&#x20; -l app=bluegreen,version=green `

&#x20; --timeout=60s

```



\---



\# Rollback



Because Blue remains deployed while Green is active, traffic can be moved back without rebuilding Blue.



Run:



```powershell

.\\scripts\\switch-to-blue.ps1

```



The script updates the Service selector to:



```text

app=bluegreen

version=blue

```



Verify:



```powershell

kubectl describe service bluegreen-service

```



Then call:



```powershell

curl.exe http://127.0.0.1:59770/api/version

```



The response returns to:



```json

{

&#x20; "environment": "blue",

&#x20; "version": "1.0"

}

```



\---



\## Why the Additional Readiness Check Matters



A useful failure case discovered while building this project was that:



```text

kubectl rollout status

```



can report a successful rollout even when a Deployment has intentionally been scaled to zero replicas.



For that reason, the Green cutover script performs an additional check:



```powershell

kubectl wait `

&#x20; --for=condition=Ready `

&#x20; pod `

&#x20; -l app=bluegreen,version=green `

&#x20; --timeout=60s

```



If there are no matching Ready Green pods, the command fails and the Service selector is left unchanged.



This provides an extra safety check before traffic is redirected.



\---



\## Docker Version Configuration



Both releases are produced from the same Java source.



The Dockerfile accepts:



```dockerfile

ARG APP\_VERSION=1.0

ARG APP\_ENVIRONMENT=blue



ENV APP\_VERSION=${APP\_VERSION}

ENV APP\_ENVIRONMENT=${APP\_ENVIRONMENT}

```



Spring Boot reads those values through:



```java

@Value("${app.version:1.0}")

private String version;



@Value("${app.environment:blue}")

private String environment;

```



This makes it possible to build:



```text

bluegreen-app:v1 → Blue  / 1.0

bluegreen-app:v2 → Green / 2.0

```



without manually modifying the Java source between builds.



\---



\## Kubernetes Labels and Traffic Routing



Blue pods use:



```yaml

labels:

&#x20; app: bluegreen

&#x20; version: blue

```



Green pods use:



```yaml

labels:

&#x20; app: bluegreen

&#x20; version: green

```



The Service always selects:



```text

app=bluegreen

```



and changes only the `version` selector.



This is the mechanism used to perform the Blue-Green traffic switch.



\---



\## Key Learning Outcomes



This project provided practical experience with:



\- Java application packaging using Maven

\- Docker image creation and tagging

\- container environment configuration

\- Kubernetes Deployments and Pods

\- Kubernetes Services

\- labels and selectors

\- liveness and readiness probes

\- Blue-Green deployment concepts

\- release validation

\- traffic switching

\- rollback strategies

\- PowerShell automation

\- debugging Docker and Kubernetes issues

\- designing deployment safeguards



\---



\## Current Scope



This project intentionally focuses on the core Blue-Green deployment workflow using a local Kubernetes environment.



Current implementation:



```text

Spring Boot

&#x20;    │

&#x20;    ▼

Docker Images

&#x20;    │

&#x20;    ▼

Minikube / Kubernetes

&#x20;    │

&#x20;    ├── Blue Deployment

&#x20;    ├── Green Deployment

&#x20;    │

&#x20;    ▼

Kubernetes Service

```



Cloud deployment is not required to run or demonstrate the project.



\---



\## Future Improvements



Potential extensions include:



\- GitHub Actions CI/CD pipeline

\- automated Docker image builds

\- container registry integration

\- Helm packaging

\- Kubernetes Ingress

\- Prometheus metrics

\- Grafana dashboards

\- automated API tests before cutover

\- automatic rollback on failed validation

\- deployment to a managed Kubernetes service such as AKS



\---



\## Author



\*\*Rohan Hanumanthappa Channagouder\*\*



GitHub: \[Rohan-HC](https://github.com/Rohan-HC)

