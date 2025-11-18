#!/bin/bash

# This script automates the creation AND launch of a complete microservices
# architecture for a development environment.
# It will exit immediately if any command fails.
set -e

# --- Step 1: Prompt for the project name ---
echo "--- Project Setup ---"
read -p "Please enter the directory name for your project (e.g., my-awesome-project): " PROJECT_NAME

# Use a default name if the user enters nothing
if [ -z "$PROJECT_NAME" ]; then
  PROJECT_NAME="docker-microservices-starter"
  echo "No name entered. Using default name: '$PROJECT_NAME'"
fi

# Check if the directory already exists
if [ -d "$PROJECT_NAME" ]; then
  echo -e "\nWarning: Directory '$PROJECT_NAME' already exists. The script will stop to avoid overwriting data."
  exit 1
fi

echo -e "The project will be created in the directory: '$PROJECT_NAME'\n"


# --- Step 2: Create the root project directory ---
echo "▶ Creating root directory '$PROJECT_NAME'..."
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"
echo -e "✔ Directory '$PROJECT_NAME' created.\n"

# --- Step 3: Set up the Frontend Service ('app') ---
echo "▶ Setting up Frontend service ('app')..."
echo "  - Creating a complete React/Vite project via npx (requires user input)..."
# Create a full React application with all necessary source files
npx create-vite@latest app --template react-ts

echo "  - Adding network configuration for Docker..."
# Modify package.json to make Vite accessible from outside the container
sed -i 's/"dev": "vite"/"dev": "vite --host 0.0.0.0 --port 5173"/' app/package.json

echo "  - Creating Dockerfile for the frontend..."
cat <<'EOF' > app/Dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
# Dependencies will be installed by the user on the host or by the build process
COPY . .
EXPOSE 5173
CMD ["npm", "run", "dev"]
EOF
echo -e "✔ Service 'app' configured.\n"

# --- Step 4: Set up the API Service ('api') ---
echo "▶ Setting up API service ('api')..."
mkdir -p api/src
cat <<'EOF' > api/package.json
{
  "name": "api", "version": "1.0.0", "description": "API Backend Service", "main": "dist/index.js",
  "scripts": { "build": "tsc", "start": "node dist/index.js", "dev": "nodemon" },
  "dependencies": { "express": "^4.19.2" },
  "devDependencies": { "@types/express": "^4.17.21", "@types/node": "^20.12.7", "nodemon": "^3.1.0", "ts-node": "^10.9.2", "typescript": "^5.4.5" }
}
EOF
echo "  - File 'api/package.json' created."
cat <<'EOF' > api/tsconfig.json
{
  "compilerOptions": { "target": "es2016", "module": "commonjs", "rootDir": "./src", "outDir": "./dist", "esModuleInterop": true, "forceConsistentCasingInFileNames": true, "strict": true, "skipLibCheck": true },
  "include": ["src/**/*.ts"], "exclude": ["node_modules"]
}
EOF
echo "  - File 'api/tsconfig.json' created."
cat <<'EOF' > api/nodemon.json
{ "watch": ["src"], "ext": "ts,json", "ignore": ["src/**/*.spec.ts"], "exec": "ts-node ./src/index.ts" }
EOF
echo "  - File 'api/nodemon.json' created."
cat <<'EOF' > api/src/index.ts
import express, { Request, Response } from 'express';
const app = express(); const port = 3000;
app.use(express.json());
app.get('/', (req: Request, res: Response) => res.status(200).send('Welcome to the API Service!'));
app.get('/data', (req: Request, res: Response) => res.status(200).json({ message: 'Data from API', timestamp: new Date() }));
app.listen(port, () => console.log(`API service running at http://localhost:${port}`));
EOF
echo "  - File 'api/src/index.ts' created."
cat <<'EOF' > api/Dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "run", "dev"]
EOF
echo -e "  - File 'api/Dockerfile' created."
echo -e "✔ Service 'api' configured.\n"

