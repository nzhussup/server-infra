kubectl apply -f argocd/server-insecure.yml
kubectl rollout restart deployment argocd-server -n argocd
