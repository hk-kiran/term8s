function sshc() {
  PS3="Select a namespace: "
  select ns in $(kubectl get namespace | grep -v NAME | awk '{print $1}')
  do
    echo "Selected:  $ns"
    echo "================================================================"
    PS3="Select a pod: "
    select pod in $(kubectl get pods -n $ns| grep -v NAME | awk '{print $1}')
    do
      echo "Selected:  $pod"
      echo "================================================================"
      PS3="Select container: "
      select c in $(kubectl get pods $pod -n $ns -o jsonpath='{.spec.containers[*].name}')
      do
        echo "Selected:  $c"
        echo "================================================================"
        PS3="Select one of the option: "
        select op in tail-logs shell attach
        do
          case $op in
            tail-logs )
              kubectl logs $pod $c -n $ns --follow
              ;;
            attach )
              kubectl attach -it -n $ns $pod -c $c
              ;;
            shell )
              kubectl exec -it -n $ns $pod -c $c -- sh -c "(bash || ash || sh)"
              ;;
          esac
          break
        done
        break
      done
    break
    done
  break
  done
  return $?
}
