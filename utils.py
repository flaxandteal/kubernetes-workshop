from kubernetes import client, config
from urllib.request import urlopen
from IPython.core.display import HTML
import base64

config.load_kube_config()
contexts, active_context = config.list_kube_config_contexts()
ns = active_context['context']['namespace']

def get_service_ip(service):
    v1Api = client.CoreV1Api()
    result = v1Api.list_namespaced_endpoints(ns)
    item = next(i for i in result.items if i.metadata.name == service)
    return item.subsets[0].addresses[0].ip

def display_page(url):
    return HTML(
        '<iframe style="width: 100%; height: 500px" src="data:text/html;base64,'
        + base64.b64encode(urlopen(url).read()).decode()
        + '"></iframe>'
    )
