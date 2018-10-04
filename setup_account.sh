#!/bin/sh

mkdir -p ~/.kube
rm -f ~/.kube/config
export USER=$GIT_COMMITTER_NAME
cat <<END > ~/.kube/config
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    server: https://$KUBERNETES_PORT_443_TCP_ADDR:$KUBERNETES_SERVICE_PORT_HTTPS
  name: jupyter-cluster
contexts:
- context:
    cluster: jupyter-cluster
    user: jupyter-user
    namespace: $USER
  name: jupyter-cluster
current-context: jupyter-cluster
kind: Config
preferences: {}
users:
- name: jupyter-user
  user:
    token: ~
END
SECRET=$(kubectl --token $(cat /var/run/secrets/kubernetes.io/serviceaccount/token) get serviceaccount -n $USER jupyter-user -o=jsonpath='{.secrets[0].name}')
TOKEN=$(kubectl --token $(cat /var/run/secrets/kubernetes.io/serviceaccount/token) get secret -n $USER $SECRET -o=jsonpath='{.data.token}' | base64 -d)
echo $TOKEN
rm -f ~/.kube/config
cat <<END > ~/.kube/config
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    server: https://$KUBERNETES_PORT_443_TCP_ADDR:$KUBERNETES_SERVICE_PORT_HTTPS
  name: jupyter-cluster
contexts:
- context:
    cluster: jupyter-cluster
    user: jupyter-user
    namespace: $USER
  name: jupyter-cluster
current-context: jupyter-cluster
kind: Config
preferences: {}
users:
- name: jupyter-user
  user:
    token: $TOKEN
END
