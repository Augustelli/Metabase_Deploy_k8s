#!/bin/bash

cd /home/ubuntu

sudo mkdir deploy

sudo touch deploy/ingress.yaml
sudo touch deploy/metabase.secret.yaml
sudo touch deploy/metabase-app.yaml
sudo touch deploy/mysql.secret.yaml
sudo touch deploy/mysql.yaml


sudo tee /home/ubuntu/deploy/ingress.yaml << EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: metabase-ingress
spec:
  rules:
  - host: a.mancuso.my.kube.um.edu.ar
    http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: metabase-svc
            port:
              number: 80
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: metabase-svc
            port:
              number: 443
EOF

sudo tee /home/ubuntu/deploy/metabase.secret.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  name: metabase-secret
type: Opaque
data:
  MB_DB_USER: bWJfdXNlcg==
  MB_DB_PASS: YWRtaW4xMjM0NTY=
  ADMIN_EMAIL: YWRtaW5AZXhhbXBsZS5jb20=
  ADMIN_PASSWORD: bXE0SDk1KG9Hdm4lNXhIbSQkeTkzVChMSno5TyFs
  METABASE_PASSWORD: bXE0SDk1KG9Hdm4lNXhIbSQkeTkzVChMSno5TyFs
EOF

sudo tee /home/ubuntu/deploy/metabase-app.yaml << EOF
# ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: metabase-config
data:
  MB_DB_TYPE: mysql
  MB_DB_HOST: mysql
  MB_DB_PORT: "3306"
  MB_DB_DBNAME: metabase
---
# Service

apiVersion: v1
kind: Service
metadata:
  name: metabase-svc
spec:
  selector:
    app: metabase
  ports:
    - protocol: TCP
      port: 80
      targetPort: 3000
---
# Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: metabase
spec:
  replicas: 1
  selector:
    matchLabels:
      app: metabase
  template:
    metadata:
      labels:
        app: metabase
    spec:
      initContainers:
        - name: wait-for-mysql
          image: busybox
          command: ['sh','-c','while ! nc -z mysql 3306; do echo waiting for mysql; sleep 2; done;',]
      containers:
        - name: metabase
          image: metabase/metabase:latest
          ports:
            - containerPort: 3000
          livenessProbe:
            httpGet:
              path: /api/health
              port: 3000
            initialDelaySeconds: 120
            periodSeconds: 10
            failureThreshold: 3
          readinessProbe:
            httpGet:
              path: /api/health
              port: 3000
            initialDelaySeconds: 60
            periodSeconds: 10
            failureThreshold: 3
          envFrom:
            - configMapRef:
                name: metabase-config
            - secretRef:
                name: metabase-secret
          env:
            - name: MB_ADMIN_EMAIL
              valueFrom:
                secretKeyRef:
                  name: metabase-secret
                  key: ADMIN_EMAIL
            - name: MB_ADMIN_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: metabase-secret
                  key: ADMIN_PASSWORD




---
EOF
sudo tee /home/ubuntu/deploy/mysql.secret.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret
type: Opaque
data:
  MYSQL_ROOT_PASSWORD: cm9vdA==
  MYSQL_DATABASE: bWV0YWJhc2U
  MYSQL_USER: cm9vdA==
  MYSQL_PASSWORD: cm9vdA==
EOF

sudo tee /home/ubuntu/deploy/mysql.yaml << EOF
# StateFull Set

apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  serviceName: "mysql"
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
        - name: mysql
          image: mysql:8.4
          ports:
            - containerPort: 3306
          args:
            - --mysql-native-password=ON
          readinessProbe:
            exec:
              command: ['mysqladmin', 'ping', '-h', 'localhost']
            initialDelaySeconds: 30
            periodSeconds: 10
            timeoutSeconds: 5
          env:
            - name: MYSQL_ROOT_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mysql-secret
                  key: MYSQL_ROOT_PASSWORD
            - name: MYSQL_DATABASE
              valueFrom:
                secretKeyRef:
                  name: mysql-secret
                  key: MYSQL_DATABASE
            - name: MYSQL_USER
              valueFrom:
                secretKeyRef:
                  name: mysql-secret
                  key: MYSQL_USER
            - name: MYSQL_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mysql-secret
                  key: MYSQL_PASSWORD
          volumeMounts:
            - name: mysql-persistent-storage
              mountPath: /var/lib/mysql
  volumeClaimTemplates:
    - metadata:
        name: mysql-persistent-storage
      spec:
        accessModes: [ "ReadWriteOnce" ]
        resources:
          requests:
            storage: 1Gi
---

# Service
apiVersion: v1
kind: Service
metadata:
  name: mysql
spec:
  selector:
    app: mysql
  ports:
    - port: 3306


---

EOF




