# Тестування IaС локально з використанням Kind

* `tf init` - ініціалізація, завантаження модулів[^1]

[^1]: Внесіть зміни в модуль kind-cluster <https://github.com/den-vasyliev/tf-kind-cluster/pull/1> для явного зазначення версії kubernetes в kind за потреби

* `tf validate` - перевірка конфігурації
* `tf apply` - застосування конфігурації, розгортання кластера
* `kind export kubeconfig --name kind-cluster` - встановлення контексту для подальшої роботи з кластером
* `tf apply` - продовження розгортання з використанням отриманих налаштувань в новому контексті
* `flux get all` - перевірка наявності node
* `k cluster-info` - інфо про кластер
* `flux check --pre` - перевірка передумов для flux
* `k get ns` - перевірка наявності потрібних namespace
* `flux logs -f` - безперервний вивід логів
* в репо flux-gitops руками додати `flux-gitops/clusters/kubot/ns.yaml` - по логам дивимось, що namespace підтягнувся
  
    ```yaml ns.yaml
    apiVersion: v1
    kind: Namespace
    metadata:
      name: kubot
    ```

* `k get ns` - перевіряємо namespace
* `flux create source git kubot --url=https://github.com/Andygol/kubot.git --branch=main --namespace=kubot --export` - створення маніфесту GitRepository `flux-gitops/clusters/kubot/kubot-gr.yaml`
  
  ```yaml
  apiVersion: source.toolkit.fluxcd.io/v1
  kind: GitRepository
  metadata:
    name: kubot
    namespace: kubot
  spec:
    interval: 1m0s
    ref:
      branch: main
    url: https://github.com/Andygol/kubot.git
  ```

* `flux create helmrelease kubot --namespace kubot --source GitRepository/kubot --chart ./helm --interval 1m --export` - створення маніфеста HelmRelease `flux-gitops/clusters/kubot/kubot-hr.yaml`
  
  ```yaml
  apiVersion: helm.toolkit.fluxcd.io/v2beta1
  kind: HelmRelease
  metadata:
    name: kubot
    namespace: kubot
  spec:
    chart:
      spec:
        chart: ./helm
        reconcileStrategy: ChartVersion
        sourceRef:
          kind: GitRepository
          name: kubot
    interval: 1m0s
  ```

* `flux logs -f` - додав руками маніфестів `kubot-gr.yaml`, `kubot-hr.yaml`
* `kubectl logs -n flux-system deployment/helm-controller | jq -r 'select(.source != null) | .source'` - перевірка версії api
* Поміняв ~~`v2beta2`~~ --> `v2beta1` у `kubot-hr.yaml`
* `k get po -n kubot` - перевірка створення поду
* `k describe pods -n kubot` - інформація про под
* … для повного розгортання поду потрібно передати токен застосунку через secret
* … далі буде