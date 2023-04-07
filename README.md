# helm-charts
Public repo for the Helm charts I use

## Attribution
Currently a modified version of [mvisonneau/generic-app](https://github.com/mvisonneau/helm-charts/tree/main/charts/generic-app). It's been updated to use newer Kubernetes APIs, and other changes made. A non-inclusive list, in no particular order:
    - Made dnsConfig and dnsPolicy optional
    - Removed DataDog-specific items
    - Removed some labels/annotations
    - Added volumeClaimTemplate for StatefulSet
    - Added loadBalancerClass to Service

