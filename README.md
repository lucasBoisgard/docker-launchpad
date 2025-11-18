# Docker Microservices Starter Kit

This repository contains a powerful, fully automated setup script to bootstrap a complete development environment for a microservices architecture using Docker Compose.

Run one command, and the script will generate a full project structure and launch all services, including a React frontend, two Node.js backends, a MongoDB database, and an Nginx reverse proxy.

## Features

-   **Fully Automated**: Creates, configures, and launches the entire stack with one script.
-   **React Frontend**: A complete React + TypeScript application created with Vite.
-   **Node.js API**: A backend API service using Express and TypeScript.
-   **Node.js Auth Service**: A second backend service for handling authentication logic.
-   **Nginx Reverse Proxy**: A single entry point (`localhost`) that routes traffic to the correct service.
-   **MongoDB Database**: A persistent MongoDB service for data storage.
-   **Hot-Reloading**: Change your code in any of the frontend or backend services, and see the changes instantly.

## Prerequisites

Before you begin, ensure you have the following installed on your system:
-   [Docker Engine](https://docs.docker.com/engine/install/)
-   [Docker Compose](https://docs.docker.com/compose/install/)
-   [Node.js and npm](https://nodejs.org/en/download/) (for the setup script to run `npx` and `npm install`)

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
    The script will first ask you for a project name. After you provide it, it will create all the files and then pause for you to answer two questions from the `create-vite` tool.

### Answering the `create-vite` Prompts

During the setup, it is important to answer **No** to both interactive questions, as the script handles these steps automatically.

1.  When asked `◇ Use rolldown-vite (Experimental)?`:
    -   Select **No**.

2.  When asked `◇ Install with npm and start now?`:
    -   Select **No**.

After you answer, the script will automatically continue, install the necessary dependencies, and launch the Docker containers.

## Accessing Your Application

Once the script finishes, your fully containerized development environment is running.

-   **Access the frontend**: [http://localhost](http://localhost)
-   **Test the API endpoint**: [http://localhost/api/data](http://localhost/api/data)

## Development Workflow

-   **Frontend**: Modify any file inside the `[your-project-name]/app/src` directory. The browser will automatically refresh.
-   **Backend**: Modify any file inside the `[your-project-name]/api/src` or `[your-project-name]/auth-service/src` directories. `nodemon` will automatically restart the corresponding Node.js server.

## Stopping the Environment

To stop all running containers, navigate into your project's root directory (`[your-project-name]`) and run:
```bash
docker compose down
```

To perform a **full cleanup**, including the database volume (all data will be lost):
```bash
docker compose down -v
```

## License

This project is licensed under the MIT License.