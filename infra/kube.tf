resource "kubectl_manifest" "wiz-tech-task-namespace" {
  yaml_body = <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: wiz
EOF
}

resource "kubectl_manifest" "wiz-tech-task-mongoexpress-deployment" {
  override_namespace = "wiz"
  yaml_body          = <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mongo-express-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mongo-express
  template:
    metadata:
      labels:
        app: mongo-express
    spec:
      containers:
      - name: mongo-express
        image: mongo-express

        env:
        - name: ME_CONFIG_MONGODB_URL
          value: "mongodb://${aws_instance.wiz-technical-task-mongodb-server.private_ip}:27017/dev?ssl=false"
        ports:
        - name: mongo-express
          containerPort: 8081
EOF
}

resource "kubectl_manifest" "wiz-tech-task-mongoexpress-service" {
  override_namespace = "wiz"
  yaml_body          = <<EOF
apiVersion: v1
kind: Service
metadata:
  name: mongo-express
spec:
  selector:
    app: mongo-express
  ports:
    - port: 8081
      targetPort: 8081
  type: LoadBalancer
EOF
}

resource "kubectl_manifest" "wiz-tech-task-tasksapp-deployment" {
  override_namespace = "wiz"
  yaml_body          = <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tasksapp
  labels:
    app: tasksapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: tasksapp
  template:
    metadata:
      labels:
        app: tasksapp
    spec:
      containers:
        - name: tasksapp
          image: public.ecr.aws/v4o5r6v9/tasksapp-python:4
          ports:
            - containerPort: 5000
          imagePullPolicy: Always
          env:
          - name: MONGO_URI
            value: "mongodb://${aws_instance.wiz-technical-task-mongodb-server.private_ip}:27017/dev"
          - name: JSONIFY_PRETTYPRINT_REGULAR
            value: "True"
EOF
}

resource "kubectl_manifest" "wiz-tech-task-tasksapp-service" {
  override_namespace = "wiz"
  yaml_body          = <<EOF
apiVersion: v1
kind: Service
metadata:
  name: tasksapp-service
spec:
  selector:
    app: tasksapp
  ports:
    - port: 80
      targetPort: 5000
  type: LoadBalancer
EOF
}

resource "kubectl_manifest" "wiz-tech-task-permissive-rbac" {
  override_namespace = "wiz"
  yaml_body          = <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  creationTimestamp: null
  name: permissive-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: admin
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: kubelet
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:serviceaccounts
EOF
}