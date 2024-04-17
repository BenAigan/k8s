# Load Functions
echo -n "Loading Kubernetes Functions and Aliases ... "

# Kubernetes Aliases #

# kubectl 
alias k='kubectl'
alias kl='kubectl logs'
alias klf='kubectl logs --follow'

# kubectl describe
alias kd='kubectl describe'
alias kdcj='kubectl describe cronjob'
alias kdcm='kubectl describe configmap'
alias kdd='kubectl describe deploy'
alias kde='kubectl describe event'
alias kdj='kubectl describe job'
alias kdp='kubectl describe pod'
alias kdpv='kubectl describe persistentvolume'
alias kdpvc='kubectl describe persistentvolumeclaim'
alias kds='kubectl describe service'
alias kdsa='kubectl describe serviceaccount'
alias kdsc='kubectl describe storageclass'
alias kdst='kubectl describe secret'
alias kdsts='kubectl describe statefulset'
alias kdsvc='kubectl describe service'

# kubectl get
alias kg='kubectl get'
alias kgcj='kubectl get cronjob'
alias kgcm='kubectl get configmap'
alias kgd='kubectl get deploy'
alias kge='kubectl get event'
alias kgj='kubectl get job'
alias kgp='kubectl get pod'
alias kgpa='kubectl get pod -A'
alias kgpw='kubectl get pod -w'
alias kgpv='kubectl get persistentvolume'
alias kgpva='kubectl get persistentvolume -A'
alias kgpvc='kubectl get persistentvolumeclaim'
alias kgpvca='kubectl get persistentvolumeclaim -A'
alias kgs='kubectl get service'
alias kgsa='kubectl get serviceaccount'
alias kgsc='kubectl get storageclass'
alias kgst='kubectl get secret'
alias kgsts='kubectl get statefulset'
alias kgsvc='kubectl get service'
alias kgsvca='kubectl get service -A'

# kubectl top
alias ktp='kubectl top pod --sum=true'
alias ktn='kubectl top node'


# Kubernetes Functions

function podlogs { 

  # We can limit logs to a time using since, i.e. since 5 minutes ago
  since=$1

  # Make output dir
  logDir=~/podlogs/podlogs.$(date +%Y-%m-%d-%H%M%S )
  mkdir -p ${logDir}
  [[ $? -gt 0 ]] && return

  # Get logs from all pods
  for pod in $(kubectl get pods --no-headers -o custom-columns=":metadata.name"); do

    # Info
    [[ ! -z ${debug} ]] && echo "Getting pod logs for ${pod} ..."

    # Get logs
    if [[ ! -z ${since} ]]; then
      kubectl logs ${pod} --all-containers=true --since=${since} > ${logDir}/${pod}.txt
      [[ $? -gt 0 ]] && return
    else
      kubectl logs ${pod} --all-containers=true > ${logDir}/${pod}.txt
      [[ $? -gt 0 ]] && return
    fi

    # Confirm written
    [[ ! -z ${debug} ]] && echo "Pod ${pod} written to ${logDir}/${pod}.txt"

  done

  # Move to logs dir using pushd
  pushd ${logDir} > /dev/null
  [[ $? -eq 0 ]] && echo "Pushed dir onto Stack, popd to return, popd -0 to clear stack ..."
  dirs -v

}

function kscale {

  # Set Replica Count
  replicas=${1:-0}

  # Loop through each type
  for objectType in statefulsets deploy; do

    # Get list of objects
    objects=$(kubectl get ${objectType} --no-headers -o custom-columns=":metadata.name")

    # Loop through
    for object in ${objects}; do
      echo "kubectl scale --replicas ${replicas} ${objectType}/${object}"
    done

  done

  # Jobs can't be scaled any more
  jobs=$( kubectl get jobs --no-headers -o custom-columns=":metadata.name" )

  for job in ${jobs}; do
    echo "kubectl patch job ${job} -p '{\"spec\":{\"parallelism\":${replicas}}}'"
  done

}

function kn { # kubectl change context namespace
  if [[ ! -z $1 ]]; then
    kubectl config set-context --current --namespace $1
  else
    # Check if we have set namespace in config
    namespace=$( kubectl config view -o jsonpath={.contexts[].context.namespace} )

    printf "Namespace: %s\n" ${namespace}
    kubectl get namespaces
  fi

} 

echo "Loaded"
