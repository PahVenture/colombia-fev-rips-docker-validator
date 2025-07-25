#!/bin/bash
set -e

# Deploy FEV RIPS to Kubernetes using Helm
# Usage: ./deploy.sh [environment] [release-name]
# Environment: development|production (default: development)
# Release name: custom release name (default: fevrips)

ENVIRONMENT=${1:-development}
RELEASE_NAME=${2:-fevrips}
NAMESPACE=${RELEASE_NAME}

echo "🚀 Deploying FEV RIPS to Kubernetes"
echo "Environment: $ENVIRONMENT"
echo "Release Name: $RELEASE_NAME"
echo "Namespace: $NAMESPACE"

# Create namespace if it doesn't exist
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Check if this is a production deployment
if [ "$ENVIRONMENT" = "production" ]; then
    echo "⚠️  Production deployment detected"
    echo "Creating database credentials secret..."
    
    # Prompt for database password if not set
    if [ -z "$DB_PASSWORD" ]; then
        echo -n "Enter database password for production: "
        read -s DB_PASSWORD
        echo
    fi
    
    # Create database secret
    kubectl create secret generic ${RELEASE_NAME}-db-credentials \
        --from-literal=sa-password="$DB_PASSWORD" \
        -n $NAMESPACE \
        --dry-run=client -o yaml | kubectl apply -f -
    
    # Deploy with production values
    helm upgrade --install $RELEASE_NAME helm/fevrips \
        -f helm/fevrips/values-production.yaml \
        --set database.auth.existingSecret=${RELEASE_NAME}-db-credentials \
        --namespace $NAMESPACE \
        --wait
        
else
    echo "📚 Development deployment"
    
    # Deploy with development values
    helm upgrade --install $RELEASE_NAME helm/fevrips \
        -f helm/fevrips/values-development.yaml \
        --namespace $NAMESPACE \
        --wait
fi

echo "✅ Deployment completed successfully!"
echo ""
echo "📊 Checking deployment status:"
kubectl get pods -n $NAMESPACE
echo ""
kubectl get services -n $NAMESPACE
echo ""

if [ "$ENVIRONMENT" = "development" ]; then
    echo "🌐 To access the application:"
    echo "kubectl port-forward svc/${RELEASE_NAME}-api-prod 8080:5100 -n $NAMESPACE"
    echo "Then visit: http://localhost:8080/health"
    echo ""
    echo "For staging environment:"
    echo "kubectl port-forward svc/${RELEASE_NAME}-api-stage 8081:5100 -n $NAMESPACE"
    echo "Then visit: http://localhost:8081/health"
fi

echo ""
echo "📋 Useful commands:"
echo "  View logs:    kubectl logs -f deployment/${RELEASE_NAME}-api-prod -n $NAMESPACE"
echo "  Scale app:    kubectl scale deployment/${RELEASE_NAME}-api-prod --replicas=3 -n $NAMESPACE"
echo "  Delete:       helm uninstall $RELEASE_NAME -n $NAMESPACE"
echo "  Status:       helm status $RELEASE_NAME -n $NAMESPACE"