# --- Step 5: Set up the Authentication Service ('auth-service') ---
echo "▶ Setting up Authentication service ('auth-service')..."
mkdir -p auth-service/src
cat <<'EOF' > auth-service/package.json
{
  "name": "auth-service", "version": "1.0.0", "description": "Authentication Service", "main": "dist/index.js",
  "scripts": { "build": "tsc", "start": "node dist/index.js", "dev": "nodemon" },
  "dependencies": { "express": "^4.19.2" },
  "devDependencies": { "@types/express": "^4.17.21", "@types/node": "^20.12.7", "nodemon": "^3.1.0", "ts-node": "^10.9.2", "typescript": "^5.4.5" }
}
EOF
echo "  - File 'auth-service/package.json' created."
cat <<'EOF' > auth-service/tsconfig.json
{
  "compilerOptions": { "target": "es2016", "module": "commonjs", "rootDir": "./src", "outDir": "./dist", "esModuleInterop": true, "forceConsistentCasingInFileNames": true, "strict": true, "skipLibCheck": true },
  "include": ["src/**/*.ts"], "exclude": ["node_modules"]
}
EOF
echo "  - File 'auth-service/tsconfig.json' created."
cat <<'EOF' > api/nodemon.json
{ "watch": ["src"], "ext": "ts,json", "ignore": ["src/**/*.spec.ts"], "exec": "ts-node ./src/index.ts" }
EOF
echo "  - File 'auth-service/nodemon.json' created."
cat <<'EOF' > auth-service/src/index.ts
import express, { Request, Response } from 'express';
const app = express(); const port = 4000;
app.use(express.json());
app.get('/', (req: Request, res: Response) => res.status(200).send('Welcome to the Auth Service!'));
app.post('/login', (req: Request, res: Response) => {
  const { username, password } = req.body;
  if (username === 'admin' && password === 'password123') {
    return res.status(200).json({ message: 'Login successful!', token: 'fake-jwt-token' });
  }
  return res.status(401).json({ message: 'Invalid credentials' });
});
app.listen(port, () => console.log(`Auth service running at http://localhost:${port}`));
EOF
echo "  - File 'auth-service/src/index.ts' created."
cat <<'EOF' > auth-service/Dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 4000
CMD ["npm", "run", "dev"]
EOF
echo -e "  - File 'auth-service/Dockerfile' created."
echo -e "✔ Service 'auth-service' configured.\n"

# --- Step 6: Set up the Nginx Reverse Proxy (FIXED VERSION) ---
echo "▶ Setting up Nginx Reverse Proxy ('nginx')..."
mkdir -p nginx
cat <<'EOF' > nginx/app.conf
upstream frontend { server app:5173; }
upstream api_backend { server api:3000; }
upstream auth_backend { server auth-service:4000; }

server {
    listen 80;
    server_name localhost;

    location / {
        proxy_pass http://frontend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
    location /api/ {
        rewrite /api/(.*) /$1 break;
        proxy_pass http://api_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    location /auth/ {
        rewrite /auth/(.*) /$1 break;
        proxy_pass http://auth_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF
echo "  - File 'nginx/app.conf' created."
cat <<'EOF' > nginx/Dockerfile
FROM nginx:1.25-alpine
COPY app.conf /etc/nginx/conf.d/default.conf
EOF
echo -e "  - File 'nginx/Dockerfile' (fixed) created."
echo -e "✔ Service 'nginx' configured.\n"

# --- Step 7: Create the Docker Compose file ---
echo "▶ Creating 'docker-compose.yml' file..."
cat <<'EOF' > docker-compose.yml
# This attribute is obsolete, but kept for compatibility with older versions.
version: '3.8'

services:
  nginx:
    build: ./nginx
    container_name: nginx_proxy
    ports: ["80:80"]
    depends_on: [app, api, auth-service]
    networks: [app-network]
  app:
    build: { context: ./app, dockerfile: Dockerfile }
    container_name: react_app
    volumes: ["./app:/app", "/app/node_modules"]
    networks: [app-network]
  api:
    build: ./api
    container_name: api_service
    volumes: ["./api:/app", "/app/node_modules"]
    depends_on: [db]
    environment: ["MONGO_URI=mongodb://db:27017/my_database", "NODE_ENV=development"]
    networks: [app-network]
  auth-service:
    build: ./auth-service
    container_name: auth_service
    volumes: ["./auth-service:/app", "/app/node_modules"]
    depends_on: [db]
    environment: ["MONGO_URI=mongodb://db:27017/my_database", "NODE_ENV=development"]
    networks: [app-network]
  db:
    image: mongo:6.0
    container_name: mongodb
    volumes: [db_data:/data/db]
    networks: [app-network]
networks:
  app-network:
    driver: bridge
volumes:
  db_data:
EOF
echo -e "✔ File 'docker-compose.yml' created.\n"

# --- Step 8: Finalizing and Launching Environment (AUTOMATED) ---
echo "====================================================="
echo "      PROJECT FILES CREATED. NOW LAUNCHING..."
echo "====================================================="
echo ""

echo "▶ (IMPORTANT) Installing frontend dependencies on host..."
echo "(This is required for the Docker volume and hot-reloading to work correctly)"
cd app && npm install && cd ..
echo "✔ Frontend dependencies installed."
echo ""

echo "▶ Launching Docker environment in the background..."
echo "(This may take a minute for the first build)"
docker compose up --build -d
echo ""

# --- Final Instructions ---
echo "====================================================="
echo "         ENVIRONMENT IS UP AND RUNNING!"
echo "====================================================="
echo ""
echo "✔ Your full-stack application is now accessible at: http://localhost (or your server's IP)"
echo ""
echo "To stop the environment, navigate to the '$PROJECT_NAME' directory and run:"
echo "  docker compose down"
echo ""