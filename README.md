# Docker Microservices Starter Kit

This repository contains a powerful setup script to instantly bootstrap a complete development environment for a microservices architecture using Docker Compose.

The script generates a full project structure with a React frontend, two Node.js backend services, a MongoDB database, and an Nginx reverse proxy configured for seamless communication.

## Features

-   **React Frontend**: A complete React + TypeScript application created with Vite.
-   **Node.js API**: A backend API service using Express and TypeScript.
-   **Node.js Auth Service**: A second backend service for handling authentication logic.
-   **Nginx Reverse Proxy**: A single entry point (`localhost`) that routes traffic to the correct service.
-   **MongoDB Database**: A persistent MongoDB service for data storage.
-   **Docker Compose**: All services are orchestrated with a single `docker-compose.yml` file.
-   **Hot-Reloading**: Change your code in any of the frontend or backend services, and see the changes instantly without restarting the entire stack.

## Prerequisites

Before you begin, ensure you have the following installed on your system:
-   [Docker Engine](https://docs.docker.com/engine/install/)
-   [Docker Compose](https://docs.docker.com/compose/install/) (usually included with Docker Desktop)

## How to Use

1.  **Clone the Repository**
    ```bash
    git clone <your-repository-url>
    cd <repository-folder>
    ```

2.  **Make the Script Executable**
    ```bash
    chmod +x setup.sh
    ```

3.  **Run the Setup Script**
    ```bash
    ./setup.sh
    ```
    The script will first ask you for a project name. This will be the name of the root folder containing all the services.

    ```
    --- Project Setup ---
    Please enter the directory name for your project (e.g., my-awesome-project): my-app
    ```

### Answering the `create-vite` Prompts

During the setup, the `create-vite` tool will ask two interactive questions. It is important to answer **No** to both, as the script handles these steps later.

1.  When asked `◇ Use rolldown-vite (Experimental)?`:
    -   Select **No**.

2.  When asked `◇ Install with npm and start now?`:
    -   Select **No**.

The script will then continue and configure the rest of the project automatically.

## Post-Setup Instructions

After the script finishes, it will print a list of final commands. These steps are crucial to get the environment running.

1.  **Navigate into the Project Directory**
    This is the most important first step. Replace `my-app` with the project name you chose.
    ```bash
    cd my-app
    ```

2.  **Install Frontend Dependencies**
    This command creates the `node_modules` folder on your host machine, which is necessary for the Docker volume mapping and hot-reloading to work correctly.
    ```bash
    cd app && npm install && cd ..
    ```

3.  **Launch the Docker Environment**
    This command will build the Docker images for each service and start all containers in the background.
    ```bash
    docker compose up --build -d
    ```

4.  **Access Your Application**
    Once all containers are running, you can access your application in your web browser at:
    [http://localhost](http://localhost)

## Services Overview

| Service        | Directory        | Internal Port | URL via Nginx             | Description                               |
| -------------- | ---------------- | ------------- | ------------------------- | ----------------------------------------- |
| **Frontend**   | `./app`          | `5173`        | `http://localhost/`       | The React + Vite user interface.          |
| **API**        | `./api`          | `3000`        | `http://localhost/api/`   | The main Node.js + Express backend API.   |
| **Auth**       | `./auth-service` | `4000`        | `http://localhost/auth/`  | A separate Node.js authentication service.|
| **Nginx**      | `./nginx`        | `80`          | `http://localhost/`       | The reverse proxy and single entry point. |
| **Database**   | (Docker Volume)  | `27017`       | (Internal access only)    | The MongoDB database instance.            |

## Development Workflow

-   **Frontend**: Modify any file inside the `app/src` directory. The browser will automatically refresh with the changes.
-   **Backend**: Modify any file inside the `api/src` or `auth-service/src` directories. `nodemon` will automatically restart the corresponding Node.js server.

## Stopping the Environment

-   To **stop** all running containers without deleting them:
    ```bash
    docker compose stop
    ```
-   To **stop and remove** all containers and networks:
    ```bash
    docker compose down
    ```
-   To perform a **full cleanup**, including the database volume (all data will be lost):
    ```bash
    docker compose down -v
    ```

## License

This project is licensed under the MIT License.
